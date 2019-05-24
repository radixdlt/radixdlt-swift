//
//  AnyEncodableKeyValueListConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-13.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol AnyEncodableKeyValueListConvertible: DSONEncodable {
    func anyEncodableKeyValues(output: DSONOutput) throws -> [AnyEncodableKeyValue]
}

// MARK: - AnyEncodableKeyValueListConvertible
public extension EncodableKeyValueListConvertible {
    func anyEncodableKeyValues(output: DSONOutput) throws -> [AnyEncodableKeyValue] {
        return try encodableKeyValues().map { try $0.toAnyEncodableKeyValue(output: output) }
    }
}

// MARK: - DSONEncodable
public extension AnyEncodableKeyValueListConvertible {
    
    /// Radix type "map", according to this: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/56557727/DSON+Encoding
    ///
    /// Format is this:
    ///
    /// ```
    /// 0xbf // encodeMapStreamStart
    /// properties.forEach { CBOREncoded(name, value) }
    /// 0xff // encodeStreamEnd
    /// ```
    ///
    func toDSON(output: DSONOutput = .default) throws -> DSON {
        var keyValues = try anyEncodableKeyValues(output: output)
        
        if let processor = self as? AnyEncodableKeyValuesProcessing {
            keyValues = try processor.process(keyValues: keyValues, output: output)
        }
        
        return [
            CBOR.encodeMapStreamStart(),
            keyValues.flatMap { $0.cborEncoded() },
            CBOR.encodeStreamEnd()
        ].flatMap { $0 }.asData
    }
}