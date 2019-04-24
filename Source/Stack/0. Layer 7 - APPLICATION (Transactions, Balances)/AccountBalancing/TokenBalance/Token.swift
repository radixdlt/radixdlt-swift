//
//  Token.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Token: TokenConvertible, Hashable {
    public let symbol: Symbol
    public let name: Name
    public let address: Address
    public let granularity: Granularity
}

public extension Token {
    init(particle: TokenDefinitionParticle) {
        self.symbol = particle.symbol
        self.name = particle.name
        self.address = particle.address
        self.granularity = particle.granularity
    }
}

// MARK: - Known Tokens
public extension Token {
    
    static func rad(inUniverse universeConfig: UniverseConfig) -> Token {
        return Token(particle: universeConfig.rads)
    }
}