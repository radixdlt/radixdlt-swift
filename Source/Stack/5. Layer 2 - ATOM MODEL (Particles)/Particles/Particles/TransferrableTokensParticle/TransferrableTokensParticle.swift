//
//  TransferrableTokensParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

public struct TransferrableTokensParticle:
    ParticleConvertible,
    Ownable,
    PublicKeyOwner,
    TokenDefinitionReferencing,
    Accountable,
    RadixCodable,
    RadixModelTypeStaticSpecifying {
    // swiftlint:enable colon
    
    public static let serializer = RadixModelType.transferrableTokensParticle
    
    public let address: Address
    public let tokenDefinitionReference: ResourceIdentifier
    public let granularity: Granularity
    public let planck: Planck
    public let nonce: Nonce
    public let amount: Amount
    public let permissions: TokenPermissions
    
    public init(
        amount: Amount,
        address: Address,
        tokenDefinitionReference: ResourceIdentifier,
        permissions: TokenPermissions = .default,
        granularity: Granularity = .default,
        nonce: Nonce = Nonce(),
        planck: Planck = Planck()
    ) {
        self.address = address
        self.granularity = granularity
        self.nonce = nonce
        self.planck = planck
        self.amount = amount
        self.tokenDefinitionReference = tokenDefinitionReference
        self.permissions = permissions
    }
}

// MARK: Decodable
public extension TransferrableTokensParticle {
    
    enum CodingKeys: String, CodingKey {
        case serializer
        case tokenDefinitionReference
        case address, granularity, nonce, planck, amount, permissions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let address = try container.decode(Address.self, forKey: .address)
        let permissions = try container.decode(TokenPermissions.self, forKey: .permissions)
        
        let granularity = try container.decode(Granularity.self, forKey: .granularity)
        let nonce = try container.decode(Nonce.self, forKey: .nonce)
        let planck = try container.decode(Planck.self, forKey: .planck)
        let amount = try container.decode(Amount.self, forKey: .amount)
        let tokenDefinitionReference = try container.decode(ResourceIdentifier.self, forKey: .tokenDefinitionReference)
        
        self.init(
            amount: amount,
            address: address,
            tokenDefinitionReference: tokenDefinitionReference,
            permissions: permissions,
            granularity: granularity,
            nonce: nonce,
            planck: planck
        )
    }
}

// MARK: RadixCodable
public extension TransferrableTokensParticle {
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .address, value: address),
            EncodableKeyValue(key: .amount, value: amount),
            EncodableKeyValue(key: .tokenDefinitionReference, value: tokenDefinitionReference),
            EncodableKeyValue(key: .permissions, value: permissions),
            EncodableKeyValue(key: .granularity, value: granularity),
            EncodableKeyValue(key: .nonce, value: nonce),
            EncodableKeyValue(key: .planck, value: planck)
        ]
    }
}

// MARK: - PublicKeyOwner
public extension TransferrableTokensParticle {
    var publicKey: PublicKey {
        return address.publicKey
    }
}

// MARK: Accountable
public extension TransferrableTokensParticle {
    var addresses: Addresses {
        return Addresses(arrayLiteral: address)
    }
}
