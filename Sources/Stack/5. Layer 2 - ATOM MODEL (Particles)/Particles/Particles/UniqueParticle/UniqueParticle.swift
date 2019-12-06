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

// swiftlint:disable colon opening_brace

/// A representation of something unique.
public struct UniqueParticle:
    ParticleConvertible,
    RadixModelTypeStaticSpecifying,
    RadixCodable,
    Accountable,
    Hashable
{
    
    // swiftlint:enable colon opening_brace

    public static let serializer = RadixModelType.uniqueParticle
    public let address: Address
    public let name: String
    public let nonce: Nonce
    
    public init(
        address: Address,
        string name: String,
        nonce: Nonce = Nonce()
    ) {
        self.address = address
        self.name = name
        self.nonce = nonce
    }
}

// MARK: Codable
public extension UniqueParticle {

    enum CodingKeys: String, CodingKey {
        case serializer, version, destinations
        case address, name, nonce
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(Address.self, forKey: .address)
        name = try container.decode(StringValue.self, forKey: .name).value
        nonce = try container.decode(Nonce.self, forKey: .nonce)
    }
    
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .address, value: address),
            EncodableKeyValue(key: .name, value: StringValue(validated: name)),
            EncodableKeyValue(key: .nonce, value: nonce)
        ]
    }
}

public extension UniqueParticle {
    var identifier: ResourceIdentifier {
        return ResourceIdentifier(address: address, name: name)
    }
}

// MARK: - Accountable
public extension UniqueParticle {
    func addresses() throws -> Addresses {
        return try Addresses(addresses: [identifier.address])
    }
}
