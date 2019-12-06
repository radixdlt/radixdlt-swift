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

public struct SubmitAtomActionCompleted: SubmitAtomAction {
    
    public let atom: SignedAtom
    public let node: Node
    public let uuid: UUID
    public let result: SubmissionResult
    
    private init(
        atom: SignedAtom,
        node: Node,
        uuid: UUID,
        result: SubmissionResult
    ) {
        self.atom = atom
        self.node = node
        self.uuid = uuid
        self.result = result
    }
}

public extension SubmitAtomActionCompleted {
    
    static func success(sendAction: SubmitAtomActionSend, node: Node) -> Self {
        Self(atom: sendAction.atom, node: node, uuid: sendAction.uuid, result: .success)
    }
    
    static func failed(sendAction: SubmitAtomActionSend, node: Node, error: Error) -> Self {
        Self(atom: sendAction.atom, node: node, uuid: sendAction.uuid, result: .failure(error))
    }
}

public extension SubmitAtomActionCompleted {
    enum Error: Int, Swift.Error, Equatable {
        case timeout
    }
    enum SubmissionResult: Equatable {
        case success
        case failure(Error)
    }
}
