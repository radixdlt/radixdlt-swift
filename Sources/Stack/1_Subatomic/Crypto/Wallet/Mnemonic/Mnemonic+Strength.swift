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

public extension Mnemonic {
    enum Strength: Int {
        case wordCountOf12 = 12
        case wordCountOf15 = 15
        case wordCountOf18 = 18
        case wordCountOf21 = 21
        case wordCountOf24 = 24
        
        public var wordCount: Int {
            return rawValue
        }
    }
}

extension Mnemonic.Strength: CaseIterable {}

public extension Mnemonic.Strength {
    static func supports(wordCount: Int) -> Bool {
        return Mnemonic.Strength(rawValue: wordCount) != nil
    }
}

// MARK: - To BitcoinKit
import BitcoinKit
internal extension Mnemonic.Strength {
    var toBitcoinKitStrength: BitcoinKit.Mnemonic.Strength {
        switch self {
        case .wordCountOf12: return .default
        case .wordCountOf15: return .low
        case .wordCountOf18: return .medium
        case .wordCountOf21: return .high
        case .wordCountOf24: return .veryHigh
        }
    }
}
