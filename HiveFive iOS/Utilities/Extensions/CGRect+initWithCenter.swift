//
//  Extension+CGRect.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import UIKit

extension CGRect {
    
    /**
     - Parameter center: The center point of the rectangle
     - Parameter size: The size of the rectangle
     */
    init(center: CGPoint, size: CGSize){
        self.init(
            origin: CGPoint(
                x: center.x - size.width / 2,
                y: center.y - size.height / 2
            ),
            size: size
        )
    }
    
    /**
     - Returns: Path for the inner circle that fits in the rectangle, with its center at the center of the rectangle
     */
    static func innerCircle(center: CGPoint, radius: CGFloat) -> UIBezierPath {
        return UIBezierPath(ovalIn: CGRect(center: center, size: CGSize(width: radius * 2, height: radius * 2)))
    }
}
