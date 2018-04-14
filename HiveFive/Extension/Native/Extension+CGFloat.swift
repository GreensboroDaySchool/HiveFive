//
//  Extension+CGFloat.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
    
    /**
     This is sufficient for most scenarios!
     - Returns: A random CGFloat from 0 to 1 using the arc4 random number generation algorithm
     */
    static func random() -> CGFloat {
        return CGFloat(Double.random())
    }
    
    /**
     - Parameter min: A CGFloat
     - Parameter max: Another CGFloat
     - Note: Automatically swaps min and max if max is larger than min.
     - Returns: A random CGFloat between min and max.
     */
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(Double.random(min: Double(min), max: Double(max)))
    }
    
}
