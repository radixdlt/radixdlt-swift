//
//  RestClientTestLivePeers.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

import RxSwift
class RestClientTestLivePeersTest: XCTestCase {
    private let bag = DisposeBag()
    private let restClient = DefaultRESTClient(baseURL: URL.localhost)
    
    override func setUp() {
        super.setUp()
    }
    
    func testNodeFinder() {
        let expectation = XCTestExpectation(description: "rest client")
        
        restClient.request(router: NodeRouter.livePeers, decodeAs: [NodeRunnerData].self).subscribe(onSuccess: { nodeRunners in
            XCTAssertFalse(nodeRunners.isEmpty)
            XCTAssertEqual(nodeRunners[0].ipAddress, "172.18.0.3")
            expectation.fulfill()
        }, onError: {
            XCTFail("Error: \($0)")
            expectation.fulfill()
        }).disposed(by: bag)
        
        wait(for: [expectation], timeout: 10)
    }
    
}
