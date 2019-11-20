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

// swiftlint:disable opening_brace colon

public struct Host:
    Throwing,
    CustomStringConvertible,
    Comparable,
    Decodable,
    Hashable
{
    // swiftlint:enable opening_brace colon
    
    public let domain: String
    public let port: Port
    
    public init(domain: String, port: Port) throws {
        self.domain = try URLFormatter.validating(isOnlyHost: domain)
        self.port = port
    }
    
}

public extension Host {
    var urlString: String {
        [domain, "\(port.port)"].joined(separator: ":")
    }
    
    var description: String {
        urlString
    }

}

public extension Host {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        do {
            return try compareDomains(of: lhs, and: rhs)
        } catch Error.bothDomainsAreLocalhostButOneUsesLettersAndOtherNumbers {
            fatalError("Both LHS and RHS are localhost, but one is '\(String.localhostLetters)' and other `\(String.localhostNumbers)`, thus Equatable consider them to differ, but in fact they should equal. TODO handle this gracefully")
        } catch {
            unexpectedlyMissedToCatch(error: error)
        }
    }

    static func compareDomains(of lhs: Self, and rhs: Self) throws -> Bool {
        let domains = [lhs, rhs].map { $0.domain }
        if domains.contains(String.localhostLetters) && domains.contains(String.localhostNumbers) {
            throw Error.bothDomainsAreLocalhostButOneUsesLettersAndOtherNumbers
        }
        return compare(lhs, rhs, ==)
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        compare(lhs, rhs, <)
    }
    
    static func <= (lhs: Self, rhs: Self) -> Bool {
        compare(lhs, rhs, <=)
    }
    
    static func > (lhs: Self, rhs: Self) -> Bool {
        compare(lhs, rhs, >)
    }
    
    static func >= (lhs: Self, rhs: Self) -> Bool {
        compare(lhs, rhs, >=)
    }
    
}

private extension Host {
    static func compare(_ lhs: Self, _ rhs: Self, _ comparison: (String, String) -> Bool) -> Bool {
        comparison(lhs.urlString, rhs.urlString)
    }
}
