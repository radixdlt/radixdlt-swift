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

import XCTest
@testable import RadixSDK
import Combine

class CreateTokenTests: IntegrationTest {

    func testFailingCreateTokenInSomeoneElsesName() throws {
        // GIVEN: An Application API owned by Alice, and identity Bob
        let aliceApp = application!
        
        // WHEN: Alice tries to create a token on Bob's behalf
        let (tokenCreation, _) = aliceApp.createToken(creator: bob)
        
        // THEN: We get an error
        try waitFor(
            tokenCreation: tokenCreation,
            toFailWithError: .uniqueActionError(.nonMatchingAddress(activeAddress: alice, butActionStatesAddress: bob)),
            because: "Alice cannot create a Token on Bob's behalf"
        )
    }
    
    /*
    func testFailCreatingTokenWithSameRRIAsUniqueId() {
        
        let actionCreateToken =
            application.actionCreateToken(symbol: "FOO")
        
        let rri = actionCreateToken.identifier
        
        let transaction = Transaction {
            PutUniqueIdAction(uniqueMaker: alice, string: "FOO")
            actionCreateToken
        }
        
        application.make(transaction: transaction).blockingAssertThrows(
            error: CreateTokenError.uniqueActionError(.rriAlreadyUsedByUniqueId(string: rri.name))
        )
    }
    
    func testFailCreatingTokenWithSameRRIAsExistingMutableSupplyToken() {
        
        let symbol: Symbol = "FOO"
        let actionCreateMutableToken = application.actionCreateMultiIssuanceToken(symbol: symbol)
        
        let transaction = Transaction {
            actionCreateMutableToken
            application.actionCreateToken(symbol: symbol)
        }
        
        application.make(transaction: transaction).blockingAssertThrows(
            error: CreateTokenError.uniqueActionError(
                .rriAlreadyUsedByMutableSupplyToken(identifier: actionCreateMutableToken.identifier)
            )
        )
    }
    
    func testFailCreatingTokenWithSameRRIAsExistingFixedSupplyToken() {
        let symbol: Symbol = "FOO"
        let actionCreateFixedToken = application.actionCreateFixedSupplyToken(symbol: symbol)
        
        let transaction = Transaction {
            actionCreateFixedToken
            application.actionCreateToken(symbol: symbol)
        }
        
        application.make(transaction: transaction).blockingAssertThrows(
            error: CreateTokenError.uniqueActionError(
                .rriAlreadyUsedByFixedSupplyToken(identifier: actionCreateFixedToken.identifier)
            )
        )
    }
 */
    
}

private extension CreateTokenTests {
    
    func waitFor(
        tokenCreation pendingTransaction: PendingTransaction,
        toFailWithError createTokenError: CreateTokenError,
        because description: String,
        timeout: TimeInterval = .enoughForPOW,
        line: UInt = #line
    ) throws {
        
        try waitForAction(
            ofType: CreateTokenAction.self,
            in: pendingTransaction,
            because: description
        ) { createTokenAction in
            
            TransactionError.actionsToAtomError(
                .createTokenActionError(
                    createTokenError,
                    action: createTokenAction
                )
            )
        }
    }
}
