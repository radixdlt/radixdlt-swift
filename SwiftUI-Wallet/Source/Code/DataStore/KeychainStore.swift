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
import SwiftUI
import Combine
import KeychainSwift
import RadixSDK



extension Preferences {
    static var `default`: Preferences {
        return KeyValueStore(UserDefaults.standard)
    }

    var hasAgreedToTermsAndPolicy: Bool {
           get {
                    return isTrue(.hasAgreedToTermsAndPolicy)
                }
        set {
//            // Bug? This is needed to prevent infinite recursion....
//            if newValue != hasAgreedToTermsAndPolicy {
//                defaults.set(newValue, forKey: Key.hasAgreedToTermsAndPolicy.rawValue)
//            }
            save(value: newValue, forKey: .hasAgreedToTermsAndPolicy)
        }

    }
}


extension SecurePersistence {

    var mnemonic: Mnemonic? {
        get {
           loadCodable(forKey: .mnemonic)
        }
        set {
            saveValueOrDeleteIfNil(value: newValue, forKey: .mnemonic)
        }
    }

    var seedFromMnemonic: Data? {
        get {
            loadValue(forKey: .seedFromMnemonic)
        }
        set {
            saveValueOrDeleteIfNil(value: newValue, forKey: .seedFromMnemonic)
        }
    }

    var isWalletSetup: Bool {
        return seedFromMnemonic != nil || mnemonic != nil
    }

}

extension KeyValueStoring {
    func saveValueOrDeleteIfNil<Value>(value: Value?, forKey key: Key, options: SaveOptions = .default) {
        guard let newValue = value else {
            return deleteValue(forKey: key)
        }
        self.save(value: newValue, forKey: key, options: options)
    }

    func saveValueOrDeleteIfNil<Value>(value: Value?, forKey key: Key, options: SaveOptions = .default) where Value: Codable {
        guard let newValue = value else {
            return deleteValue(forKey: key)
        }
        self.saveCodable(newValue, forKey: key, options: options)
    }
}
