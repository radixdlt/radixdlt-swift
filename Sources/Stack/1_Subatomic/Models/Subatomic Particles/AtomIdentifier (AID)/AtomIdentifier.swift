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

/// An Atom Identifier - also known as `AID` - made up of 192 bits of truncated hash and 64 bits of a selected shard.
/// The AID is used so that Atoms can be located using just this identifier.
///
/// This is an example of an AID: `"9b3ff63d7a055e037f0d52b0e6382e07388927a66b2cc97c56abab3870585f04"`
///
public struct AtomIdentifier:
    Throwing,
    DataInitializable,
    DataConvertible,
    StringRepresentable,
    StringInitializable,
    Hashable,
    CustomStringConvertible
{
    // swiftlint:enable colon opening_brace
    
    /// 192 first bits of a `RadixHash`
    private let truncatedHash: Data
    
    /// 64 bit int representing the determinstically selected shard, based on the Hash of the Atom in question.
    public let shard: Shard
    
    public init(truncatedHash: Data, shard: Shard) throws {
        if truncatedHash.length != AtomIdentifier.byteCountHash {
            throw Error.incorrectByteCountOfTruncatedHash(
                expected: AtomIdentifier.byteCountHash,
                butGot: truncatedHash.length
            )
        }
        self.truncatedHash = truncatedHash
        self.shard = shard
    }
}

// MARK: - StringInitializable
public extension AtomIdentifier {
    init(string hexString: String) throws {
        let hex = try HexString(hexString: hexString)
        try self.init(data: hex.asData)
    }
}

// MARK: - StringRepresentable
public extension AtomIdentifier {
    var stringValue: String {
        return asData.hex
    }
    
    var shortAid: String {
        let idString = stringValue
        return [
            idString.prefix(4),
            "...",
            idString.suffix(4)
            ].joined()
    }
}

// MARK: - Equatable
public extension AtomIdentifier {
    static func == (lhs: AtomIdentifier, rhs: AtomIdentifier) -> Bool {
        return lhs.asData == rhs.asData
    }
}

public extension AtomIdentifier {
    
    init(hash: RadixHash, shard: Shard) throws {
        try self.init(
            truncatedHash: hash.asData.prefix(AtomIdentifier.byteCountHash),
            shard: shard
        )
    }
    
    init(hash: RadixHash, shards: Shards) throws {
        let shard = AtomIdentifier.selectShard(in: shards, basedOnHash: hash)
        try self.init(hash: hash, shard: shard)
    }
}

// MARK: - DataInitializable
public extension AtomIdentifier {
    init(data: Data) throws {
        if data.length != AtomIdentifier.byteCount {
            throw Error.incorrectByteCount(expected: AtomIdentifier.byteCount, butGot: data.length)
        }
        let truncatedHash = data.prefix(AtomIdentifier.byteCountHash)
        let shard = try Shard(data: CFSwapInt64BigToHost(UInt64(data: data.suffix(AtomIdentifier.byteCountShard))).asData)
        
        try self.init(truncatedHash: truncatedHash, shard: shard)
    }
}

// MARK: - DataConvertible
public extension AtomIdentifier {
    var asData: Data {
        return truncatedHash + CFSwapInt64HostToBig(UInt64(truncatingIfNeeded: shard))
    }
}

// MARK: - Constants
public extension AtomIdentifier {
    
    static let byteCountHash = 24
    static let byteCountShard = 8
    static let byteCount = byteCountHash + byteCountShard
}

// MARK: - Throwing
public extension AtomIdentifier {
    enum Error: Swift.Error {
        case incorrectByteCountOfTruncatedHash(expected: Int, butGot: Int)
        case incorrectByteCount(expected: Int, butGot: Int)
    }
}

// MARK: - Private
private extension AtomIdentifier {
    
    /// Deterministically selects a shard from a set of potential shards for any given Atom, using the RadixHash of said Atom.
    ///
    /// This function is defined in the Tempo whitepaper under the section about `AID` as:
    /// ```
    /// s(hash, shardSet) = shardSet.elementAt(hash.firstByte % shardSet.size)
    /// ```
    ///
    static func selectShard(in shards: Shards, basedOnHash hash: RadixHash) -> Shard {
        let targetShardIndex = Int(hash[0]) % shards.count
        let targetShard = shards.sorted(by: Shard.areInIncreasingOrderUnsigned)[targetShardIndex]
        return targetShard
    }
}
