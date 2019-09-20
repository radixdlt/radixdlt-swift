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
@testable import RadixSDK
import XCTest

class SignedAmountTests: XCTestCase {
    
    func testLiteralNegative() {
        let a: SignedAmount = -3
        XCTAssertEqual(a.description, "-3")
    }
    
    func testLiteralPositve() {
        let a: SignedAmount = 3
        XCTAssertEqual(a.description, "3")
    }
    
    func testLiteralZero() {
        let a: SignedAmount = 0
        XCTAssertEqual(a.description, "0")
    }
    
    func testBigSignedInt() {
        // Int64
        let a: SignedAmount = "100000000000000000000000000000000000000000000000000000"
        let b: SignedAmount = 1
        XCTAssertEqual(a + b, "100000000000000000000000000000000000000000000000000001")
    }
    
    func testFromSignedAmountNegative() {
        let a: SignedAmount = -1
        let b = SignedAmount(amount: a)
        XCTAssertAllEqual(a, b, -1)
    }
    
    func testFromSignedAmountZero() {
        let a: SignedAmount = 0
        let b = SignedAmount(amount: a)
        XCTAssertAllEqual(a, b, 0)
    }
    
    func testFromSignedAmountPositive() {
        let a: SignedAmount = 1
        let b = SignedAmount(amount: a)
        XCTAssertAllEqual(a, b, 1)
    }
    
    func testFromNonNegativeAmountPositive() {
        let a: NonNegativeAmount = 1
        let b = SignedAmount(amount: a)
        XCTAssertEqual(a, 1)
        XCTAssertEqual(b, 1)
        XCTAssertAllEqual(a.abs, b.abs, 1)
    }
    
    func testFromNonNegativeAmountZero() {
        let a: NonNegativeAmount = 0
        let b = SignedAmount(amount: a)
        XCTAssertEqual(a, 0)
        XCTAssertEqual(b, 0)
        XCTAssertAllEqual(a.abs, b.abs, 0)
    }
    
    func testFromPositiveAmount() {
        let a: PositiveAmount = 1
        let b = SignedAmount(amount: a)
        XCTAssertEqual(a, 1)
        XCTAssertEqual(b, 1)
        XCTAssertAllEqual(a.abs, b.abs, 1)
    }

    func testNegatedNegative() {
        let a: SignedAmount = -2
        let negated: SignedAmount = a.negated()
        XCTAssertEqual(negated, 2)
        XCTAssertEqual(negated.negated(), -2)
    }
    
    func testNegatedPositive() {
        let a: SignedAmount = 2
        let negated: SignedAmount = a.negated()
        XCTAssertEqual(negated, -2)
        XCTAssertEqual(negated.negated(), 2)
    }
    
    func testAbsNegative() {
        let a: SignedAmount = -5
        XCTAssertEqual(a.abs, 5)
    }
    
    func testAbsPositive() {
        let a: SignedAmount = 5
        XCTAssertEqual(a.abs, 5)
    }
    
    func testPositiveResultAdd() {
        let a: SignedAmount = 2
        let b: SignedAmount = 3
        XCTAssertEqual(a + b, 5)
    }
    
    func testPositiveResultMultiply() {
        let a: SignedAmount = 2
        let b: SignedAmount = 3
        XCTAssertEqual(a * b, 6)
    }
    
    func testPositiveResultMultiplyTwoNegative() {
        let a: SignedAmount = -2
        let b: SignedAmount = -3
        XCTAssertEqual(a * b, 6)
    }
    
    func testPositiveResultSubtract() {
        let a: SignedAmount = 2
        let b: SignedAmount = 3
        XCTAssertEqual(b - a, 1)
    }
    
    func testPositiveResultAddInout() {
        var a: SignedAmount = 2
        a += 3
        XCTAssertEqual(a, 5)
    }
    
    func testPositiveResultMultiplyInout() {
        var a: SignedAmount = 2
        a *= 5
        XCTAssertEqual(a, 10)
    }
    
    
    func testPositiveResultMultiplyInoutBothNegative() {
        var a: SignedAmount = -2
        a *= -5
        XCTAssertEqual(a, 10)
    }
    
    func testPositiveResultSubtractInout() {
        var a: SignedAmount = 9
        a -= 7
        XCTAssertEqual(a, 2)
    }
    
    func testNegativeResultAdd() {
        let a: SignedAmount = 2
        let b: SignedAmount = -3
        XCTAssertEqual(a + b, -1)
    }
    
    func testNegativeResultMultiply() {
        let a: SignedAmount = 2
        let b: SignedAmount = -3
        XCTAssertEqual(a * b, -6)
    }
    
    func testNegativeResultSubtract() {
        let a: SignedAmount = 2
        let b: SignedAmount = 3
        XCTAssertEqual(a - b, -1)
    }
    
    func testNegativeResultAddInout() {
        var a: SignedAmount = -4
        a += 3
        XCTAssertEqual(a, -1)
    }
    
    func testNegativeResultMultiplyInout() {
        var a: SignedAmount = 2
        a *= -5
        XCTAssertEqual(a, -10)
    }
    
    func testNegativeResultMultiplyInoutNegativeStart() {
        var a: SignedAmount = -2
        a *= 5
        XCTAssertEqual(a, -10)
    }
    
    func testNegativeResultSubtractInout() {
        var a: SignedAmount = 9
        a -= 11
        XCTAssertEqual(a, -2)
    }
}
