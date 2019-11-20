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

import XCTest
@testable import RadixSDK

class PointMultiplicationTests: XCTestCase {
    func testPointMultiplication() {
        let G = Secp256k1.G
     
        let curveOrderPlusOne = 1 + Secp256k1.order
        let one: BigUnsignedInt = 1

        do {
            let privateKey = try PrivateKey(wif: "5K6EwEiKWKNnWGYwbNtrXjA8KKNntvxNKvepNqNeeLpfW7FSG1v")
            let publicKey = PublicKey(private: privateKey)
            XCTAssertEqual(privateKey.hex, "a7ec27c206a68e33f53d6a35f284c748e0874ca2f0ea56eca6eb7668db0fe805")
            XCTAssertEqual(publicKey.description, "035d21e7a118c479a007d45401bdbd06e3f9814ad5bbbbc5cec17f19029a060903")
            
            // test point multiplication
            
            // with some private key
            let publicKeyPoint = privateKey * G
        
            XCTAssertEqual(publicKeyPoint.x.hex, "5d21e7a118c479a007d45401bdbd06e3f9814ad5bbbbc5cec17f19029a060903")
            XCTAssertEqual(publicKeyPoint.y.hex, "ccfca71eff2101ad68238112e7585110e0f2c32d345225985356dc7cab8fdcc9")
            
            // with order plus 1
            let pointOrderPlus1 = curveOrderPlusOne * G
            XCTAssertEqual(pointOrderPlus1.x.hex, "79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798")
            XCTAssertEqual(pointOrderPlus1.y.hex, "483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8")

            let pointOne = one * G
            XCTAssertEqual(pointOrderPlus1.x.hex, pointOne.x.hex)
            XCTAssertEqual(pointOrderPlus1.y.hex, pointOne.y.hex)
        } catch {
            XCTFail("error: \(error)")
        }
    }
    
}
