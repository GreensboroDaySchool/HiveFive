//
//  Notification.swift
//  Hive Five
//
//  Created by Jiachen Ren on 5/5/19.
//  Copyright © 2019 Greensboro Day School. All rights reserved.
//

import Foundation

extension Notification {
    enum Key: String {
        case themeUpdated
        case handUpdated
        case didSelectNewNode
        case didCancelSelection
        case didPlaceSelection
        case requiresQueenBee
        case displayMessage
        case kpHackableUpdated
        case kpHackableUpdateCancelled
        case toolBarVisibleUpdated
        case nodeSizeUpdated
        case showAlertsUpdated
        case profileUpdated
        case queen4Updated
        case immobilized4Updated
        case structureUpdated
        case selectedNodeUpdated
        case availablePositionsUpdated
        case rootNodeMoved
        case hiveStructureRemoved
    }
}

func post(
    key: Notification.Key,
    object: Any? = nil,
    userInfo: [AnyHashable : Any]? = nil
    ) {
    NotificationCenter.default.post(
        name: Notification.Name(key.rawValue),
        object: object,
        userInfo: nil
    )
    print("posted notification: \(key.rawValue)")
}
