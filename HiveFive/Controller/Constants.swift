//
//  Constants.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/5/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import UIKit

/*
 Keep constants organized
 */
let themeUpdateNotification = Notification.Name("themeUpdated")
let defaultTheme = themes[0].name
let themeId = "theme"
func designatedTheme() -> Theme {
    return Theme.decode(get(id: themeId) as? String ?? defaultTheme)
}

let handUpdateNotification = Notification.Name("handUpdated")
let didSelectNewNodeNotification = Notification.Name("selectedNewNode")
let didCancelNewPiece = Notification.Name("cancelledSelectedNewNode")
let didPlaceNewPiece = Notification.Name("placeSelectedNewPiece")
let requiresQueenNotification = Notification.Name(rawValue: "requireQueen")
let displayMsgNotification = Notification.Name("requestDisplayMsg")
let kpHackableUpdateNotification = Notification.Name("kpHackableUpdated")
let kpHackableUpdateCancelledNotification = Notification.Name("kpHackableUpdateCancelled")

//MARK: User Default
//Note: posted value is always the new value
let toolBarVisibilityId = "toolBarVisibility"
let toolBarVisibilityNotification = Notification.Name(toolBarVisibilityId)
let defaultToolBarVisibility = true
func toolBarShouldBeVisible() -> Bool {
    return get(id: toolBarVisibilityId) as? Bool ?? defaultToolBarVisibility
}

let preferredNodeSizeId = "preferredNodeSize"
let preferredNodeSizeNotification = Notification.Name(preferredNodeSizeId)
let preferredNodeSizes: [CGFloat] = [90,100,120] //small, medium, large
let defaultNodeSize = 1 //the index of the node size
func nodeSizeIndex() -> Int {
    return get(id: preferredNodeSizeId) as? Int ?? defaultNodeSize
}
/// - Note: returns current **diameter** of each node
let currentNodeSize: () -> CGFloat = {preferredNodeSizes[nodeSizeIndex()]}

let rectangularUiId = "rectangularUI"
let defaultUseRectangularUI = false
func shouldUseRectangularUI() -> Bool  {
    return get(id: rectangularUiId) as? Bool ?? defaultUseRectangularUI
}
let uiCornerRadius: CGFloat = 10

let showAlertsId = "showAlerts"
let shouldShowAlertsChangedNotification = Notification.Name(showAlertsId)
let defaultShowAlerts = true
func shouldShowAlerts() -> Bool  {
    return get(id: showAlertsId) as? Bool ?? defaultShowAlerts
}

let currentProfileId = "currentProfile"
let profileUpdatedNotification = Notification.Name(currentProfileId)
func currentProfileName() -> String {
    return get(id: currentProfileId) as? String ?? "#default"
}
func currentProfile() -> Profile {
    return Profile.load(currentProfileName())
}

let tableViewCellHeightId = "tableViewCellHeight"
let tableViewCellHeightUpdatedNotification = Notification.Name(tableViewCellHeightId)
let defaultTableViewCellHeight: Int = 70
func tableViewCellHeight() -> Int {
    return get(id: tableViewCellHeightId) as? Int ?? defaultTableViewCellHeight
}
