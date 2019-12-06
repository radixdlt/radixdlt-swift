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
import BitcoinKit

public struct Mnemonic: CustomStringConvertible {
    
    public static let separator: String = " "
    
    public let words: [Word]
    public let language: Language

    /// Pass a trivial closure: `{ _, _ in }` to `validateChecksum` if you would like to opt-out of checksum validation.
    public init(
        words: [Word],
        language: Language,
        validateChecksum: (([Word], Language) throws -> Void) = { try Mnemonic.validateChecksummed(words: $0, language: $1) }
    ) rethrows {
        try validateChecksum(words, language)

        self.words = words
        self.language = language
    }

    @discardableResult public static func validateChecksummed(words: [Word], language: Language) throws -> Bool {
        do {
            return try BitcoinKit.Mnemonic.validateChecksumOf(mnemonic: words.map { $0.value }, language: language.toBitcoinKitLanguage)
        } catch let bitcoinKitError as BitcoinKit.MnemonicError {
            let error = Mnemonic.Error(fromBitcoinKitError: bitcoinKitError)
            throw error
        } catch { fatalError("unexpected error: \(error)") }
    }

    @discardableResult public static func validateChecksummedDerivingLanguage(words: [Word]) throws -> Bool {
        do {
            return try BitcoinKit.Mnemonic.validateChecksumDerivingLanguageOf(mnemonic: words.map { $0.value })
        } catch let bitcoinKitError as BitcoinKit.MnemonicError {
            let error = Mnemonic.Error(fromBitcoinKitError: bitcoinKitError)
            throw error
        } catch { fatalError("unexpected error: \(error)") }
    }
}

public extension Mnemonic {
    var description: String {
        return "#\(words.count) words omitted for security reasons, language: '\(language)'"
    }
}

#if DEBUG
extension Mnemonic: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Mnemonic (this is only printable on DEBUG builds): \(words), language: \(language)"
    }
}
#endif

// MARK: - Internal
internal extension Mnemonic {
    init(strings: [String], language: Language) throws {
        try self.init(words: strings.map(Word.init(value:)), language: language)
    }
}

// MARK: - To BitcoinKit
public extension Mnemonic {
    var seed: Data {
        BitcoinKit.Mnemonic.seed(mnemonic: words.map { $0.value }) { _ in /* no checksum validation, should be handled by UI */ }
    }
}
