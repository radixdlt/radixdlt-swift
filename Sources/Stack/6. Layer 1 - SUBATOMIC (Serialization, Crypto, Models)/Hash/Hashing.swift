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
import CryptoKit

public protocol Hashing {
    func hash(data: Data) -> Data
}

public protocol SHA256Hashing: Hashing {
    func sha256(of data: Data) -> Data
}

public extension SHA256Hashing {
    func hash(data: Data) -> Data {
        return sha256(of: data)
    }
}

public protocol SHA256TwiceHashing: Hashing {
    func sha256Twice(of data: Data) -> Data
}

public extension SHA256TwiceHashing {
    func hash(data: Data) -> Data {
        return sha256Twice(of: data)
    }
}

public protocol SHA512TwiceHashing: Hashing {
    func sha512Twice(of data: Data) -> Data
}

public extension SHA512TwiceHashing {
    func hash(data: Data) -> Data {
        return sha512Twice(of: data)
    }
}

extension SHA256.Digest: DataConvertible {
    public var asData: Data { return Data(self) }
}

extension SHA512.Digest: DataConvertible {
    public var asData: Data { return Data(self) }
}
