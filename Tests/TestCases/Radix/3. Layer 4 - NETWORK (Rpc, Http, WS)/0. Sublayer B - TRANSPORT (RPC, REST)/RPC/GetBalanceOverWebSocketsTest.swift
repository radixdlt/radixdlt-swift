//
//  GetBalanceTest.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-30.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest
import RxSwift
import RxTest
import RxBlocking

class GetBalanceOverWebSocketsTest: WebsocketTest {
    
    private var address: Address!
    private var xrd: ResourceIdentifier!
    
    override func setUp() {
        super.setUp()
        self.address = "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor"
        self.xrd = ResourceIdentifier(address: address, name: "XRD")
    }
    
    func testGetBalanceOverWS() {
        let magic: Magic = 1
        let identity = RadixIdentity(private: 1, magic: magic)
        let application = DefaultRadixApplicationClient(node: .localhost, identity: identity, magic: magic)
        guard let balance =  application.getBalances(for: address, ofToken: xrd).blockingTakeFirst() else { return }
        
        XCTAssertEqual(balance.balance.amount.description, "1000000000000000000000000000")
    }
}