//
//  SpunParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct SpunParticle: Codable, RadixModelTypeStaticSpecifying {

    public static let type = RadixModelType.spunParticle

    public let spin: Spin
    public let particle: ParticleConvertible
    public init(spin: Spin = .down, particle: ParticleConvertible) {
        self.spin = spin
        self.particle = particle
    }
}

// MARK: - Deodable
public extension SpunParticle {
    
    public enum CodingKeys: String, CodingKey {
        case type = "serializer"
        
        case particle, spin
    }
    
    private enum ParticleTypeKey: String, CodingKey {
        case type = "serializer"
    }
    
    // swiftlint:disable:next function_body_length
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let particleNestedContainer = try container.nestedContainer(keyedBy: ParticleTypeKey.self, forKey: .particle)
        let modelType = try particleNestedContainer.decode(RadixModelType.self, forKey: .type)
        let particleType = try ParticleType(modelType: modelType)
        switch particleType {
        case .message:
            particle = try container.decode(MessageParticle.self, forKey: .particle)
        case .burnedToken, .transferredToken, .mintedToken:
            particle = try container.decode(TokenParticle.self, forKey: .particle)
        case .tokenDefinition: particle = try container.decode(TokenDefinitionParticle.self, forKey: .particle)
        case .unique: particle = try container.decode(UniqueParticle.self, forKey: .particle)
        }
        spin = try container.decode(Spin.self, forKey: .spin)
    }
}

// MARK: - Encodable
public extension SpunParticle {
    
    // swiftlint:disable:next function_body_length
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        
        if let messageParticle = particle as? MessageParticle {
            try container.encode(messageParticle, forKey: .particle)
        } else if let tokenDefinitionParticle = particle as? TokenDefinitionParticle {
            try container.encode(tokenDefinitionParticle, forKey: .particle)
        } else if let tokenParticle = particle as? TokenParticle {
            try container.encode(tokenParticle, forKey: .particle)
        } else if let uniqueParticle = particle as? UniqueParticle {
            try container.encode(uniqueParticle, forKey: .particle)
        }
        try container.encode(spin, forKey: .spin)
    }
}

public extension SpunParticle {
    static func up(particle: ParticleConvertible) -> SpunParticle {
        return SpunParticle(spin: .up, particle: particle)
    }
    
    static func down(particle: ParticleConvertible) -> SpunParticle {
        return SpunParticle(spin: .down, particle: particle)
    }
    
    func particle<P>(as type: P.Type) -> P? where P: ParticleConvertible {
        return particle.as(P.self)
    }
}
