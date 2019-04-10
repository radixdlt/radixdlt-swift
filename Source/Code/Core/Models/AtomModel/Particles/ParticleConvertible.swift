//
//  Particle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol ParticleConvertible: RadixHashable, Codable {
    var particleType: ParticleType { get }
}

public extension ParticleConvertible where Self: RadixModelTypeStaticSpecifying {
    var particleType: ParticleType {
        do {
            return try ParticleType(serializer: serializer)
        } catch {
            incorrectImplementation("Error: \(error)")
        }
    }
}
