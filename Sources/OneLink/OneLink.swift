//
//  OneLink.swift
//  OneLink
//
//  Created by Rasid Ramazanov on 01.04.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import UIKit
import MMBKit

// MARK: - Setup
extension OneLink: MBComponent {
    
    public func setup() {
        
    }
    
}

/// Manager for deeplinks and push notification navigations.
public final class OneLink {
    
    /// `OneLink` singleton instance.
    public static let shared: OneLink = OneLink()
    
}
