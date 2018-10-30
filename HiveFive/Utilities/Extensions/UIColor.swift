//
//  Extension+UIColor.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import UIKit

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
