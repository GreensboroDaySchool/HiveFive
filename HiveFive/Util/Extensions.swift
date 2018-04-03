//
//  Extensions.swift
//  Hive Five
//
//  Created by Jiachen Ren on 3/31/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
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

//Various extensions developed by Jiachen Ren. Migrated from Hashlife project

extension CGPoint {
    var vec2D: Vec2D {
        return Vec2D(point: self)
    }
    
    func translate(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y);
    }
    
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
    
    static func midpoint(from p1: CGPoint, to p2: CGPoint) -> CGPoint{
        return CGPoint(x: (p2.x+p1.x)/2, y: (p2.y+p1.y)/2)
    }
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}



extension CGFloat {
    static func random() -> CGFloat {
        let dividingConst: UInt32 = 4294967295
        return CGFloat(arc4random()) / CGFloat(dividingConst)
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        var min = min, max = max
        if (max < min) {swap(&min, &max)}
        return min + random() * (max - min)
    }
    
    private static func swap(_ a: inout CGFloat, _ b: inout CGFloat){
        let temp = a
        a = b
        b = temp
    }
}

extension Decimal {
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

//Modified from https://stackoverflow.com/questions/28644311/how-to-get-the-rgb-code-int-from-an-uicolor-in-swift
extension UIColor {
    func rgb() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (r: red, g: green, b: blue, a: alpha)
    }
}


public class Utils {
    public static func map(_ i: CGFloat, _ v1: CGFloat, _ v2: CGFloat, _ t1: CGFloat, _ t2: CGFloat) -> CGFloat {
        return (i - v1) / (v2 - v1) * (t2 - t1) + t1
    }
    
    public static func loadFile(name: String, extension ext: String) -> String? {
        let path = Bundle.main.path(forResource: name, ofType: ext, inDirectory: nil)
        let url = URL(fileURLWithPath: path!)
        let data = try? Data(contentsOf: url)
        return String(data: data!, encoding: .utf8)
    }
}

extension CGContext {
    static func point(at point: CGPoint, strokeWeight: CGFloat){
        let circle = UIBezierPath(ovalIn: CGRect(center: point, size: CGSize(width: strokeWeight, height: strokeWeight)))
        circle.fill()
    }
    static func fillCircle(center: CGPoint, radius: CGFloat) {
        let circle = UIBezierPath(ovalIn: CGRect(center: center, size: CGSize(width: radius * 2, height: radius * 2)))
        circle.fill()
    }
}

extension CGRect {
    init(center: CGPoint, size: CGSize){
        self.init(
            origin: CGPoint(
                x: center.x - size.width / 2,
                y: center.y - size.height / 2
            ),
            size: size
        )
    }
    static func fillCircle(center: CGPoint, radius: CGFloat) {
        let circle = UIBezierPath(ovalIn: CGRect(center: center, size: CGSize(width: radius * 2, height: radius * 2)))
        circle.fill()
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
