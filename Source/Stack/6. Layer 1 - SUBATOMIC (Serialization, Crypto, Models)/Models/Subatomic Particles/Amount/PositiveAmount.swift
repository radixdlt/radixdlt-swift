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

/// A strictly positive integer representing some amount, e.g. amount of tokens to transfer.
public struct PositiveAmount: NonNegativeAmountConvertible, Throwing {
    public typealias Magnitude = BigUnsignedInt
    public let magnitude: Magnitude
    
    public init(validated: Magnitude) {
        self.magnitude = validated
    }
    
    public init(validating unvalidated: Magnitude) throws {
        if unvalidated == 0 {
            throw Error.amountCannotBeZero
        }
        let validated = unvalidated
        self.init(validated: validated)
    }
}

// MARK: - Throwing
public extension PositiveAmount {
    enum Error: Swift.Error, Equatable {
        case amountCannotBeZero
        case amountCannotBeNegative
    }
}

// MARK: Presets
public extension PositiveAmount {
    static var one: PositiveAmount {
        return PositiveAmount(validated: 1)
    }
}

// MARK: - From NonNegativeAmount
public extension PositiveAmount {
    init(nonNegative: NonNegativeAmount) throws {
        try self.init(validating: nonNegative.magnitude)
    }
}

// MARK: - To NonNegativeAmount
public extension PositiveAmount {
    var asNonNegative: NonNegativeAmount {
        return NonNegativeAmount(positive: self)
    }
}

// MARK: - From SignedAmount
public extension PositiveAmount {
    init(signedAmount: SignedAmount) throws {
        switch signedAmount.amountAndSign {
        case .positive(let positive):
            self.init(validated: positive)
        case .zero:
            throw Error.amountCannotBeZero
        case .negative: throw Error.amountCannotBeNegative
        }
    }
}
