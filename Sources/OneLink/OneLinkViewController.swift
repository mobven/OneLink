//
//  OneLinkViewController.swift
//  OneLink
//
//  Created by Rasid Ramazanov on 03.04.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import UIKit

/// `UIViewController` for embedding child view controllers
internal class OneLinkViewController: UIViewController {
    
    required init(with viewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        changeContent(to: viewController)
    }
    
    deinit {
        OneLink.shared.oneLinkViewControllerDeInit()
    }
    
    @available(iOS, unavailable, message: "init(coder:) has not been supported")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been supported")
    }
    
    fileprivate func changeContent(to viewController: UIViewController) {
        addChild(viewController)
        viewController.view.frame = CGRect(
            origin: view.bounds.origin,
            size: CGSize(width: view.bounds.width,
                         height: view.bounds.height)
        )
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    
}
