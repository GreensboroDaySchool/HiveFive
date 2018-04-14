//
//  Extension+CGPoint.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    
    /**
     Equivalent representation of the point with Vec2D
     */
    var vec2D: Vec2D {
        return Vec2D(point: self)
    }
    
    /**
     Translate by doing self.x + x, self.y + y
     - Parameter x: Offset x
     - Parameter y: Offset y
     - Returns: A new CGPoint instance that is translated by the offset.
     */
    func translate(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y);
    }
    
    /**
     - Parameter point: The CGPoint to which the translation is based on.
     - Returns: A new CGPoint instance that is translated by the coordinate represented by the given point/
     */
    func translate(by point: CGPoint) -> CGPoint {
        return self.translate(point.x, point.y)
    }
    
    /**
     - Parameter other: Another point
     - Returns: Distance from self to the given point
     */
    func dist(to other: CGPoint) -> CGFloat {
        return CGFloat(vec2D.dist(other.vec2D))
    }
    
    /**
     - Parameter from: First point.
     - Parameter to: Second point.
     - Returns: The midpoint between the first point and the second point.
     */
    static func midpoint(from p1: CGPoint, to p2: CGPoint) -> CGPoint{
        return CGPoint(x: (p2.x+p1.x)/2, y: (p2.y+p1.y)/2)
    }
    
    /**
     Equivalent to translate(by:)
     */
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    /**
     Opposite of translate(by:)
     */
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    /**
     - Returns: CGPoint with y coordinate flipped
     */
    func flipY() -> CGPoint {
        return CGPoint(x: x, y: -y)
    }
    
    /**
     - Returns: CGPoint with x coordinate flipped
     */
    func flipX() -> CGPoint {
        return CGPoint(x: -x, y: y)
    }
    
    /**
     - Returns: CGPoint with x, y coordinates flipped
     */
    func flip() -> CGPoint {
        return CGPoint(x: -x, y: -y)
    }
}
