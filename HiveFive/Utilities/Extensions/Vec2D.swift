//
//  Extension+Vec2D.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import UIKit
import Hive5Common

extension Vec2D {
    
    var cgPoint: CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
    
    convenience init(point: CGPoint) {
        self.init(x: Float(point.x), y: Float(point.y))
    }
}
