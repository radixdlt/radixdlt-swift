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

// swiftlint:disable colon opening_brace

/// A transfer of a non-zero amount of a certain token between two Radix accounts
public struct TransferTokensAction:
    ConsumeTokensAction,
    UserActionWithAddresses,
    Hashable
{
    
    // swiftlint:enable colon opening_brace

    public let sender: Address
    public let recipient: Address
    public let amount: PositiveAmount
    public let tokenResourceIdentifier: ResourceIdentifier
    
    public let attachment: Data?
    
    /// This `date` should **ONLY** be used for display purposes, has nothing to do with `API`/`hash`
    public let date: Date
    
    public init(
        from sender: AddressConvertible,
        to recipient: AddressConvertible,
        amount: PositiveAmount,
        tokenResourceIdentifier: ResourceIdentifier,
        attachment: Data? = nil,
        date: Date? = nil
    ) {
        self.sender = sender.address
        self.recipient = recipient.address
        self.amount = amount
        self.tokenResourceIdentifier = tokenResourceIdentifier
        self.attachment = attachment
        
        self.date = date ?? Date()
    }
}

// MARK: - Hashable
public extension TransferTokensAction {
    func hash(into hasher: inout Hasher) {
        hasher.combine(sender)
        hasher.combine(recipient)
        hasher.combine(amount)
        hasher.combine(tokenResourceIdentifier)
    }
}

// MARK: - UserAction
public extension TransferTokensAction {
    var user: Address { return sender }
    var nameOfAction: UserActionName { return .transferTokens }
    var identifierForTokenToConsume: ResourceIdentifier { return tokenResourceIdentifier }
}

// MARK: UserActionWithAddresses
public extension TransferTokensAction {
    var addresses: Set<Address> {
        return Set([sender, recipient])
    }
}

public extension TransferTokensAction {
    var metaDataFromAttachmentOrEmpty: MetaData {
        guard let attachment = attachment else { return [:] }
        return [.attachment: Base64String(data: attachment).stringValue]
    }
}

// MARK: Attachment as Message
public extension TransferTokensAction {
    func attachedMessage(decodeAs encoding: String.Encoding = .default) -> String? {
        guard let attachmentData = attachment else { return nil }
        return String(data: attachmentData, encoding: encoding)
    }
}
