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

public struct UniverseConfig:
    RadixModelTypeStaticSpecifying,
    RadixCodable,
    RadixHashable,
    DSONEncodable,
    Throwing,
    Decodable,
    Equatable,
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    // swiftlint:enable colon opening_brace
    
    public let magic: Magic
    public let port: Port
    public let name: String
    public let description: String
    public let type: UniverseType
    public let timestamp: Date
    public let creator: PublicKey
    public let genesis: Atoms
    public let planck: Planck
    
    /// Only used for tests
    internal let hashIdFromApi: HashEUID?
    
    private init(
        magic: Magic,
        port: Port,
        name: String,
        description: String,
        type: UniverseType,
        timestamp: Date,
        creator: PublicKey,
        genesis: Atoms,
        planck: Planck,
        hashIdFromApi: HashEUID? = nil
    ) throws {
        self.magic = magic
        self.port = port
        self.name = name
        self.description = description
        self.type = type
        self.timestamp = timestamp
        self.creator = creator
        self.genesis = genesis
        self.planck = planck
        self.hashIdFromApi = hashIdFromApi
        
        try UniverseConfig.nativeTokenDefinitionFrom(genesis: genesis)
        
        if let hashIdFromApi = hashIdFromApi {
            guard hashIdFromApi == self.hashEUID else {
                throw Error.hashIdFromApiDoesNotMatchCalculated
            }
        }
  
    }
}

// MARK: - Decodable
public extension UniverseConfig {
    
    enum CodingKeys: String, CodingKey {
        case serializer, version
        case magic, port, name, description, type, timestamp, creator, genesis, planck
        
        // TEST ONLY
        case hashIdFromApi = "hid"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let magic = try container.decode(Magic.self, forKey: .magic)
        let port = try container.decode(Port.self, forKey: .port)
        let name = try container.decode(StringValue.self, forKey: .name).stringValue
        let description = try container.decode(StringValue.self, forKey: .description).stringValue
        let type = try container.decode(UniverseType.self, forKey: .type)
        let timestampMillis = try container.decode(TimeInterval.self, forKey: .timestamp)
        let timestamp = TimeConverter.dateFrom(millisecondsSince1970: timestampMillis)
        let creator = try container.decode(PublicKey.self, forKey: .creator)
        let genesis = try container.decode(Atoms.self, forKey: .genesis)
        
        let planck = try container.decode(Planck.self, forKey: .planck)
        
        // TESTING ONLY
        let hashIdFromApi = try container.decodeIfPresent(HashEUID.self, forKey: .hashIdFromApi)
        
        try self.init(
            magic: magic,
            port: port,
            name: name,
            description: description,
            type: type,
            timestamp: timestamp,
            creator: creator,
            genesis: genesis,
            planck: planck,
            hashIdFromApi: hashIdFromApi
        )
    }
}

// MARK: Encodable
public extension UniverseConfig {
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .magic, value: magic, output: .allButHash),
            EncodableKeyValue(key: .planck, value: planck),
            EncodableKeyValue(key: .port, value: port),
            EncodableKeyValue(key: .name, value: name),
            EncodableKeyValue(key: .description, value: description),
            EncodableKeyValue(key: .timestamp, value: TimeConverter.millisecondsFrom(date: timestamp)),
            EncodableKeyValue(key: .creator, value: creator),
            EncodableKeyValue(key: .type, value: type),
            EncodableKeyValue(key: .genesis, value: genesis)
        ]
    }
}

// MARK: - RadixModelTypeStaticSpecifying
public extension UniverseConfig {
    static let serializer: RadixModelType = .universeConfig
}

// MARK: Throwing
public extension UniverseConfig {
    enum Error: Swift.Error, Equatable {
        case hashIdFromApiDoesNotMatchCalculated
        case noParticleForNativeToken
        case multipleNativeTokensFound([ResourceIdentifier])
    }
}

// MARK: - CustomDebugStringConvertible
public extension UniverseConfig {
    var debugDescription: String {
        return """
        Name: \(name),
        Type: \(type.name),
        Magic: \(magic)
        """
    }
}

public extension UniverseConfig {
    var magicByte: Byte {
        return magic.byte
    }

    func nativeTokenDefinition() throws -> TokenDefinition {
       return try UniverseConfig.nativeTokenDefinitionFrom(genesis: genesis)
    }
}

private extension UniverseConfig {
    @discardableResult
    static func nativeTokenDefinitionFrom(genesis: Atoms) throws -> TokenDefinition {
        let tokenDefinitions: [TokenDefinition] = genesis.atoms
            .flatMap { $0.fixedSupplyTokenDefinitionParticles(spin: .up) }
            .map { TokenDefinition(tokenConvertible: $0) }
        
        let count = tokenDefinitions.count
        if count == 1 {
            return tokenDefinitions[0]
        } else if count == 0 {
            throw Error.noParticleForNativeToken
        } else {
            throw Error.multipleNativeTokensFound(tokenDefinitions.map { $0.tokenDefinitionReference })
        }
    }
}
