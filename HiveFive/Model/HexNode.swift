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
      _____(up)_____
     /              \
 (upLeft)         (upRight)
   /     Oh Yeah!     \
   \      Hive        /
(downLeft)       (downRight)
     \____(down)____/
 */
struct Neighbors {
    var nodes = [HexNode?](repeating: nil, count: 6)
    private static let dirs: [Direction:Int] = [.up : 0, .upLeft : 1, .upRight : 2, .down : 3, .downLeft : 4, .downRight: 5]

    subscript(dir: Direction) -> HexNode? {
        get {
            return nodes[index(from: dir)]
        }
        set {
            nodes[index(from: dir)] = newValue
        }
    }

    private func index(from dir: Direction) -> Int {
        return Neighbors.dirs[dir]!
    }
    
    /**
     WARNING: does not check bounds
     */
    private func dir(from index: Int) -> Direction {
        return Neighbors.dirs.keys.map{$0}[index]
    }

    /**
     @return whether the references to each nodes of [self] is the same as that of [other]
     */
    func equals(_ other: Neighbors) -> Bool {
        return zip(nodes, other.nodes).reduce(true, { $0 && ($1.0 === $1.1) })
    }
    
    /**
     @return whether [nodes] contains reference to [node]
     returns nil if node is not in [nodes]; returns the Direction otherwise.
    */
    func contains(_ node: HexNode) -> Direction? {
        return nodes.enumerated().reduce(nil, {$1.element === node ? dir(from: $1.offset) : $0})
    }
}

/**
 This is the parent of Hive, QueenBee, Beetle, Grasshopper, Spider, and SoldierAnt, since all of them are pieces that together consist a hexagonal board.
 */
protocol HexNode: AnyObject {
    var neighbors: Neighbors { get }

    /**
    @return whether taking this node up will break the structure.
    */
    func canMove() -> Bool

    /**
    @return the number of nodes that are connected to the current node.
    */
    func numConnected() -> Int
    
    /**
    @return whether the node has [other] as an immediate neighbor
    */
    func hasNeighbor(_ other: HexNode) -> Direction?

    /**
    **Note**
    The implementation for this method should be different for each class that conforms to the HexNode protocol.
    For example, a beetle's route may cover a piece while a Queen's route may never overlap another piece.
    @return whether the piece can legally move to the designated location by following the instructions provided by route.
    */
    func canMove(to newPlace: Route) -> Bool

    /**
    moves the piece to the designated location
    */
    func move(to newPlace: Route)

    /**
    @return all possible locations in which the current node can move to by following a defined route.
    */
    func availableMoves() -> [Route]
}

extension HexNode {
    func canMove() -> Bool {
        neighbors.nodes.map({(node) -> Void in
//            if (node == nil) return
        })
        return false
    }
    
    func canMove(to newPlace: Route) -> Bool {
        return false
    }
    
    func move(to newPlace: Route){
        
    }
    
    func availableMoves() -> [Route] {
        return []
    }
}

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
}

/**
The direction in component of the Instruction
*/
enum Direction {
    case up, upLeft, upRight, down, downLeft, downRight
}

/**
Since everything is relative, there is no absolute location like in a x,y coordinate, only relative positions defined by Route;
Route defines where the location is by providing step-wise instructions. If Instruction is a vector, then Route is an array
of vectors that "directs" to the relative location.
*/
struct Route {
    var instructions: [Instruction]
}
