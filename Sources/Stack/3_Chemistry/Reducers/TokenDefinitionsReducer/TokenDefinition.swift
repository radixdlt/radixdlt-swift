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

public struct TokenDefinition: TokenConvertible, Hashable {
    public let symbol: Symbol
    public let name: Name
    public let tokenDefinedBy: Address
    public let granularity: Granularity
    public let description: Description
    public let tokenSupplyType: SupplyType
    public let iconUrl: URL?
    public let tokenPermissions: TokenPermissions?
    public let supply: Supply?
    
    public init(
        symbol: Symbol,
        name: Name,
        tokenDefinedBy: Address,
        granularity: Granularity,
        description: Description,
        tokenSupplyType: SupplyType,
        iconUrl: URL?,
        tokenPermissions: TokenPermissions?,
        supply: Supply?
    ) {
        self.name = name
        self.symbol = symbol
        self.granularity = granularity
        self.tokenDefinedBy = tokenDefinedBy
        self.description = description
        self.tokenSupplyType = tokenSupplyType
        self.iconUrl = iconUrl
        self.tokenPermissions = tokenPermissions
        self.supply = supply
        
        if tokenSupplyType == .fixed && supply == Supply.zero {
            incorrectImplementation("Fixed supply of zero is not allowed")
        }
    }
}

public extension TokenDefinition {
    init(tokenConvertible token: TokenConvertible) {
        self.init(
            symbol: token.symbol,
            name: token.name,
            tokenDefinedBy: token.tokenDefinedBy,
            granularity: token.granularity,
            description: token.description,
            tokenSupplyType: token.tokenSupplyType,
            iconUrl: token.iconUrl,
            tokenPermissions: token.tokenPermissions,
            supply: token.supply
        )
    }
}
