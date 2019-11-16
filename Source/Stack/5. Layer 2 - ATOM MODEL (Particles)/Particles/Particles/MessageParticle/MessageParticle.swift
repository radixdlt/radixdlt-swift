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

// swiftlint:disable colon

/// A way of sending, receiving and storing data from a verified source via a Message Particle type. Message Particle instances may contain arbitrary byte data with arbitrary string-based key-value metadata.
///
/// Sending, storing and fetching data in some form is required for virtually every application - from everyday instant messaging to complex supply chain management.
/// A decentralised ledger needs to support simple and safe mechanisms for data management to be a viable platforms for decentralised applications (or DApps).
/// For a formal definition read [RIP - Messages][1].
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/412844083/RIP-3+Messages
///
public struct MessageParticle:
    ParticleConvertible,
    RadixModelTypeStaticSpecifying,
    Accountable,
    RadixCodable,
    Equatable
{
// swiftlint:enable colon
    
    public static let serializer = RadixModelType.messageParticle
    
    public let from: Address
    public let to: Address
    public let metaData: MetaData
    public let payload: Data
    public let nonce: Nonce
    
    public init(
        from: Address,
        to: Address,
        payload: Data,
        nonce: Nonce = Nonce(),
        metaData: MetaData = [:]
    ) {
        self.from = from
        self.to = to
        self.metaData = metaData
        self.payload = payload
        self.nonce = nonce
    }
}

// MARK: - Convenience init
public extension MessageParticle {
    init(from: Address, to: Address, message: String, nonce: Nonce = Nonce(), includeTimeNow: Bool = true) {
        
        let messageData = message.toData()
        let metaData: MetaData = includeTimeNow ? .timeNow : [:]
        
        self.init(
            from: from,
            to: to,
            payload: messageData,
            nonce: nonce,
            metaData: metaData
        )
    }
}

// MARK: - Accountable
public extension MessageParticle {
    func addresses() throws -> Addresses {
        return try Addresses(addresses: [from, to])
    }
}

// MARK: Codable
public extension MessageParticle {
    enum CodingKeys: String, CodingKey {
        case serializer, version, destinations

        case from
        case to
        case payload = "bytes"
        case nonce
        case metaData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let from = try container.decode(Address.self, forKey: .from)
        let to = try container.decode(Address.self, forKey: .to)
        let payloadBase64 = try container.decodeIfPresent(Base64String.self, forKey: .payload)
        let metaData = try container.decodeIfPresent(MetaData.self, forKey: .metaData) ?? [:]
        let nonce = try container.decode(Nonce.self, forKey: .nonce)
        
        self.init(
            from: from,
            to: to,
            payload: payloadBase64?.asData ?? Data(),
            nonce: nonce,
            metaData: metaData
        )
    }
    
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        
        let payloadOrEmpty = payload.isEmpty ? "" : payload.toBase64String()
        
        return [
            EncodableKeyValue(key: .from, value: from),
            EncodableKeyValue(key: .to, value: to),
            EncodableKeyValue(key: .payload, value: payloadOrEmpty),
            EncodableKeyValue(key: .nonce, value: nonce),
            EncodableKeyValue(key: .metaData, nonEmpty: metaData)
        ].compactMap { $0 }
    }
}

public extension MessageParticle {
    var textMessage: String {
        return String(data: payload)
    }
}

public extension MessageParticle {
    var debugPayloadDescription: String {
        return "'\(textMessage)' [\(from) ➡️ \(to)]"
    }
}
