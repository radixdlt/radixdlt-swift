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

public protocol SubmitAtomActionInitial: SubmitAtomAction {
    /// If `true`, a pending transaction will only complete on a `store`  event (`AtomStatusEvent`).
    var completeOnAtomStoredOnly: Bool { get }
}

public struct SubmitAtomActionRequest: SubmitAtomActionInitial, FindANodeRequestAction {
    public let atom: SignedAtom
    public let completeOnAtomStoredOnly: Bool
    public let uuid: UUID
    
    public init(atom: SignedAtom, completeOnAtomStoredOnly: Bool, uuid: UUID = .init()) {
        self.atom = atom
        self.completeOnAtomStoredOnly = completeOnAtomStoredOnly
        self.uuid = uuid
    }
}

public extension SubmitAtomActionRequest {
    var shards: Shards {
        do {
            return try atom.requiredFirstShards()
        } catch {
            incorrectImplementationShouldAlwaysBeAble(to: "get shards.", error)
        }
    }
}
