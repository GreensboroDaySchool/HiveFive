/**
 *
 *  This file is part of Hive Five.
 *
 *  Hive Five is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Hive Five is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Hive Five.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import Foundation


public class Vec2D: CustomStringConvertible, Equatable {
    
    public static func ==(lhs: Vec2D, rhs: Vec2D) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    public var description: String {
        return "[\(self.x), \(self.y)]"
    }
    var x: Float
    var y: Float
    
    required public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
    
    
    
    convenience init() {
        self.init(x: 0, y: 0)
    }
    
    public func add(_ vec: Vec2D) -> Vec2D {
        self.x += vec.x
        self.y += vec.y
        return self
    }
    
    public func sub(_ vec: Vec2D) -> Vec2D {
        self.x -= vec.x
        self.y -= vec.y
        return self
    }
    
    public func mult(_ n: Float) -> Vec2D {
        self.x *= n
        self.y *= n
        return self
    }
    
    public func div(_ n: Float) -> Vec2D {
        self.x /= n
        self.y /= n
        return self
    }
    
    public func norm() -> Vec2D {
        let mag = self.mag()
        if mag != 0 && mag != 1.0 {
            return self.div(mag)
        }
        return self
    }
    
    public func mag() -> Float {
        return sqrt(self.x * self.x + self.y * self.y)
    }
    
    public func limit(_ n: Float) -> Vec2D {
        if self.mag() * self.mag() > n * n {
            return self.norm().mult(n)
        }
        return self
    }
    
    public func setMag(_ n: Float) -> Vec2D {
        return self.norm().mult(n)
    }
    
    public func rotate(_ angle: Float) -> Vec2D {
        let temp = self.x
        self.x = self.x * cos(angle) + self.y * sin(angle)
        self.y = temp * sin(angle) + self.y * cos(angle)
        return self
    }
    
    public func heading() -> Float {
        return atan2(self.y, self.x)
    }
    
    public func dist(_ vec: Vec2D) -> Float {
        let dx = self.x - vec.x
        let dy = self.y - vec.y
        return sqrt(dx * dx + dy * dy)
    }
    
    public func clone(_ vec: Vec2D) -> Vec2D {
        return Vec2D(point: self.cgPoint)
    }
    
    public class func angleBetween(_ vec1: Vec2D, _ vec2: Vec2D) -> Float {
        if vec1.x == 0.0 && vec1.y == 0.0 {
            return 0.0
        } else if vec2.x == 0.0 && vec2.y == 0.0 {
            return 0.0
        } else {
            let dot = vec1.x * vec2.x + vec1.y * vec2.y
            let amt = dot / (vec1.mag() * vec2.mag())
            return amt <= -1.0 ? Float.pi : (amt >= 1.0 ? 0.0 : acos(amt))
        }
    }
    
    public class func random() -> Vec2D {
        let seed1 = Float(arc4random_uniform(0x186A0)) - 0xC350
        let seed2 = Float(arc4random_uniform(0x186A0)) - 0xC350
        return Vec2D(x: seed1, y: seed2).norm()
    }
}

