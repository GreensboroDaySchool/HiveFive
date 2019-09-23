//
//  NSObject+Observe.swift
//  Hive Five
//
//  Created by Xule Zhou on 5/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

extension NSObject {
    internal func observe(_ key: Notification.Key, _ selector: Selector) {
        NotificationCenter.default.addObserver(
            self,
            selector: selector,
            name: Notification.Name(key.rawValue),
            object: nil
        )
    }
    
    internal func observe(_ name: Notification.Name, _ selector: Selector) {
        NotificationCenter.default.addObserver(
            self,
            selector: selector,
            name: name,
            object: nil
        )
    }
}

