//
//  OneLinkSpy.swift
//  OneLink
//
//  Created by Rasid Ramazanov on 05.04.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import Foundation
@testable import MBOneLink

class OneLinkSpy: OneLink {
    
    static let sharedSpy: OneLinkSpy = OneLinkSpy()
    
    override public func presentPendingLinks() {
        if let link = pendingLinks.first {
            navigateToLink(link)
            pendingLinks.removeFirst()
        }
    }
    
    /// Navigate to like dismissing it immediately.
    private func navigateToLink(_ oneLink: OneLinkable) {
        let parentController = OneLinkViewControllerSpy(with: oneLink.viewController)
        parentController.dismiss(animated: true, completion: nil)
    }
    
    override internal func oneLinkViewControllerDeInit() {
        guard !pendingLinks.isEmpty else {
            delegate?.oneLinkAllLinksCompleted()
            return
        }
        OneLinkSpy.sharedSpy.presentPendingLinks()
    }
    
}

class OneLinkViewControllerSpy: OneLinkViewController {
    
    deinit {
        OneLinkSpy.sharedSpy.oneLinkViewControllerDeInit()
    }
    
}
