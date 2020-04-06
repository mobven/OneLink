//
//  UIViewContController+Extension.swift
//  OneLink
//
//  Created by Rasid Ramazanov on 03.04.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Returns visible view controller from a given view controller
    var visibleViewController: UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.visibleViewController
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.visibleViewController
        } else if let presentedViewController = presentedViewController {
            return presentedViewController.visibleViewController
        } else {
            return self
        }
    }
    
}
