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
    static let allDirections: [Direction] = (0..<6).map {Direction(rawValue: $0)!}

    var nodes = [HexNode?](repeating: nil, count: allDirections.count)

    subscript(dir: Direction) -> HexNode? {
        get {return nodes[dir.rawValue]}
        set {nodes[dir.rawValue] = newValue}
    }

    /**
     TODO: should Neighbors be immutable? Don't change it yet!
     @return the direction & node tuples in which there is a neighbor present.
     */
    func available() -> [(dir: Direction, node: HexNode)] {
        return nodes.enumerated().filter{$0.element != nil}
            .map{Direction(rawValue: $0.offset)!}
            .map{($0, self[$0]!)}
    }

    /**
     Returns a new instance with [node] removed
     */
    func remove(_ node: HexNode) -> Neighbors {
        var copied = self
        guard let index = nodes.index(where: {$0 === node}) else {
            return copied
        }
        copied.nodes[index] = nil
        return copied
    }

    func removeAll(_ nodes: [HexNode]) -> Neighbors {
        var copied = self
        for node in nodes {
            copied = copied.remove(node) // not very efficient, but suffice for now!
        }
        return copied
    }

    /**
     @return whether the references to each nodes of [self] is the same as that of [other]
     */
    func equals(_ other: Neighbors) -> Bool {
        return zip(nodes, other.nodes).reduce(true) {$0 && ($1.0 === $1.1)}
    }

    /**
     @return whether [nodes] contains reference to [node]
     returns nil if node is not in [nodes]; returns the Direction otherwise.
    */
    func contains(_ node: HexNode) -> Direction? {
        return nodes.enumerated().reduce(nil) {$1.element === node ? Direction(rawValue: $1.offset) : $0}
    }
}

/**
 This is the parent of Hive, QueenBee, Beetle, Grasshopper, Spider, and SoldierAnt, since all of them are pieces that together consist a hexagonal board.
 */
protocol HexNode: AnyObject {
    var neighbors: Neighbors { get set }

    /**
    @return whether taking this node up will break the structure.
    */
    func canMove() -> Bool

    /**
    @return the number of nodes that are connected to the current node, including the current node
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
    Moves the piece to the designated location
    */
    func move(to newPlace: Route)

    /**
     Remove the reference to a specific node from its neighbors
     */
    func remove(_ node: HexNode)

    /**
     Connect with another node at a certain neighboring position.
     The connection should be bidirectional, [dir] is the direction in relation to [node]
     */
    func connect(with node: HexNode, at dir: Direction)

    /**
     When the node disconnects from the structure, all references to it from the neighbors should be removed.
     */
    func disconnect()

    /**
     Returns self for convenient chained modification.
     */
    func removeAll(_ nodes: [HexNode]) -> HexNode

    /**
    @return all possible locations in which the current node can move to by following a defined route.
    */
    func availableMoves() -> [Route]
}

extension HexNode {
    func canMove() -> Bool {
        var neighbors = self.neighbors // make a copy of the neighbors

        // I am not using map, reduce, etc. because clarity outweighs conciseness
        for (i,neighbor) in neighbors.nodes.enumerated() {
            if neighbor == nil {continue}
            let dir = neighbor!.neighbors.contains(self)
            if (dir != nil) {
                //potential bug, neighbors might get copied

                 neighbors.nodes[i]!.neighbors[dir!] = nil // remove reference to self
            }
        }
        var connected =  neighbors.nodes.filter{$0 != nil}.map{$0!.numConnected()}
        if (connected.count == 1) {return true} // only two pieces on the board, one of which can always move.
        for i in (0..<(connected.count - 1)) {
            // if number of connected pieces are not the same for each piece, then the structure is broken.
            if connected[i] != connected[i+1] {
                return false
            }
        }
        return true
    }

    func canMove(to newPlace: Route) -> Bool {
        return false
    }

    func move(to newPlace: Route) {

    }

    func availableMoves() -> [Route] {
        return []
    }

    //Not the perfect solution... but it works like a charm!
    func numConnected() -> Int {
        let pool = [HexNode]()
        return numConnected(pool, 1) - numConnected(pool, 0)
    }

    //TODO: check to make sure that the connection could be made, i.e. neighbors[dir] is empty
    func connect(with node: HexNode, at dir: Direction) {
        node.neighbors[dir] = self
        neighbors[dir.opposite()] = node
    }

    //TODO: implement
    func disconnect() {
        fatalError("not implemented")
    }

    /**
     @param pool: the HexNodes that are already accounted for
     @param i: 0 -> excluding leaf nodes; 1 -> leaf nodes + 2 * multi-directionally bounded nodes
     */
    private func numConnected(_ pool: [HexNode], _ i: Int) -> Int {
        var pool = pool // make pool mutable
        let pairs = neighbors.available() // get the nodes that are present
        let count = pairs.count // initial # of connected is the # of neighbors
        if pool.contains(where: {$0 === self}) {return 0}
        pool.append(self) // self is accounted for
        return count + pairs.map{$0.node}.filter{node in !pool.contains(where: {$0 === node})}
                .map{$0.numConnected(pool, i)}
                .reduce(i) {$0 + $1}
    }

    func remove(_ node: HexNode) {
        neighbors = neighbors.remove(node)
    }

    func removeAll(_ nodes: [HexNode]) -> HexNode {
        nodes.forEach(remove)
        return self
    }

    func hasNeighbor(_ other: HexNode) -> Direction? {
        return neighbors.contains(other)
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
enum Direction: Int {
    case up = 0, upLeft, upRight, down, downLeft, downRight

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
        }
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
