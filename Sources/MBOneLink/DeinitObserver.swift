//
//  DeinitObserver.swift
//  OneLink
//
//  Created by Rasid Ramazanov on 26.09.2020.
//  Copyright © 2020 Mobven. All rights reserved.
//

import UIKit

internal class DeinitObserver {
    
    static var deinitCallbackKey = "deinitcallback"
    
    static func onObjectDeinit(forObject object: NSObject,
                               callback: @escaping () -> ()) {
        let rem = deinitCallback(forObject: object)
        rem.callbacks.append(callback)
    }
    
    static func deinitCallback(forObject object: NSObject) -> DeinitCallback {
        if let deinitCallback = objc_getAssociatedObject(object, &deinitCallbackKey) as? DeinitCallback {
            return deinitCallback
        } else {
            let rem = DeinitCallback()
            objc_setAssociatedObject(object, &deinitCallbackKey, rem, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return rem
        }
    }
}

@objc internal class DeinitCallback: NSObject {
    var callbacks: [() -> ()] = []
    
    deinit {
        callbacks.forEach({ $0() })
    }
}
