//
//  Address.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import SwiftCBOR

public protocol PrefixAddressSpecifying: JSONPrefixSpecifying {}
public protocol Base58Convertible: PrefixAddressSpecifying {
    var base58String: Base58String { get }
}

public struct Address: Base58Convertible, CBORDataConvertible, PrefixedJsonCodableByProxy, Hashable, CustomStringConvertible, ExactLengthSpecifying, DataInitializable {
    
    public static let length = 51
    
    /// `base58String` is the base58 encoding of `Z` where:
    /// `Z` = X | Y
    /// `|` = Concatenation between [Byte]
    /// `Y` = first 4 bytes of `H`
    /// `H` = RadixHash of X
    /// `X` = M | C
    /// `C` = Public Key on Compressed format (33 bytes)
    /// `M` = first byte of `Magic` number
    /// => Base58(Magic[0] | PKc | RadixHash(Magic[0] | PKc).prefix(4))
    public let base58String: Base58String
    public let publicKey: PublicKey
    
    public init(magic: Magic, publicKey: PublicKey) {
        self.publicKey = publicKey
        self.base58String = Address.checksummed(from: publicKey, magic: magic)
    }
    
    public init(base58String: Base58String) throws {
        try Address.validateLength(of: base58String)
        try Address.isChecksummed(base58String)
        let addressData = base58String.asData
        self.publicKey = try PublicKey(data: addressData[1...addressData.count - 5])
        self.base58String = base58String
    }
}

// MARK: - DataInitializable
public extension Address {
    init(data: Data) throws {
        try self.init(base58String: data.toBase58String())
    }
}

// MARK: - PrefixedJsonDecodableByProxy
public extension Address {
    public typealias Proxy = Base58String
    var proxy: Proxy {
        return base58String
    }
    init(proxy: Proxy) throws {
        try self.init(base58String: proxy)
    }
}

// MARK: DSONPrefixSpecifying
public extension Address {
    var dsonPrefix: DSONPrefix {
        return  .addressBase58
    }
}

// MARK: - DataConvertible
public extension Address {
    var asData: Data {
        return base58String.asData
    }
}

// MARK: - Convenience Init
public extension Address {
    init(publicKey: PublicKey, universeConfig: UniverseConfig) {
        self.init(magic: universeConfig.magic, publicKey: publicKey)
    }
}

// MARK: - StringInitializable
public extension Address {
    init(string: String) throws {
        let base58 = try Base58String(string: string)
        try self.init(base58String: base58)
    }
}
// MARK: - CustomStringConvertible
public extension Address {
    var description: String {
        return base58String.value
    }
}

// MARK: - Checksum
public extension Address {
    
    static func checksummed(from dataConvertible: DataConvertible, magic: Magic) -> Base58String {
        let magicByte = magic.asData.bytes[0]
        return checksummed(magicByte + dataConvertible.asData)
    }
    
    static func checksummed(_ dataConvertible: DataConvertible) -> Base58String {
        var data = dataConvertible.asData
        let checksum = RadixHash(unhashedData: data, hashedBy: Sha256TwiceHasher())
        data += checksum.prefix(Address.checksumByteCount)
        
        return data.toBase58String()
    }
    
    static func isChecksummed(base58: Base58String, magic: Magic) throws {
         let magicByte = magic.asData.bytes[0]
        try isChecksummed(magicByte + base58)
    }
    
    static let checksumByteCount = 4
    
    static func isChecksummed(_ dataConvertible: DataConvertible) throws {
        let data = dataConvertible.asData
        let checksumDropped = Data(data.dropLast(Address.checksumByteCount))
        guard data == checksummed(checksumDropped).asData else {
            throw Error.checksumMismatch
        }
    }
    
    public enum Error: Swift.Error {
        case checksumMismatch
    }
}
