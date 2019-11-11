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

public enum ResultOfUserAction: Throwing {
    
    case pendingSending(
        /// Ugly hack to retain this observable
        cachedAtom: AnyPublisher<SignedAtom, Never>,
        updates: Publishers.MakeConnectable<AnyPublisher<SubmitAtomAction, Never>>,
        completable: Completable
    )
    
    case failedToStageAction(FailedToStageAction)
}

// MARK: Convenience Init
public extension ResultOfUserAction {
    
    init(
        updates: AnyPublisher<SubmitAtomAction, Never>,
        cachedAtom: AnyPublisher<SignedAtom, Never>,
        autoConnect: ((Cancellable) -> Void)?
    ) {
        
//        let replayedUpdates = updates.replayAll()
//
//        let completable = updates.compactMap(typeAs: SubmitAtomActionStatus.self)
//            .lastOrError()
//            .flatMapCompletable { submitAtomActionStatus in
//                let statusEvent = submitAtomActionStatus.statusEvent
//                switch statusEvent {
//                case .stored: return Completable.completed()
//                case .notStored(let reason):
//                    log.warning("Not stored, reason: \(reason)")
//                    return Completable.error(Error.failedToSubmitAtom(reason.error))
//                }
//            }
//
//        self = .pendingSending(cachedAtom: cachedAtom, updates: replayedUpdates, completable: completable)
//
//        if let autoConnect = autoConnect {
//            autoConnect(replayedUpdates.connect())
//        }
        combineMigrationInProgress()
    }
}

// Throwing
public extension ResultOfUserAction {
    enum Error: Swift.Error {
        case failedToStageAction(FailedToStageAction)
        case failedToSubmitAtom(SubmitAtomError)
    }
}

public extension ResultOfUserAction {
    /// Blocking get of  signed atom.
    func atom(timeout: TimeInterval = 1) throws -> Atom {
        switch self {

        case .failedToStageAction(let stageActionError):
            throw stageActionError

        case .pendingSending:
            
//            return try cachedAtom.toBlocking(timeout: timeout)
//                .single()
//                .wrappedAtom
//                .wrappedAtom
            combineMigrationInProgress()
        }
    }
}

public struct FailedToStageAction: Swift.Error {
    let error: Swift.Error
    let userAction: UserAction
}

// MARK: RxBlocking
public extension ResultOfUserAction {
    func toObservable() -> AnyPublisher<SubmitAtomAction, Never> {
//        switch self {
//        case .pendingSending(_, let updates, _):
//            return updates
//        case .failedToStageAction(let failedAction):
//            return AnyPublisher<SubmitAtomAction, Never>.error(Error.failedToStageAction(failedAction))
//        }
        combineMigrationInProgress()
    }
    
    func toCompletable() -> Completable {
        combineMigrationInProgress()
//        switch self {
//        case .pendingSending(_, _, let completable):
//            return completable
//        case .failedToStageAction(let failedAction):
//            return Completable.error(Error.failedToStageAction(failedAction))
//        }
    }
    
    // Returns a bool marking if the action was successfully completed within the provided time period if any timeout was provided
    // if no `timeout` was provided, then the bool just marks if the action was successful or not in general.
    func blockUntilComplete(timeout: TimeInterval? = nil) -> Bool {
        combineMigrationInProgress()
//        switch toCompletable().toBlocking(timeout: timeout).materialize() {
//        case .completed: return true
//        case .failed: return false
//        }
    }
}
