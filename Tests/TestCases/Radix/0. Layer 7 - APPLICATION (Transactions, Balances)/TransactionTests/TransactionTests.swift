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
import RxSwift

class TransactionTests: LocalhostNodeTest {
    
    private var aliceIdentity: AbstractIdentity!
    private var bobIdentity: AbstractIdentity!
    private var application: RadixApplicationClient!
    private var alice: Address!
    private var bob: Address!
    private var carolAccount: Account!
    private var carol: Address!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        aliceIdentity = AbstractIdentity(alias: "Alice")
        bobIdentity = AbstractIdentity(alias: "Bob")
        application = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: aliceIdentity)
        alice = application.addressOfActiveAccount
        bob = application.addressOf(account: bobIdentity.activeAccount)
        carolAccount = Account()
        carol = application.addressOf(account: carolAccount)
    }
    
    func testTransactionWithSingleCreateTokenActionWithoutInitialSupply() {
        // GIVEN identity alice and a RadixApplicationClient
        
        // WHEN Alice observes her transactions after creating token without
        XCTAssertTrue(
            application.createToken(defineSupply: .mutableZeroSupply)
                .result
                .blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        guard let transaction = application.observeMyTransactions().blockingTakeFirst(timeout: 1) else {
            return
        }
        
        // THEN said single CreateTokenAction can be seen in the transaction
        XCTAssertEqual(transaction.actions.count, 1)
        guard let createTokenAction = transaction.actions.first as? CreateTokenAction else {
            return XCTFail("Transaction is expected to contain exactly one `CreateTokenAction`, nothing else.")
        }
        XCTAssertEqual(createTokenAction.tokenSupplyType, .mutable)
    }
    
    func testTransactionWithSingleCreateTokenActionWithInitialSupply() {
        // GIVEN identity alice and a RadixApplicationClient
        
        // WHEN Alice observes her transactions after having made one with a single `CreateTokenAction`
        XCTAssertTrue(
            application.createToken(defineSupply: .mutable(initial: 123))
                .result
                .blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        guard let transaction = application.observeMyTransactions().blockingTakeFirst(timeout: 1) else {
            return
        }
        
        switch transaction.actions.countedElementsZeroOneTwoAndMany {
        // THEN one CreateTokenAction can be seen in the transaction
        case .two(let first, let secondAndLast):
            guard
                let createTokenAction = first as? CreateTokenAction,
                let mintTokenAction = secondAndLast as? MintTokensAction
            else { return XCTFail("Expected first action to be `CreateTokenAction`, and second to be MintTokensAction.")  }
            
            XCTAssertEqual(createTokenAction.tokenSupplyType, .mutable)
            XCTAssertEqual(mintTokenAction.amount, 123)
        default: XCTFail("Expected exactly two actions")
        }

    }
    
    func testTransactionWithSingleTransferTokensAction() {
        // GIVEN identity alice and a RadixApplicationClient
        // GIVEN: and bob
        // GIVEN: and `FooToken` created by Alice
        
        print("🙋🏻‍♀️ alice: \(alice!)")
        print("🙋🏻‍♂️ bob: \(bob!)")
        
        let (tokenCreation, fooToken) =
            application.createToken(defineSupply: .mutable(initial: 10))
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        XCTAssertTrue(
            //  WHEN: Alice makes a transaction containing a single TransferTokensAction of FooToken
            application.transferTokens(
                identifier: fooToken,
                to: bob,
                amount: 5,
                message: "For taxi fare"
            )
            .blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        // WHEN: and observes her transactions
        guard
            let transaction = application.observeMyTransactions(containingActionsOfAllTypes: [TransferTokensAction.self])
            .blockingTakeFirst()
        else { return }
        
        // THEN she sees a Transaction containing just the TransferTokensAction
        XCTAssertEqual(transaction.actions.count, 1)
        guard let transferTokensAction = transaction.actions.first as? TransferTokensAction else {
            return XCTFail("Transaction is expected to contain exactly one `BurnTokensAction`, nothing else.")
        }
        XCTAssertEqual(transferTokensAction.amount, 5)
        XCTAssertEqual(transferTokensAction.recipient, bob)
        XCTAssertEqual(transferTokensAction.attachedMessage(), "For taxi fare")
        XCTAssertEqual(transferTokensAction.sender, alice)
    }
    
    func testTransactionWithSingleBurnTokensAction() {
        // GIVEN identity alice and a RadixApplicationClient

        // GIVEN: and `FooToken` created by Alice
        
        let (tokenCreation, fooToken) =
            application.createToken(defineSupply: .mutable(initial: 123))
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        XCTAssertTrue(
            //  WHEN: Alice makes a transaction containing a single BurnTokensAction of FooToken
            application.burnTokens(amount: 23, ofType: fooToken).blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        // WHEN: and observes her transactions
        guard let transaction = application.observeMyTransactions(containingActionsOfAllTypes: [BurnTokensAction.self])
            .blockingTakeFirst() else { return }
        
        // THEN she sees a Transaction containing just the BurnTokensAction
        XCTAssertEqual(transaction.actions.count, 1)
        guard let burnTokensAction = transaction.actions.first as? BurnTokensAction else {
            return XCTFail("Transaction is expected to contain exactly one `BurnTokensAction`, nothing else.")
        }
        XCTAssertEqual(burnTokensAction.amount, 23)
    }
    
    func testTransactionWithSingleMintTokensAction() {
        // GIVEN identity alice and a RadixApplicationClient
        
        // GIVEN: and `FooToken` created by Alice
        
        let (tokenCreation, fooToken) =
            application.createToken(defineSupply: .mutableZeroSupply)
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        XCTAssertTrue(
            //  WHEN: Alice makes a transaction containing a single MintTokensAction of FooToken
            application.mintTokens(amount: 23, ofType: fooToken).blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        // WHEN: and observes her transactions
        guard let transaction = application.observeMyTransactions(containingActionsOfAllTypes: [MintTokensAction.self])
            .blockingTakeFirst() else { return }
        
        // THEN she sees a Transaction containing just the MintTokensAction
        XCTAssertEqual(transaction.actions.count, 1)
        guard let mintTokensAction = transaction.actions.first as? MintTokensAction else {
            return XCTFail("Transaction is expected to contain exactly one `MintTokensAction`, nothing else.")
        }
        XCTAssertEqual(mintTokensAction.amount, 23)
    }
    
    func testTransactionWithSingleSendMessageAction() {
        // GIVEN identity alice and a RadixApplicationClient
        
        // WHEN Alice observes her transactions after having made one with a single `SendMessageAction`
        XCTAssertTrue(
            application.sendEncryptedMessage("Hey Bob, this is secret!", to: bob)
                .blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        // WHEN: and observes her transactions
        guard let transaction = application.observeMyTransactions().blockingTakeFirst(timeout: 1) else {
            return
        }
        
        // THEN she sees a Transaction containing the SendMessageAction
        XCTAssertEqual(transaction.actions.count, 1)
        guard let sendMessageAction = transaction.actions.first as? SendMessageAction else {
            return XCTFail("Transaction is expected to contain exactly one `SendMessageAction`, nothing else.")
        }
        XCTAssertEqual(sendMessageAction.sender, alice)
        XCTAssertEqual(sendMessageAction.recipient, bob)
        XCTAssertEqual(sendMessageAction.decryptionContext, .decrypted)
        XCTAssertEqual(sendMessageAction.textMessage(), "Hey Bob, this is secret!")

    }
    
    func testTransactionWithSinglePutUniqueAction() {
        // GIVEN identity alice and a RadixApplicationClient
        
        // WHEN Alice observes her transactions after having made one with a single `PutUniqueIdAction`
        XCTAssertTrue(
            application.putUnique(string: "Foobar")
                .blockingWasSuccessfull()
        )
        
        // WHEN: and observes her transactions
        guard let transaction = application.observeMyTransactions().blockingTakeFirst(timeout: 1) else {
            return
        }
        
        // THEN she sees a Transaction containing the SendMessageAction
        XCTAssertEqual(transaction.actions.count, 1)
        guard let putUniqueAction = transaction.actions.first as? PutUniqueIdAction else {
            return XCTFail("Transaction is expected to contain exactly one `PutUniqueIdAction`, nothing else.")
        }
        XCTAssertEqual(putUniqueAction.uniqueMaker, alice)
        XCTAssertEqual(putUniqueAction.string, "Foobar")
        
    }
    
    func testTransactionWithTwoMintTokenAndTwoPutUniqueIdActions() {
        // GIVEN identity alice and a RadixApplicationClient
        
        // GIVEN: and `FooToken` created by Alice
        
        let (tokenCreation, fooToken) =
            application.createToken(defineSupply: .mutableZeroSupply)
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        //  WHEN: Alice makes a transaction containing 2 MintTokensAction of FooToken and 2 PutUnique and observes her transactions
        let newTransaction = Transaction {[
            MintTokensAction(tokenDefinitionReference: fooToken, amount: 5, minter: alice),
            MintTokensAction(tokenDefinitionReference: fooToken, amount: 10, minter: alice),
            PutUniqueIdAction(uniqueMaker: alice, string: "Mint5"),
            PutUniqueIdAction(uniqueMaker: alice, string: "Mint10")
        ]}
            
        XCTAssertTrue(
            application.send(transaction: newTransaction)
                .blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        // WHEN: and observes her transactions
        guard let transaction = application.observeMyTransactions(containingActionsOfAllTypes: [PutUniqueIdAction.self, MintTokensAction.self])
            .blockingTakeFirst() else { return }
        
        // THEN she sees a Transaction containing the 2 MintTokensAction and 2 PutUniqueActions
        XCTAssertEqual(transaction.actions.count, 4)
        guard
            let mint5 = transaction.actions[0] as? MintTokensAction,
            let mint10 = transaction.actions[1] as? MintTokensAction,
            let unique5 = transaction.actions[2] as? PutUniqueIdAction,
            let unique10 = transaction.actions[3] as? PutUniqueIdAction
            else { return XCTFail("Wrong actions") }
        
        XCTAssertEqual(unique5.string, "Mint5")
        XCTAssertEqual(unique10.string, "Mint10")
        XCTAssertEqual(mint5.amount, 5)
        XCTAssertEqual(mint10.amount, 10)
    }
    
    func testTransactionWithNoActions() {
        let atom = Atom()
        let atomToTransactionMapper = DefaultAtomToTransactionMapper(identity: aliceIdentity)
        guard let transaction = atomToTransactionMapper.transactionFromAtom(atom).blockingTakeFirst() else { return }
        XCTAssertEqual(transaction.actions.count, 0)
    }
    
    // BONUS
    func omitted_testBurnTransaction() {
        let (tokenCreation, fooToken) = application.createToken(defineSupply: .mutable(initial: 35))
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        let transaction = Transaction {[
            BurnTokensAction(tokenDefinitionReference: fooToken, amount: 5, burner: alice),
            BurnTokensAction(tokenDefinitionReference: fooToken, amount: 10, burner: alice)
            ]}
        
        let atom = try! application.atomFrom(transaction: transaction, addressOfActiveAccount: alice)
        let atomToBurnActionMapper = DefaultAtomToBurnTokenMapper()
        guard let burnActions: [BurnTokensAction] = atomToBurnActionMapper.mapAtomToActions(atom).blockingTakeFirst(1, timeout: 1) else { return }
        XCTAssertEqual(burnActions.count, 2)
        let burnActionZero = burnActions[0]
        XCTAssertEqual(burnActionZero.amount, 5)
        XCTAssertEqual(burnActionZero.burner, alice)
        XCTAssertEqual(burnActionZero.tokenDefinitionReference, fooToken)
        let burnActionOne = burnActions[1]
        XCTAssertEqual(burnActionOne.amount, 10)
        XCTAssertEqual(burnActionOne.burner, alice)
        XCTAssertEqual(burnActionOne.tokenDefinitionReference, fooToken)
    }
    
    private let bag = DisposeBag()
    func omitted_testTransactionWithMintPutUnique() {
        let (tokenCreation, fooToken) = application.createToken(defineSupply: .mutable(initial: 35))
        
        application.observeTransactions(at: alice).subscribe(onNext: {
            print("✅ tx: \($0)")
        }).disposed(by: bag)
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        let mintAndUniqueTx = Transaction {[
            MintTokensAction(tokenDefinitionReference: fooToken, amount: 5, minter: alice),
            PutUniqueIdAction(uniqueMaker: alice, string: "mint")
            ]}
        
        XCTAssertTrue(
            application.send(transaction: mintAndUniqueTx)
                // THEN: the Transaction is successfully sent
                .blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        let burnAndUniqueTx = Transaction {[
            BurnTokensAction.init(tokenDefinitionReference: fooToken, amount: 5, burner: alice),
            PutUniqueIdAction(uniqueMaker: alice, string: "burn")
            ]}
        
        XCTAssertTrue(
            application.send(transaction: burnAndUniqueTx)
                // THEN: the Transaction is successfully sent
                .blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        let onlyUniqueTx = Transaction {[
            PutUniqueIdAction(uniqueMaker: alice, string: "unique")
            ]}
        
        XCTAssertTrue(
            application.send(transaction: onlyUniqueTx)
                // THEN: the Transaction is successfully sent
                .blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        
        guard let putUniqueTransactions = application.observeTransactions(at: alice, containingActionOfAnyType: [PutUniqueIdAction.self]).blockingArrayTakeFirst(3, timeout: 1) else { return }
        XCTAssertEqual(
            putUniqueTransactions.flatMap { $0.actions(ofType: PutUniqueIdAction.self) }.map { $0.string },
            ["mint", "burn", "unique"]
        )
        
        guard let burnTxs = application.observeTransactions(at: alice, containingActionOfAnyType: [BurnTokensAction.self]).blockingArrayTakeFirst(1, timeout: 1) else { return }
        XCTAssertEqual(burnTxs.count, 1)
        XCTAssertEqual(burnTxs[0].actions.count, 2)
        
        guard let burnOrMintTransactions = application.observeTransactions(at: alice, containingActionOfAnyType: [BurnTokensAction.self, MintTokensAction.self]).blockingArrayTakeFirst(2, timeout: 1) else { return }
        
        XCTAssertEqual(burnOrMintTransactions.count, 2)
        
        guard let uniqueBurnTransactions = application.observeTransactions(at: alice, containingActionsOfAllTypes: [PutUniqueIdAction.self, BurnTokensAction.self]).blockingTakeFirst() else { return }
        
        guard case let uniqueActionInBurnTxs = uniqueBurnTransactions.actions(ofType: PutUniqueIdAction.self), let uniqueActionInBurnTx = uniqueActionInBurnTxs.first else { return XCTFail("Expected UniqueAction") }
        XCTAssertEqual(uniqueActionInBurnTx.string, "burn")
        
        guard let uniqueMintTransactions = application.observeTransactions(at: alice, containingActionsOfAllTypes: [PutUniqueIdAction.self, MintTokensAction.self]).blockingTakeFirst() else { return }
        
        guard case let uniqueActionInMintTxs = uniqueMintTransactions.actions(ofType: PutUniqueIdAction.self), let uniqueActionInMintTx = uniqueActionInMintTxs.first else { return XCTFail("Expected UniqueAction") }
        XCTAssertEqual(uniqueActionInMintTx.string, "mint")
    }
}


extension Symbol {
    static var random: Symbol {
        let randomSymbol = String(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(14))
        return .init(validated: randomSymbol)
    }
}

extension RadixApplicationClient {
    static var localhostAliceSingleNodeApp: RadixApplicationClient {
        return RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: AbstractIdentity(alias: "Alice"))
    }
}

extension RadixApplicationClient {
    func createToken(
        name: Name = .irrelevant,
        symbol: Symbol = .random,
        description: Description = .irrelevant,
        defineSupply supplyTypeDefinition: CreateTokenAction.InitialSupply.SupplyTypeDefinition,
        iconUrl: URL? = nil,
        granularity: Granularity = .default
    ) -> (result: ResultOfUserAction, rri: ResourceIdentifier) {
        
        let createTokenAction = try! CreateTokenAction(
            creator: addressOfActiveAccount,
            name: name,
            symbol: symbol,
            description: description,
            defineSupply: supplyTypeDefinition,
            granularity: granularity,
            iconUrl: iconUrl
        )
        
        return (create(token: createTokenAction), createTokenAction.identifier)
    }
    
    func createFixedSupplyToken(
        name: Name = .irrelevant,
        symbol: Symbol = .random,
        description: Description = .irrelevant,
        iconUrl: URL? = nil,
        supply: PositiveSupply = .max,
        granularity: Granularity = .default
    ) -> (result: ResultOfUserAction, rri: ResourceIdentifier) {
        
        return try! createToken(
            creator: addressOfActiveAccount,
            name: name,
            symbol: symbol,
            description: description,
            defineSupply: .fixed(to: supply),
            iconUrl: iconUrl,
            granularity: granularity
        )
    }
    
    func createMultiIssuanceToken(
        name: Name = .irrelevant,
        symbol: Symbol = .random,
        description: Description = .irrelevant,
        iconUrl: URL? = nil,
        initialSupply: Supply? = nil,
        granularity: Granularity = .default
    ) -> (result: ResultOfUserAction, rri: ResourceIdentifier) {
        
        return try! createToken(
            creator: addressOfActiveAccount,
            name: name,
            symbol: symbol,
            description: description,
            defineSupply: .mutable(initial: initialSupply),
            iconUrl: iconUrl,
            granularity: granularity
        )
    }
}