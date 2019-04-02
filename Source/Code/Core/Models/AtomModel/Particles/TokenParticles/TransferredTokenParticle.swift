//
//  TransferredTokenParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TransferredTokenParticle: TokenParticleConvertible, ConsumableTokens, ConsumingTokens {
    
    public static let serializer = RadixModelType.transferredTokensParticle
    
    public let address: Address
    public let tokenDefinitionReference: TokenDefinitionReference
    public let granularity: Granularity
    public let planck: Planck
    public let nonce: Nonce
    public let amount: Amount
    
    public init(
        address: Address,
        granularity: Granularity,
        nonce: Nonce = Nonce(),
        planck: Planck = Planck(),
        amount: Amount,
        tokenDefinitionReference: TokenDefinitionReference
        ) {
        self.address = address
        self.granularity = granularity
        self.nonce = nonce
        self.planck = planck
        self.amount = amount
        self.tokenDefinitionReference = tokenDefinitionReference
    }
}