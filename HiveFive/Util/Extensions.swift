//
//  Extensions.swift
//  Hive Five
//
//  Created by Jiachen Ren on 3/31/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension Array {
    /**
     Filters the array according to a given condition
     - Parameter isDuplicate: Condition that is true when the two elements are duplicates
     - Return: The filtered Array containing no duplicates by filtering by given conditions
     */
    func filterDuplicates(isDuplicate: @escaping (_ lhs: Element, _ rhs: Element) -> Bool) -> [Element]{
        var results = [Element]()
        forEach { element in
            let existingElements = results.filter {isDuplicate(element, $0)}
            if existingElements.count == 0 {
                results.append(element)
            }
        }
        return results
    }
}

/*
 Various extensions developed by Jiachen Ren. Migrated from Hashlife project
 */

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
        return vec2D.dist(other.vec2D)
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

extension Double {
    
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

extension Decimal {
    
    /**
     IntValue of the Decimal - for convenience.
     */
    var intValue: Int {
        return NSDecimalNumber(decimal: self).intValue
    }
}

extension Date {
    public var millisecondsSince1970: Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}


extension UIColor {
    
    /**
     Decomposes UIColor to its RGBA components
     */
    var rgbColor: RGBColor {
        get {
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return RGBColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
    
    /**
     Decomposes UIColor to its HSBA components
     */
    var hsbColor: HSBColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return HSBColor(hue: h, saturation: s, brightness: b, alpha: a)
    }
    
    /**
     Holds the CGFloat values of HSBA components of a color
     */
    public struct HSBColor {
        var hue: CGFloat
        var saturation: CGFloat
        var brightness: CGFloat
        var alpha: CGFloat
        
        var uiColor: UIColor {
            get {
                return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
            }
        }
    }

    /**
     Holds the CGFloat values of RGBA components of a color
     */
    public struct RGBColor {
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        var alpha: CGFloat
        
        var uiColor: UIColor {
            get {
                return UIColor(red: red, green: green, blue: blue, alpha: alpha)
            }
        }
    }
}

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

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}

class CoreData {
    static var context: NSManagedObjectContext = {
        return (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext
    }()
    
    /**
     - Parameter entity: The name of the entity to be deleted.
     */
    static func delete(entity: String) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let _ = try? CoreData.context.execute(request)
    }
}

extension UIGestureRecognizer {
    
    /**
     A little trick for cancelling detected gesture.
     */
    func cancel() {
        isEnabled = false
        isEnabled = true
    }
}

extension Dictionary {
    var keyValuePairs: [(key: Key,value: Value)] {
        get {
            return zip(self.keys,self.values).map{(key: $0.0, value: $0.1)}
        }
    }
}
