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

/**
 A piece-wise instruction. For example, Instruction(3,.upLeft) would mean move upLeft 3 times
 Imagine an Instruction instance like a vector that has magnitude and direction, then [dir] defines
 the direction while [num] defines the magnitude.
 */
struct Instruction {
    ///the number of nodes to move in the specified direction
    let num: Int
    
    ///the direction in relation to the current node
    let dir: Direction
    
    /**
     Apply the instruction on [node] to get to the next node
     Note: the method assumes that the instruction is valid.
     */
    func apply(to node: HexNode) -> HexNode {
        var result = node
        for _ in (0..<num) {
            result = result.neighbors[dir]!
        }
        return result
    }
}

/**
       _____(up)_____
      /              \
  (upLeft)         (upRight)
    /     Oh Yeah!     \
    \      Hive        /
 (downLeft)       (downRight)
      \____(down)____/
 */
enum Direction: Int {
    static let allDirections: [Direction] = (0..<8).map {
        Direction(rawValue: $0)!
    }
    //Horizontal locations
    case up = 0, upRight, downRight, down, downLeft, upLeft
    
    //Vertical locations, the top node is always connected to the others (with a below pointed to the node below)
    //The node being suppressed should have all horizontal references set to nil
    case below, above
    
    /**
     I know there's a better way, but that would simply take too much time!
     @return the opposite direction.
     */
    func opposite() -> Direction {
        switch self {
        case .up: return .down
        case .upLeft: return .downRight
        case .upRight: return .downLeft
        case .down: return .up
        case .downLeft: return .upRight
        case .downRight: return .upLeft
        case .below: return .above
        case .above: return .below
        }
    }
    
    func horizontalFlip() -> Direction {
        switch self {
        case .upRight: return .upLeft
        case .upLeft: return .upRight
        case .downLeft: return .downRight
        case .downRight: return .downLeft
        default: fatalError("horizontalFlip() only applies to slanted directions")
        }
    }
    
    /**
     e.g. Direction.up.adjacent() returns [.upLeft, .upRight]
     Note: this method is not intended for down/below.
     @return the adjacent directions of a certain direction
     use adjacent()[0] to get the next element counter-clockwise,
     use adjacent()[1] to get the next element clockwise
     */
    func adjacent() -> [Direction] {
        assert(self.rawValue < 6) // this method is only intended for horizontal directions
        var adjacent = [Direction]()
        let count = 6 // there are 6 horizontal directions in total
        let value = rawValue + count
        adjacent.append(Direction(rawValue: (value - 1) % count)!)
        adjacent.append(Direction(rawValue: (value + 1) % count)!)
        return adjacent
    }
}

/**
 Since everything is relative, there is no absolute location like in a x,y coordinate, only relative positions defined by Route;
 Route defines where the location is by providing step-wise instructions. If Instruction is a vector, then Route is an array
 of vectors that "directs" to the relative location.
 */
struct Route {
    var instructions: [Instruction]
}

/**
 Destination defines the destination that a piece would eventually arrive by following a given route.
 */
struct Destination {
    var node: HexNode // b/c the "one hive policy", the destination has to be the vacant locations around a node
    var dir: Direction // the direction of the vacant location
    
    /**
     TODO: debug
     Resolve the destination by following a given Route.
     @param start: the starting node of the route
     @param route: the route to be followed to get to the destination
     @return the resolved destination
     */
    static func resolve(from start: HexNode, following route: Route) -> Destination {
        //        let nodes = start.connectedNodes() // this can be optimized -- only resolve the hive structure when pieces are moved/added
        var current = start;
        for q in 0..<(route.instructions.count - 1) {
            let instruction = route.instructions[q]
            current = instruction.apply(to: current)
        }
        let last = route.instructions.last!
        // the last step of the last instruction represents the vacant location
        for _ in 0..<(last.num - 1) {
            current = current.neighbors[last.dir]!
        }
        
        return Destination(node: current, dir: last.dir)
    }
}
