//
//  TestLink.swift
//  OneLink
//
//  Created by Rasid Ramazanov on 05.04.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import UIKit
@testable import OneLink

enum TestLink: OneLinkable {
    
    case immediate
    case waitingForApproval
    
    var viewController: UIViewController {
        let linkViewController = UIViewController()
        switch self {
        case .immediate:
            linkViewController.view.tag = 1
        case .waitingForApproval:
            linkViewController.view.tag = 2
        }
        return linkViewController
    }
    
    var state: OneLinkableState {
        switch self {
        case .immediate:
            return .immediate
        case .waitingForApproval:
            return .waitingForApproval
        }
    }
    
}
