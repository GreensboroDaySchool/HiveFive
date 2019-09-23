//
//  Extension+Double.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

public extension Double {
    
    /**
     This is sufficient for most scenarios!
     - Returns: A random double from 0 to 1 using the arc4 random number generation algorithm
     */
    static func random() -> Double {
        let arc4Max: UInt32 = 4294967295
        return Double(arc4random()) / Double(arc4Max)
    }
    
    /**
     - Parameter min: A double
     - Parameter max: Another double
     - Note: Automatically swaps min and max if max is larger than min.
     - Returns: A random double between min and max.
     */
    static func random(min: Double, max: Double) -> Double {
        var min = min, max = max
        if (max < min) {swap(&min, &max)}
        return min + random() * (max - min)
    }
    
    /**
     Swaps two doubles - for convenience.
     */
    private static func swap(_ a: inout Double, _ b: inout Double){
        let temp = a
        a = b
        b = temp
    }
    
    /**
     Maps a given value within a given range to another range
     - Parameter i: The value to be mapped
     - Parameter v1: Min value of first range
     - Parameter v2: Max value of first range
     - Parameter t1: Min value of second range
     - Parameter t2: Max value of second range
     - Returns: The mapped double value
     */
    static func map(_ i: Double, _ v1: Double, _ v2: Double, _ t1: Double, _ t2: Double) -> Double {
        return (i - v1) / (v2 - v1) * (t2 - t1) + t1
    }
    
}
