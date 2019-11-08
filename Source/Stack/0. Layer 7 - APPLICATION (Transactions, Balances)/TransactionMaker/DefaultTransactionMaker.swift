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
import Combine

public final class DefaultTransactionMaker: TransactionMaker, AddressOfAccountDeriving, Magical {
    
    /// A mapper from a container of `UserAction`s the user wants to perform, to an `Atom` ready to be pushed to the Radix network (some node).
    private let transactionToAtomMapper: TransactionToAtomMapper
    
    /// Not all accounts of `identity` contain a signing (`private`) key, but all user actions (such as transferring tokens, sending messages etc) requires a cryptographic signature by the signing key, this strategy specifies what to do in those scenarios, and can be changed later in time.
    public var strategyNoSigningKeyIsPresent: StrategyNoSigningKeyIsPresent = .throwErrorDirectly
    
    /// A mapper from `Atom` to `AtomWithFee`
    private let feeMapper: FeeMapper
    
    private let universeConfig: UniverseConfig
    
    private let radixNetworkController: RadixNetworkController
    
    private let activeAccount: AnyPublisher<Account, Never>
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        activeAccount: AnyPublisher<Account, Never>,
        radixNetworkController: RadixNetworkController,
        universeConfig: UniverseConfig,
        transactionToAtomMapper: TransactionToAtomMapper,
        feeMapper: FeeMapper = DefaultProofOfWorkWorker()
    ) {
        self.activeAccount = activeAccount
        self.radixNetworkController = radixNetworkController
        self.universeConfig = universeConfig
        self.transactionToAtomMapper = transactionToAtomMapper
        self.feeMapper = feeMapper
    }
}

public extension DefaultTransactionMaker {
    convenience init(
        activeAccount: AnyPublisher<Account, Never>,
        universe: RadixUniverse
        ) {
        
        let transactionToAtomMapper = DefaultTransactionToAtomMapper(atomStore: universe.atomStore)
        
        self.init(
            activeAccount: activeAccount,
            radixNetworkController: universe.networkController,
            universeConfig: universe.config,
            transactionToAtomMapper: transactionToAtomMapper
        )
    }
}

// MARK: Magical
public extension DefaultTransactionMaker {
    var magic: Magic { return universeConfig.magic }
}

public extension DefaultTransactionMaker {
    func atomFrom(transaction: Transaction, addressOfActiveAccount: Address) throws -> Atom {
        return try transactionToAtomMapper.atomFrom(transaction: transaction, addressOfActiveAccount: addressOfActiveAccount)
    }
}

public extension DefaultTransactionMaker {
    func send(transaction: Transaction, toOriginNode originNode: Node?) -> ResultOfUserAction {
        
        do {
            
            let unsignedAtom = try buildAtomFrom(transaction: transaction)
            
            let signedAtom = sign(atom: unsignedAtom)
            
            return createAtomSubmission(
                atom: signedAtom,
                completeOnAtomStoredOnly: false,
                originNode: originNode
            )
        } catch let failedToStageAction as FailedToStageAction {
            return ResultOfUserAction.failedToStageAction(failedToStageAction)
        } catch {
            unexpectedlyMissedToCatch(error: error)
        }
    }
}

private extension DefaultTransactionMaker {
    
    func addFee(to atom: Atom) -> Single<AtomWithFee, Never> {
//        return activeAccount.flatMapToSingle { [unowned self] in
//            self.feeMapper.feeBasedOn(
//                atom: atom,
//                universeConfig: self.universeConfig,
//                key: $0.publicKey
//            )
//        }
        combineMigrationInProgress()
    }
    
    func sign(atom: AnyPublisher<UnsignedAtom, Never>) -> Single<SignedAtom, Never> {
//        return activeAccount.flatMapToSingle { account in
//            if account.privateKey == nil, case .throwErrorDirectly = self.strategyNoSigningKeyIsPresent {
//                return AnyPublisher.error(SigningError.noSigningKeyPresentButWasExpectedToBe)
//            }
//            return atom.flatMap {
//                try account.sign(atom: $0)
//            }
//        }
        combineMigrationInProgress()
    }
    
    func createAtomSubmission(
        atom atomSingle: Single<SignedAtom, Never>,
        completeOnAtomStoredOnly: Bool,
        originNode: Node?
        ) -> ResultOfUserAction {
        
//        let cachedAtom = atomSingle.cache()
//        let updates = cachedAtom
//            .flatMapObservable { [unowned self] (atom: SignedAtom) -> AnyPublisher<SubmitAtomAction, Never> in
//                let initialAction: SubmitAtomAction
//
//                if let originNode = originNode {
//                    initialAction = SubmitAtomActionSend(atom: atom, node: originNode, isCompletingOnStoreOnly: completeOnAtomStoredOnly)
//                } else {
//                    initialAction = SubmitAtomActionRequest(atom: atom, isCompletingOnStoreOnly: completeOnAtomStoredOnly)
//                }
//
//                let status: AnyPublisher<SubmitAtomAction, Never> = self.radixNetworkController
//                    .getActions()
//                    .compactMap(typeAs: SubmitAtomAction.self)
//                    .filter { $0.uuid == initialAction.uuid }
//                    .takeWhile { !$0.isCompleted }
//
//                self.radixNetworkController.dispatch(nodeAction: initialAction)
//                return status
//            }.share(replay: 1, scope: .forever)
//
//        let result = ResultOfUserAction(updates: updates, cachedAtom: cachedAtom) { [unowned self] in
//            // CombineDisposable from calling `connect`
//            $0.disposed(by: self.disposeBag)
//        }
//
//        return result
        combineMigrationInProgress()
    }
    
    var addressOfActiveAccount: AnyPublisher<Address, Never> {
        return activeAccount.map { [unowned self] in
            self.addressOf(account: $0)
        }.eraseToAnyPublisher()
    }
    
    func buildAtomFrom(transaction: Transaction) throws -> Single<UnsignedAtom, Never> {
//        return addressOfActiveAccount.flatMapToSingle { [unowned self] in
//            let atom = try self.transactionToAtomMapper.atomFrom(transaction: transaction, addressOfActiveAccount: $0)
//            return self.addFee(to: atom).map {
//                try UnsignedAtom(atomWithPow: $0)
//            }
//        }
        combineMigrationInProgress()
    }
}
