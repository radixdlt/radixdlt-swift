//
//  Dson.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Dson<Value: DsonConvertible>: Codable {
    public let value: Value
    public init(value: Value) {
        self.value = value
    }
}

extension Dson: Hashable where Value: Hashable {}
extension Dson: Equatable where Value: Equatable {}

// MARK: - Decodable
public extension Dson {
    
    init(from: Value.From) throws {
        try self.init(value: Value(from: from))
    }

    init(string rawString: String) throws {
        let components = rawString.components(separatedBy: Value.tag.identifier)
        guard components.count == 2 else {
            throw Error.noValueFound
        }
        try self.init(from: Value.From(string: components[1]))
    }
    
    public var identifer: String {
        return [
            Value.tag.identifier,
            String(describing: value)
        ].joined()
    }
}

// MARK: - Error
public extension Dson {
    public enum Error: Swift.Error {
        case noSeparator
        case singleSeparator
        case noLeadingSepartor
        case noTagFound
        case noValueFound
        case valueMismatch
        case tagMismatch(expected: DsonTag, butGot: DsonTag)
    }
}

// MARK: - Decodable
public extension Dson {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)
        try self.init(string: rawString)
    }
}

// MARK: - Encodable
public extension Dson {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(identifer)
    }
}

// MARK: - CustomStringConvertible
public extension Dson {
    var description: String {
        return identifer
    }
}