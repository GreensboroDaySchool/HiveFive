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
let handUpdateNotification = Notification.Name("handUpdated")
let didSelectNewNodeNotification = Notification.Name("selectedNewNode")
let didCancelNewPiece = Notification.Name("cancelledSelectedNewNode")
let didPlaceNewPiece = Notification.Name("placeSelectedNewPiece")
let requiresQueenNotification = Notification.Name(rawValue: "requireQueen")

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

let rectangularUiId = "rectangularUI"
let defaultUseRectangularUI = false
func shouldUseRectangularUI() -> Bool  {
    return get(id: rectangularUiId) as? Bool ?? defaultUseRectangularUI
}
let uiCornerRadius: CGFloat = 10
