//
//  DictionaryConvertibleMutable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol DictionaryConvertibleMutable: DictionaryConvertible {
    var dictionary: [Key: Value] { get set }
    mutating func valueForKey(key: Key, ifAbsent createValue: () -> Value) -> Value
    
    @discardableResult
    mutating func removeValue(forKey key: Key) -> Value?
}

public extension DictionaryConvertibleMutable {
    mutating func valueForKey(key: Key, ifAbsent createValue: () -> Value) -> Value {
        return dictionary.valueForKey(key: key, ifAbsent: createValue)
    }
    
    /// Returns `value` that was removed, if any
    @discardableResult
    mutating func removeValue(forKey key: Key) -> Value? {
        return dictionary.removeValue(forKey: key)
    }
}
