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

public protocol PrefixedJsonDecodableByProxy: PrefixedJSONDecodable {
    associatedtype Proxy: PrefixedJSONDecodable
    init(proxy: Proxy) throws
}

public extension PrefixedJsonDecodableByProxy {
    static var jsonPrefix: JSONPrefix {
        return Proxy.jsonPrefix
    }
    init(prefixedString: PrefixedStringWithValue) throws {
        let proxy = try Proxy(prefixedString: prefixedString)
        try self.init(proxy: proxy)
    }
}

public protocol PrefixedJsonEncodableByProxy: PrefixedJSONEncodable {
    associatedtype Proxy: PrefixedJSONEncodable
    var proxy: Proxy { get }
}

public extension PrefixedJsonEncodableByProxy {
    var prefixedString: PrefixedStringWithValue {
        return proxy.prefixedString
    }
}
public typealias PrefixedJsonCodableByProxy = PrefixedJsonDecodableByProxy & PrefixedJsonEncodableByProxy
