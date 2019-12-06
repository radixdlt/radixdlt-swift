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

public enum WebSocketStatus: String, Hashable, CustomStringConvertible, CaseIterable {

    /// Newly found (not yet connected) nodes
    case disconnected
    
    case connecting
    case connected

    case closing
    case failed
}

public extension WebSocketStatus {
    
    var isConnected: Bool {
        return statusIs(.connected)
    }

    var isDisconnected: Bool {
        return statusIs(.disconnected)
    }
    
    func statusIs(_ `case`: WebSocketStatus) -> Bool {
        return enumCase(is: `case`)
    }
}

extension RawRepresentable where Self.RawValue: Equatable {
    func enumCase(is `case`: Self) -> Bool {
        return self.rawValue == `case`.rawValue
    }
}

extension CustomStringConvertible where Self: RawRepresentable, Self.RawValue == String {
    public var description: String {
        return rawValue
    }
}
