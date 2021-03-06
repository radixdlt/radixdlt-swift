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

public final class DefaultStateSubscriber: StateSubscriber {
    
    private let atomStore: AtomStore
    private let particlesToStateReducer: ParticlesToStateReducer
    
    public init(
        atomStore: AtomStore,
        particlesToStateReducer: ParticlesToStateReducer = DefaultParticlesToStateReducer.init()
    ) {
        self.atomStore = atomStore
        self.particlesToStateReducer = particlesToStateReducer
    }
}

// MARK: StateSubscriber
public extension DefaultStateSubscriber {
    func observeState<State>(
        ofType stateType: State.Type,
        at address: Address
    ) -> AnyPublisher<State, StateSubscriberError> where State: ApplicationState {
        
        atomStore.onSync(address: address)
            .mapToVoid()
            .tryMap { [unowned self] _ -> State in
                let upParticles = self.atomStore.upParticles(at: address)
                return try self.particlesToStateReducer.reduce(upParticles: upParticles, to: stateType)
            }
            .mapError { ParticlesToStateReducerError($0) }
            .mapError { StateSubscriberError.particlesToStateReducerError($0) }
            .eraseToAnyPublisher()
    }
}

public struct ParticlesToStateReducerError: Swift.Error {
    public let wrappedError: Swift.Error
    fileprivate init(_ error: Swift.Error) {
        self.wrappedError = error
    }
}

// MARK: Equatable-ish
public extension ParticlesToStateReducerError {
    func isEqual(to other: Self) -> Bool {
        return compareAny(
            lhs: wrappedError,
            rhs: other.wrappedError,
            beSatisfiedWithSameAssociatedTypeIfTheirValuesDiffer: false
        )
    }
}

public enum StateSubscriberError: Swift.Error, Equatable {
    case particlesToStateReducerError(ParticlesToStateReducerError)
}

public extension StateSubscriberError {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.particlesToStateReducerError(let lhsError), .particlesToStateReducerError(let rhsError)):
            return lhsError.isEqual(to: rhsError)
        }
    }
}
