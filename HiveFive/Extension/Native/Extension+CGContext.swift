//
//  Extension+CGContext.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import UIKit

extension CGContext {
    /**
     Fills a circle at a given coordinate with designated radius
     */
    static func fillCircle(center: CGPoint, radius: CGFloat) {
        let circle = UIBezierPath(ovalIn: CGRect(center: center, size: CGSize(width: radius * 2, height: radius * 2)))
        circle.fill()
    }
    
    /**
     Strokes a circle at a given coordinate with designated radius
     */
    static func strokeCircle(center: CGPoint, radius: CGFloat) {
        let circle = UIBezierPath(ovalIn: CGRect(center: center, size: CGSize(width: radius * 2, height: radius * 2)))
        circle.stroke()
    }
}
