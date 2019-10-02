////
//// MIT License
////
//// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
////
//// Permission is hereby granted, free of charge, to any person obtaining a copy
//// of this software and associated documentation files (the "Software"), to deal
//// in the Software without restriction, including without limitation the rights
//// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//// copies of the Software, and to permit persons to whom the Software is
//// furnished to do so, subject to the following conditions:
////
//// The above copyright notice and this permission notice shall be included in all
//// copies or substantial portions of the Software.
////
//// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//// SOFTWARE.
////
//
//import Foundation
//
//public extension PositiveAmount {
//
//    static func == <NNA>(tokenAmount: Self, amount: NNA) -> Bool where NNA: NonNegativeAmountConvertible {
//        return Self.compare(tokenAmount, amount, ==)
//    }
//
//    static func != <NNA>(tokenAmount: Self, amount: NNA) -> Bool where NNA: NonNegativeAmountConvertible {
//        return Self.compare(tokenAmount, amount, !=)
//    }
//
//    static func < <NNA>(tokenAmount: Self, amount: NNA) -> Bool where NNA: NonNegativeAmountConvertible {
//        return Self.compare(tokenAmount, amount, <)
//    }
//
//    static func > <NNA>(tokenAmount: Self, amount: NNA) -> Bool where NNA: NonNegativeAmountConvertible {
//        return Self.compare(tokenAmount, amount, >)
//    }
//
//    static func == <NNA>(amount: NNA, tokenAmount: Self) -> Bool where NNA: NonNegativeAmountConvertible {
//        return tokenAmount == amount
//    }
//    
//    static func != <NNA>(amount: NNA, tokenAmount: Self) -> Bool where NNA: NonNegativeAmountConvertible {
//        return tokenAmount != amount
//    }
//
//    static func < <NNA>(amount: NNA, tokenAmount: Self) -> Bool where NNA: NonNegativeAmountConvertible {
//        guard tokenAmount != amount else { return false }
//        return !(tokenAmount < amount)
//    }
//
//    static func > <NNA>(amount: NNA, tokenAmount: Self) -> Bool where NNA: NonNegativeAmountConvertible {
//        guard tokenAmount != amount else { return false }
//        return !(tokenAmount > amount)
//    }
//}
//
//private extension PositiveAmount {
//    static func compare<NNA>(_ tokenAmount: Self, _ amount: NNA, _ comparison: (NonNegativeAmount, NonNegativeAmount) -> Bool) -> Bool where NNA: NonNegativeAmountConvertible {
//        let lhs = NonNegativeAmount(nonNegative: tokenAmount.amountMeasuredInAtto)
//        let rhs = NonNegativeAmount(nonNegative: amount)
//        return comparison(lhs, rhs)
//    }
//}
