//
//  OneLinkTests.swift
//  OneLinkTests
//
//  Created by Rasid Ramazanov on 01.04.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import XCTest
@testable import MBOneLink

class OneLinkTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        OneLinkSpy.sharedSpy.setup()
    }
    
    func testImmediateLink() {
        OneLinkSpy.sharedSpy.present(oneLink: TestLink.immediate)
        XCTAssert(OneLinkSpy.sharedSpy.pendingLinks.count == 0)
    }
    
    func testWaitingForApprovalLink() {
        OneLinkSpy.sharedSpy.present(oneLink: TestLink.waitingForApproval)
        XCTAssert(OneLinkSpy.sharedSpy.pendingLinks.count == 1)
        OneLinkSpy.sharedSpy.present(oneLink: TestLink.waitingForApproval)
        XCTAssert(OneLinkSpy.sharedSpy.pendingLinks.count == 2)
        OneLinkSpy.sharedSpy.presentPendingLinks()
        XCTAssert(OneLinkSpy.sharedSpy.pendingLinks.count == 1)
    }
    
    func testPresentByIgnoringType() {
        OneLinkSpy.sharedSpy.present(oneLink: TestLink.waitingForApproval, ignoreLinkState: true)
        XCTAssert(OneLinkSpy.sharedSpy.pendingLinks.count == 0)
        OneLinkSpy.sharedSpy.present(oneLink: TestLink.waitingForApproval)
        XCTAssert(OneLinkSpy.sharedSpy.pendingLinks.count == 1)
        OneLinkSpy.sharedSpy.presentPendingLinks()
        XCTAssert(OneLinkSpy.sharedSpy.pendingLinks.count == 0)
    }
    
    func testOneLinkViewControllerDissmiss() {
        OneLinkSpy.sharedSpy.present(oneLink: TestLink.waitingForApproval)
        OneLinkSpy.sharedSpy.present(oneLink: TestLink.waitingForApproval)
        OneLinkSpy.sharedSpy.presentPendingLinks()
        OneLinkSpy.sharedSpy.delegate = self
        
        let expectation = XCTestExpectation(description: "deinit timer")
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            OneLinkSpy.sharedSpy.presentPendingLinks()
            expectation.fulfill()
        }
        
        XCTAssert(OneLinkSpy.sharedSpy.pendingLinks.count == 1)
        wait(for: [expectation], timeout: 3)
        XCTAssert(OneLinkSpy.sharedSpy.pendingLinks.count == 0)
    }
    
}

extension OneLinkTests: OneLinkDelegate {
    
    func oneLinkPendingNavigation(_ oneLink: OneLinkable) {
        XCTAssert(true)
    }
    
    func oneLinkAllLinksCompleted() {
        XCTAssert(true)
    }
    
}
