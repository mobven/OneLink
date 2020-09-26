//
//  OneLink.swift
//  OneLink
//
//  Created by Rasid Ramazanov on 01.04.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import UIKit
import MobKitCore

/// Protocol to achieve OneLink navigation within your application.
public protocol OneLinkable {
    /// View controller of the link.
    /// Return nil, navigation will continue with OneLinkDelegate.oneLinkPendingNavigation().
    var viewController: UIViewController? { get }
    /// State of the link.
    var state: OneLinkableState { get }
}

public enum OneLinkableState: Int, RawRepresentable {
    
    /// OneLinks with `immediate` type will be navigated immediately when received.
    case immediate
    /// Links waiting for approval. Will be kept in the `OneLink.shared` instance until `presentPendingLinks()` called.
    case waitingForApproval
    
}

/// Delegate to inform you about OneLink navigations.
public protocol OneLinkDelegate: class {
    /// Called when there is no link to be presented so that your application can continue to its regular flow.
    func oneLinkAllLinksCompleted()
    /// Called when deeplink has no view controller, and application should navigate, manually.
    func oneLinkPendingNavigation(_ oneLink: OneLinkable)
}

/// Manager for deeplinks and push notification navigations.
public class OneLink: MobKitComponent {
    
    /// `OneLink` singleton instance.
    static var instance: OneLink?
    /// `OneLink` singleton instance.
    public override class func shared() -> Self {
        if instance == nil {
            self.instance = OneLink()
        }
        guard let sharedInstance = self.instance as? Self else {
            fatalError("Could not cast OneLink")
        }
        return sharedInstance
    }
    
    override init() {
        super.init()
    }
    
    public override func setup() {
        
    }
    
    internal var pendingLinks: [OneLinkable] = []
    
    /// `OneLinkDelegate` instance to listen pending link dismiss events.
    public weak var delegate: OneLinkDelegate?
    
    /// Presents specified link. If oneLink type is `OneLinkableState.waitingForApproval`,
    /// it will be added to pending links queue.
    /// - parameter oneLink:         Link to be presented.
    /// - parameter ignoreLinkState: If set `true`, link will be navigated immediately, regarding of its state.
    ///                              Default value is false. If your application stores user login status,
    ///                              you can set the value true if the user is logged in.
    public func present(oneLink: OneLinkable, ignoreLinkState: Bool = false) {
        if ignoreLinkState || oneLink.state == .immediate {
            self.navigateToLink(oneLink)
            return
        }
        pendingLinks.append(oneLink)
    }
    
    /// Presents pending links in the queue those are waiting for approval.
    /// These links added via `present(oneLink:ignoreLinkState:)`
    /// where state of the link is `OneLinkableState.waitingForApproval`.
    public func presentPendingLinks() {
        if let link = pendingLinks.first {
            navigateToLink(link)
            pendingLinks.removeFirst()
        }
    }
    
    private func navigateToLink(_ oneLink: OneLinkable) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let viewController = oneLink.viewController else {
                self?.delegate?.oneLinkPendingNavigation(oneLink)
                return
            }
            DeinitObserver.onObjectDeinit(forObject: viewController) { [weak self] in
                self?.oneLinkViewControllerDeInit()
            }
            UIApplication.shared.keyWindow?.rootViewController?.visibleViewController?.present(
                viewController, animated: true, completion: nil
            )
        }
    }
    
    internal func oneLinkViewControllerDeInit() {
        guard !pendingLinks.isEmpty else {
            delegate?.oneLinkAllLinksCompleted()
            return
        }
        OneLink.shared().presentPendingLinks()
    }
    
}
