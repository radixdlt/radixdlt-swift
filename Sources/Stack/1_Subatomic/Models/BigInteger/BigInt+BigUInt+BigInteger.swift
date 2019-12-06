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
import BigInt

public protocol BigInteger: BinaryInteger, DataConvertible, DataInitializable {
    func serialize() -> Data
    func power(_ exponent: Int) -> Self
}

// MARK: - DataConvertible
public extension BigInteger {
    var asData: Data {
        return serialize()
    }
}

public typealias BigSignedInt = BigInt
public typealias BigUnsignedInt = BigUInt
extension BigSignedInt: BigInteger {}
extension BigUnsignedInt: BigInteger {
    public init(data: Data) {
        self.init(data)
    }
}

public extension BigInt {
    
    /// Stolen from: https://github.com/attaswift/BigInt/issues/54
    func serialize() -> Data {
        var array = Array(BigUInt.init(self.magnitude).serialize())
        
        if array.count > 0 {
            if self.sign == BigInt.Sign.plus {
                if array[0] >= 128 {
                    array.insert(0, at: 0)
                }
            } else if self.sign == BigInt.Sign.minus {
                if array[0] <= 127 {
                    array.insert(255, at: 0)
                }
            }
        }
        
        return Data(array)
    }
    
    init(_ data: Data) {
        var dataArray = Array(data)
        var sign: BigInt.Sign = BigInt.Sign.plus
        
        if dataArray.count > 0 {
            if dataArray[0] >= 128 {
                sign = BigInt.Sign.minus
                
                if dataArray.count > 1 {
                    if dataArray[0] == 255, dataArray.count > 1 {
                        dataArray.remove(at: 0)
                    } else {
                        dataArray[0] = UInt8(256 - Int(dataArray[0]))
                    }
                }
            }
        }
        
        let magnitude = dataArray.unsignedBigInteger
        
        self .init(sign: sign, magnitude: magnitude)
    }
}

// MARK: - BigUnsignedInt + StringInitializable
extension BigUnsignedInt: StringInitializable {
    
    public init(string: String) throws {
        guard let fromString = BigUnsignedInt(string, radix: 10) else {
            throw invalidCharacterError(string, allowed: .decimalDigits)
        }
        self = fromString
    }
}

// MARK: - BigUnsignedInt + StringRepresentable
extension BigUnsignedInt: StringRepresentable {
    public var stringValue: String {
        return self.toDecimalString()
    }
}

private func invalidCharacterError(_ invalidCharacter: String, allowed: CharacterSet) -> InvalidStringError {
    InvalidStringError.invalidCharacters(
        expectedCharacterSet: allowed,
        expectedCharacters: allowed.asString,
        butGot: invalidCharacter
    )
}

// MARK: - BigSignedInt + StringInitializable
extension BigSignedInt: StringInitializable {
    
    public init(string: String) throws {
        guard let fromString = BigSignedInt(string, radix: 10) else {
            throw invalidCharacterError(string, allowed: .decimalDigits)
        }
        self = fromString
    }
}

// MARK: - BigSignedInt + StringRepresentable
extension BigSignedInt: StringRepresentable {
    public var stringValue: String {
        return self.toDecimalString()
    }
}
