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

class NonNegativeAmountTests: TestCase {
    
    func testNonNegativeAmount256BitMaxValue() {
        XCTAssertEqual(NonNegativeAmount.max.hex, String(repeating: "f", count: 64))
    }
    
    func testAdd() {
        let a: NonNegativeAmount = 2
        let b: NonNegativeAmount = 3
        XCTAssertEqual(a + b, 5)
    }
    
    func testAddZero() {
        let a: NonNegativeAmount = 2
        let b: NonNegativeAmount = 0
        XCTAssertEqual(a + b, a)
    }
    
    func testMultiply() {
        let a: NonNegativeAmount = 2
        let b: NonNegativeAmount = 3
        XCTAssertEqual(a * b, 6)
    }
    
    func testMultiplyZero() {
        let a: NonNegativeAmount = 2
        let b: NonNegativeAmount = 0
        XCTAssertEqual(a * b, 0)
    }
    
    func testSubtract() {
        let a: NonNegativeAmount = 2
        let b: NonNegativeAmount = 3
        XCTAssertEqual(b - a, 1)
    }
    
    func testSubtractZero() {
        let a: NonNegativeAmount = 2
        let b: NonNegativeAmount = 0
        XCTAssertEqual(a - b, a)
    }
    
    
    func testAddInout() {
        var a: NonNegativeAmount = 2
        a += 3
        XCTAssertEqual(a, 5)
    }
    
    func testAddInoutZero() {
        var a: NonNegativeAmount = 2
        a += 0
        XCTAssertEqual(a, 2)
    }
    
    func testMultiplyInout() {
        var a: NonNegativeAmount = 2
        a *= 5
        XCTAssertEqual(a, 10)
    }
    
    
    func testMultiplyInoutZero() {
        var a: NonNegativeAmount = 2
        a *= 0
        XCTAssertEqual(a, 0)
    }
    
    func testSubtractInout() {
        var a: NonNegativeAmount = 9
        a -= 7
        XCTAssertEqual(a, 2)
    }
    
    func testGreaterThanZeroLiteral() {
        func assertIsLargerThanZero(_ nonNegativeAmount: NonNegativeAmount) {
            if nonNegativeAmount > 0 {
                XCTAssertTrue(true)
            } else {
                XCTFail("Should have been larager than zero")
            }
        }
        
        assertIsLargerThanZero(1)
    }
    
    func testBinaryIntegerProtocolMethods() {
        let amount: NonNegativeAmount = 15
        XCTAssertEqual(amount.bitWidth, 4)
    }
}
