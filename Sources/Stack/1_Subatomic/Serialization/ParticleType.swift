//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

public enum ParticleType {
    case message
    case mutableSupplyTokenDefinition
    case fixedSupplyTokenDefinition
    case unallocated
    case transferrable
    case resourceIdentifier
    case unique
}

public extension ParticleType {
    enum Error: Swift.Error {
        case notParticle
    }
}

internal extension ParticleType {
    init(serializer: RadixModelType) throws {
        switch serializer {
        case .unallocatedTokensParticle:            self = .unallocated
        case .uniqueParticle:                       self = .unique
        case .transferrableTokensParticle:          self = .transferrable
        case .messageParticle:                      self = .message
        case .resourceIdentifierParticle:           self = .resourceIdentifier
        case .mutableSupplyTokenDefinitionParticle: self = .mutableSupplyTokenDefinition
        case .fixedSupplyTokenDefinitionParticle:   self = .fixedSupplyTokenDefinition
        default:                                    throw Error.notParticle
        }
    }
    
    var serializer: RadixModelType {
        switch self {
        case .unallocated:                  return .unallocatedTokensParticle
        case .message:                      return .messageParticle
        case .unique:                       return .uniqueParticle
        case .resourceIdentifier:           return .resourceIdentifierParticle
        case .transferrable:                return .transferrableTokensParticle
        case .mutableSupplyTokenDefinition: return .mutableSupplyTokenDefinitionParticle
        case .fixedSupplyTokenDefinition:   return .fixedSupplyTokenDefinitionParticle
        }
    }
}

internal extension ParticleType {
    var debugEmoji: String {
        switch self {
        case .fixedSupplyTokenDefinition: return "🔒"
        case .mutableSupplyTokenDefinition: return "🔓"
        case .message: return "💌"
        case .resourceIdentifier: return "🆔"
        case .unallocated: return "👽"
        case .transferrable: return "💸"
        case .unique: return "🦄"
        }
    }

    var debugName: String {
        switch self {
        case .fixedSupplyTokenDefinition: return "FixedToken"
        case .mutableSupplyTokenDefinition: return "MutableToken"
        case .message: return "Message"
        case .resourceIdentifier: return "RRI"
        case .unallocated: return "Unalloc"
        case .transferrable: return "Transf"
        case .unique: return "Unique"
        }
    }
}
