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
import BitcoinKit
import XCTest
@testable import RadixSDK

/// Sanity checks of Signing implementation of RFC6979 - Deterministic usage of ECDSA: https://tools.ietf.org/html/rfc6979
/// Test vectors: https://github.com/trezor/trezor-crypto/blob/957b8129bded180c8ac3106e61ff79a1a3df8893/tests/test_check.c#L1959-L1965
/// Signature data from: https://github.com/oleganza/CoreBitcoin/blob/master/CoreBitcoinTestsOSX/BTCKeyTests.swift
class Secp256k1RFC6979Tests: TestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testSecp256k1Vector1() {
        verifyRFC6979WithSignature(
            key: "CCA9FBCC1B41E5A95D369EAA6DDCFF73B61A4EFAA279CFC6567E8DAA39CBAF50",
            message: "sample",
            expectedSignatureR: "af340daf02cc15c8d5d08d7735dfe6b98a474ed373bdb5fbecf7571be52b3842",
            expectedSignatureS: "5009fb27f37034a9b24b707b7c6b79ca23ddef9e25f7282e8a797efe53a8f124",
            expectedDer: "3045022100af340daf02cc15c8d5d08d7735dfe6b98a474ed373bdb5fbecf7571be52b384202205009fb27f37034a9b24b707b7c6b79ca23ddef9e25f7282e8a797efe53a8f124"
        )
    }

    func testSecp256k1Vector2() {
        verifyRFC6979WithSignature(
            key: "0000000000000000000000000000000000000000000000000000000000000001",
            message: "Satoshi Nakamoto",
            expectedSignatureR: "934b1ea10a4b3c1757e2b0c017d0b6143ce3c9a7e6a4a49860d7a6ab210ee3d8",
            expectedSignatureS: "2442ce9d2b916064108014783e923ec36b49743e2ffa1c4496f01a512aafd9e5",
            expectedDer: "3045022100934b1ea10a4b3c1757e2b0c017d0b6143ce3c9a7e6a4a49860d7a6ab210ee3d802202442ce9d2b916064108014783e923ec36b49743e2ffa1c4496f01a512aafd9e5"
        )
    }

    func testSecp256k1Vector3() {
        verifyRFC6979WithSignature(
            key: "fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364140",
            message: "Satoshi Nakamoto",
            expectedSignatureR: "fd567d121db66e382991534ada77a6bd3106f0a1098c231e47993447cd6af2d0",
            expectedSignatureS: "6b39cd0eb1bc8603e159ef5c20a5c8ad685a45b06ce9bebed3f153d10d93bed5",
            expectedDer: "3045022100fd567d121db66e382991534ada77a6bd3106f0a1098c231e47993447cd6af2d002206b39cd0eb1bc8603e159ef5c20a5c8ad685a45b06ce9bebed3f153d10d93bed5"
        )
    }

    func testSecp256k1Vector4() {
        verifyRFC6979WithSignature(
            key: "f8b8af8ce3c7cca5e300d33939540c10d45ce001b8f252bfbc57ba0342904181",
            message: "Alan Turing",
            expectedSignatureR: "7063ae83e7f62bbb171798131b4a0564b956930092b33b07b395615d9ec7e15c",
            expectedSignatureS: "58dfcc1e00a35e1572f366ffe34ba0fc47db1e7189759b9fb233c5b05ab388ea",
            expectedDer: "304402207063ae83e7f62bbb171798131b4a0564b956930092b33b07b395615d9ec7e15c022058dfcc1e00a35e1572f366ffe34ba0fc47db1e7189759b9fb233c5b05ab388ea"
        )
    }

    func testSecp256k1Vector5() {
        verifyRFC6979WithSignature(
            key: "0000000000000000000000000000000000000000000000000000000000000001",
            message: "All those moments will be lost in time, like tears in rain. Time to die...",
            expectedSignatureR: "8600dbd41e348fe5c9465ab92d23e3db8b98b873beecd930736488696438cb6b",
            expectedSignatureS: "547fe64427496db33bf66019dacbf0039c04199abb0122918601db38a72cfc21",
            expectedDer: "30450221008600dbd41e348fe5c9465ab92d23e3db8b98b873beecd930736488696438cb6b0220547fe64427496db33bf66019dacbf0039c04199abb0122918601db38a72cfc21"
        )
    }

    func testSecp256k1Vector6() {
        verifyRFC6979WithSignature(
            key: "e91671c46231f833a6406ccbea0e3e392c76c167bac1cb013f6f1013980455c2",
            message: "There is a computer disease that anybody who works with computers knows about. It's a very serious disease and it interferes completely with the work. The trouble with computers is that you 'play' with them!",
            expectedSignatureR: "b552edd27580141f3b2a5463048cb7cd3e047b97c9f98076c32dbdf85a68718b",
            expectedSignatureS: "279fa72dd19bfae05577e06c7c0c1900c371fcd5893f7e1d56a37d30174671f6",
            expectedDer: "3045022100b552edd27580141f3b2a5463048cb7cd3e047b97c9f98076c32dbdf85a68718b0220279fa72dd19bfae05577e06c7c0c1900c371fcd5893f7e1d56a37d30174671f6"
        )
    }

    private func verifyRFC6979WithSignature(
        key privateKeyHex: String,
        message msgText: String,
        expectedSignatureR: String,
        expectedSignatureS: String,
        expectedDer: String
        ) {
        do {
            let hexString = try HexString(hexString: privateKeyHex)
            let privateKey = try RadixSDK.PrivateKey(hex: hexString)
            let message = try SignableMessage(unhashed: msgText.toData(), hashedBy: SHA256Hasher())
            let signature = try Signer.sign(message, privateKey: privateKey)
           
            let expectedSignature = try Signature(
                r: HexString(stringLiteral: expectedSignatureR).unsignedBigInteger,
                s: HexString(stringLiteral: expectedSignatureS).unsignedBigInteger
            )

            let publicKey = PublicKey(private: privateKey)
            XCTAssertTrue(try SignatureVerifier.verifyThat(signature: expectedSignature, signedMessage: message, usingKey: publicKey))
            
            XCTAssertEqual(signature.r.hex, expectedSignatureR)
            XCTAssertEqual(signature.s.hex, expectedSignatureS)
            
            XCTAssertEqual(try signature.toDER().hex, expectedDer)

        } catch {
            XCTFail("error: \(error)")
        }
    }
}

