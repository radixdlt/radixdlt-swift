//
//  CreateTokenActionToParticleGroupsMapperTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-30.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import XCTest
@testable import RadixSDK

class CreateTokenActionToParticleGroupsMapperTests: XCTestCase {

    private let magic: Magic = 63799298
    private lazy var identity = RadixIdentity(private: 1, magic: magic)
    private lazy var address = Address(magic: magic, publicKey: identity.publicKey)
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    
    private func assertCorrectnessTokenCreationGroup(_ group: ParticleGroup) {
        let spunParticles = group.spunParticles
        XCTAssertEqual(spunParticles.count, 3)
        guard
            let spunRriParticle = spunParticles[0].mapToSpunParticle(with: ResourceIdentifierParticle.self),
            let spunTokenDefinitionParticle = spunParticles[1].mapToSpunParticle(with: TokenDefinitionParticle.self),
            let spunUnallocatedTokensParticle = spunParticles[2].mapToSpunParticle(with: UnallocatedTokensParticle.self)
            else { return }
        XCTAssertEqual(spunRriParticle.spin, .down)
        XCTAssertEqual(spunTokenDefinitionParticle.spin, .up)
        XCTAssertEqual(spunUnallocatedTokensParticle.spin, .up)
        let rriParticle = spunRriParticle.particle
        let tokenDefinitionParticle = spunTokenDefinitionParticle.particle
        let unallocatedTokensParticle = spunUnallocatedTokensParticle.particle
        
        
        XCTAssertAllEqual(
            "/JF5FTU5wdsKNp4qcuFJ1aD9enPQMocJLCqvHE2ZPDjUNag8MKun/CCC",
            rriParticle.resourceIdentifier,
            tokenDefinitionParticle.tokenDefinitionReference,
            unallocatedTokensParticle.tokenDefinitionReference
        )
        
        XCTAssertAllEqual(
            1,
            tokenDefinitionParticle.granularity,
            unallocatedTokensParticle.granularity
        )
        
        XCTAssertAllEqual(
            [.mint: .tokenCreationOnly, .burn: .none],
            tokenDefinitionParticle.permissions,
            unallocatedTokensParticle.permissions
        )
        
        XCTAssertEqual(
            unallocatedTokensParticle.amount,
            PositiveAmount.maxValue256Bits
        )
    }
    
    private func assertCorrectnessMintTokenGroup(_ mintTokenGroup: ParticleGroup, tokenCreationGroup: ParticleGroup, initialSupply: NonNegativeAmount, createTokenAction: CreateTokenAction) {
        
        guard
            case let tokenCreationGroupParticles = tokenCreationGroup.spunParticles,
            tokenCreationGroupParticles.count == 3,
            let unallocatedParticleFromTokenCreationGroup = tokenCreationGroupParticles[2].particle as? UnallocatedTokensParticle else {
                return XCTFail("Expected UnallocatedTokensParticle at index 2 in ParticleGroup at index 0")
        }
        
        let expectUnallocatedFromLeftOverSupply = (NonNegativeAmount.maxValue256Bits - initialSupply) > 0
        
        let spunParticles = mintTokenGroup.spunParticles
        
        if expectUnallocatedFromLeftOverSupply {
            XCTAssertEqual(spunParticles.count, 3)
        } else {
            XCTAssertEqual(spunParticles.count, 2)
        }
        
        guard
            let spunUnallocatedTokensParticle = spunParticles[0].mapToSpunParticle(with: UnallocatedTokensParticle.self),
            let spunTransferrableTokensParticle = spunParticles[1].mapToSpunParticle(with: TransferrableTokensParticle.self)
            else { return }
        XCTAssertEqual(spunUnallocatedTokensParticle.spin, .down)
        XCTAssertEqual(spunTransferrableTokensParticle.spin, .up)
       
        let unallocatedTokensParticle = spunUnallocatedTokensParticle.particle
        let transferrableTokensParticle = spunTransferrableTokensParticle.particle
        
        XCTAssertEqual(
            unallocatedParticleFromTokenCreationGroup.hashId,
            unallocatedTokensParticle.hashId,
            "The `UnallocatedTokensParticle` in the two ParticleGroups should be the same, but with different spin"
        )
        
        XCTAssertEqual(
            transferrableTokensParticle.amount.abs,
            createTokenAction.initialSupply.abs
        )
        
        if expectUnallocatedFromLeftOverSupply {
            guard
                let spunLeftOverUnallocatedTokensParticle = spunParticles[2].mapToSpunParticle(with: UnallocatedTokensParticle.self)
                else { return }
            
            XCTAssertEqual(spunLeftOverUnallocatedTokensParticle.spin, .up)
            let leftOverUnallocatedTokensParticle = spunLeftOverUnallocatedTokensParticle.particle
            XCTAssertEqual(unallocatedTokensParticle.tokenDefinitionReference, leftOverUnallocatedTokensParticle.tokenDefinitionReference)
        }
    }
    
    func testTokenCreationWithoutInitialSupply() {
        
        let createTokenAction = CreateTokenAction(
            creator: address,
            name: "Cyon",
            symbol: "CCC",
            description: "Cyon Crypto Coin is the worst shit coin",
            supplyType: .fixed
        )
        
        let particleGroups = DefaultCreateTokenActionToParticleGroupsMapper().particleGroups(for: createTokenAction)
        XCTAssertEqual(particleGroups.count, 1)
        guard let group = particleGroups.first else { return }
        
        assertCorrectnessTokenCreationGroup(group)
    }
    
    func doTestTokenCreation(initialSupply: NonNegativeAmount) {
        let createTokenAction = CreateTokenAction(
            creator: address,
            name: "Cyon",
            symbol: "CCC",
            description: "Cyon Crypto Coin is the worst shit coin",
            supplyType: .fixed,
            initialSupply: initialSupply
        )
        
        let particleGroups = DefaultCreateTokenActionToParticleGroupsMapper().particleGroups(for: createTokenAction)
        XCTAssertEqual(particleGroups.count, 2)
        guard let tokenCreationGroup = particleGroups.first else { return }
        assertCorrectnessTokenCreationGroup(tokenCreationGroup)
        let mintTokenGroup = particleGroups[1]
        
        assertCorrectnessMintTokenGroup(
            mintTokenGroup,
            tokenCreationGroup: tokenCreationGroup,
            initialSupply: initialSupply,
            createTokenAction: createTokenAction
        )
    }
    
    func testTokenCreationWithInitialSupplyPartial() {
        doTestTokenCreation(initialSupply: 1000)
    }
    
    func testTokenCreationWithInitialSupplyAll() {
        doTestTokenCreation(initialSupply: .maxValue256Bits)
    }
    
}