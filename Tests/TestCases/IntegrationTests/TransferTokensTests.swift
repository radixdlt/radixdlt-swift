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

class TransferTokensTests: IntegrationTest {

    func testTransferTokenWithGranularityOf1() throws {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        let (tokenCreation, rri) = applicationClient.createToken(symbol: "AC", supply: .fixed(to: 30))
        try waitForTransactionToFinish(tokenCreation)
        
        let myTokenDef = try waitForFirstValue(of: applicationClient.observeTokenDefinition(identifier: rri))
        XCTAssertEqual(myTokenDef.symbol, "AC")

        let myBalanceBeforeTx = try waitForFirstValueUnwrapped(of: applicationClient.observeMyBalance(ofToken: rri))
        XCTAssertEqual(myBalanceBeforeTx.token.tokenDefinitionReference, rri)
        XCTAssertEqual(myBalanceBeforeTx.amount, 30)
        
        // WHEN: Alice transfer tokens she owns, to Bob
        let transfer = applicationClient.transferTokens(identifier: rri, to: bob, amount: 10, message: "For taxi fare")

        // THEN: I see that the transfer actions completes successfully
        try waitForTransactionToFinish(transfer)
        
        let myBalanceAfterTx = try waitForFirstValueUnwrapped(of: applicationClient.observeMyBalance(ofToken: rri))
        XCTAssertEqual(myBalanceAfterTx.amount, 20)
        
        let bobsBalanceAfterTx = try waitForFirstValueUnwrapped(of: applicationClient.observeBalance(ofToken: rri, ownedBy: bob))
        XCTAssertEqual(bobsBalanceAfterTx.amount, 10)
        
        let myTransfer = try waitForFirstValue(of: applicationClient.observeMyTokenTransfers())
        XCTAssertEqual(myTransfer.sender, alice)
        XCTAssertEqual(myTransfer.recipient, bob)
        XCTAssertEqual(myTransfer.amount, 10)
        XCTAssertEqual(try XCTUnwrap(myTransfer.attachedMessage()), "For taxi fare")
        
        let bobTransfer = try waitForFirstValue(of: applicationClient.observeTokenTransfers(toOrFrom: bob))
        XCTAssertEqual(bobTransfer.sender, alice)
        XCTAssertEqual(bobTransfer.recipient, bob)
        XCTAssertEqual(bobTransfer.amount, 10)
    }
    
    func testTokenNotOwned() throws {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob

        // WHEN: Alice tries to transfer tokens of some type she does not own, to Bob
        let unknownRRI: ResourceIdentifier = "/\(alice!)/Unknown"
        
        let transfer = applicationClient.transferTokens(identifier: unknownRRI, to: bob, amount: 10)
        
        // THEN:  I see that action fails with error `unknownToken`
        try waitFor(
            transfer: transfer,
            toFailWithError: .consumeError(.unknownToken(identifier: unknownRRI))
        )
    }
  
    func testInsufficientFunds() throws {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
      
        // WHEN: Alice tries to transfer tokens with a larger amount than her current balance, to Bob
        let (tokenCreation, rri) =  applicationClient.createFixedSupplyToken(supply: 30)
        try waitForTransactionToFinish(tokenCreation)

        let transfer = applicationClient.transferTokens(identifier: rri, to: bob, amount: 50)
        
        // THEN:  I see that action fails with error `InsufficientFunds`, Alice tries to spend more coins then she has
        try waitFor(
            transfer: transfer,
            toFailWithError: .insufficientFunds(currentBalance: 30, butTriedToTransfer: 50)
        )
    }
    
    func testTransferTokenWithGranularityOf10() throws {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
  
        // WHEN: Alice transfer tokens she owns, having a granularity larger than 1, to Bob
        let (tokenCreation, rri) = applicationClient.createFixedSupplyToken(supply: 10000, granularity: 10)
        try waitForTransactionToFinish(tokenCreation)
       
        // THEN: I see that the transfer actions completes successfully
        let transfer = applicationClient.transferTokens(identifier: rri, to: bob, amount: 20)
        try wait(for: transfer.completion.record().finished, timeout: .enoughForPOW)
    }
    
    func testIncorrectGranularityOf5() throws {

        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        let (tokenCreation, rri) = applicationClient.createFixedSupplyToken(supply: 100, granularity: 5)
        try waitForTransactionToFinish(tokenCreation)
        
        // WHEN: Alice tries to transfer an amount of tokens not being a multiple of the granularity of said token, to Bob
        let transfer = applicationClient.transferTokens(identifier: rri, to: bob, amount: 7)
     
        // THEN: Transfer should fail because The amount 7 is not a multiple of granularity 5 (both are primes)
        try waitFor(
            transfer: transfer,
            toFailWithError: .consumeError(
                .amountNotMultipleOfGranularity(token: rri, triedToConsumeAmount: 7, whichIsNotMultipleOfGranularity: 5)
            )
        )
    }
    
    func testFailingTransferAliceTriesToSpendCarolsCoins() throws {
        
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        let (tokenCreation, rri) = applicationClient.createFixedSupplyToken(supply: 10000, granularity: 10)
        try wait(for: tokenCreation.completion.record().finished, timeout: .enoughForPOW)
        
        // WHEN: Alice tries to spend Carols coins
        let transfer = applicationClient.transferTokens(action: TransferTokensAction(from: carol, to: bob, amount: 20, tokenResourceIdentifier: rri))
        
        // THEN: Transfer should fail because Alice tries to spend Carols coins"
        try waitFor(
            transfer: transfer,
            toFailWithError: .consumeError(.nonMatchingAddress(activeAddress: alice, butActionStatesAddress: carol))
        )
    }
}

private extension TransferTokensTests {
    
    func waitFor(
        transfer pendingTransaction: PendingTransaction,
        toFailWithError transferError: TransferError,
        description: String? = nil,
        timeout: TimeInterval = .enoughForPOW,
        line: UInt = #line
    ) throws {
        
        try waitForAction(
            ofType: TransferTokensAction.self,
            in: pendingTransaction,
            description: description,
            line: line
        ) { transferTokensAction in
            
            TransactionError.actionsToAtomError(
                .transferTokensActionError(
                    transferError,
                    action: transferTokensAction
                )
            )
        }
    }
}
