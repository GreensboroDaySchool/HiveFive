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

typealias LocalizedNode = (dir: Direction, node: HexNode?)

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
    var nodes = [HexNode?](repeating: nil, count: Direction.allDirections.count)

    subscript(dir: Direction) -> HexNode? {
        get {return nodes[dir.rawValue]}
        set {nodes[dir.rawValue] = newValue}
    }

    /**
     TODO: should Neighbors be immutable? Don't change it yet!
     @return the direction & node tuples in which there is a neighbor present.
     */
    func available() -> [(dir: Direction, node: HexNode)] {
        return nodes.enumerated().filter {$0.element != nil}
                .map {Direction(rawValue: $0.offset)!}
                .map {($0, self[$0]!)}
    }

    func adjacent(of dir: Direction) -> [LocalizedNode] {
        return dir.adjacent().map{($0, self[$0])}
    }

    /**
     Returns a new instance with [node] removed
     */
    func remove(_ node: HexNode) -> Neighbors {
        var copied = self
        guard let index = nodes.index(where: { $0 === node }) else {
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

extension Neighbors: Equatable, Hashable {
    var hashValue: Int {
        return nodes.filter({ $0 != nil }).reduce(0) {$0 ^ ObjectIdentifier($1!).hashValue}
    }

    static func ==(l: Neighbors, r: Neighbors) -> Bool {
        return l.equals(r)
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
    func canDisconnect() -> Bool

    /**
    @return the number of nodes that are connected to the current node, including the current node
    */
    func numConnected() -> Int

    /**
    @return whether the node has [other] as an immediate neighbor
    */
    func hasNeighbor(_ other: HexNode) -> Direction?

    /**
    @return whether the current node could move
    */
    func canMove() -> Bool

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
     Returns self for convenient chained modification.
     @return self
     */
    func removeAll(_ nodes: [HexNode]) -> HexNode

    /**
     Connect with another node at a certain neighboring position.
     The connection should be bidirectional, [dir] is the direction in relation to [node]
     */
    func connect(with node: HexNode, at dir: Direction)

    /**
     When the node disconnects from the structure, all references to it from the neighbors should be removed.
     Note: disconnect with all neighbors
     */
    func disconnect()

    /**
    Disconnect with the specified node
    Note: ONLY the specified node, does not include all the surrounding nodes
    */
    func disconnect(with node: HexNode);

    /**
    @return all possible locations in which the current node can move to by following a defined route.
    */
    func availableMoves() -> [Route]
}

extension HexNode {
    func canDisconnect() -> Bool {
        let neighbors = self.neighbors // make a copy of the neighbors
        // I am not using map, reduce, etc. because clarity outweighs conciseness
        self.disconnect() // temporarily disconnect with all neighbors

        let available = neighbors.available() // extract all available neighbors
        let connected = available.map{$0.node.numConnected()}
        var canMove = true
        for i in (0..<(connected.count - 1)) {
            // if number of connected pieces are not the same for each piece after the current
            // node is removed from the structure, then the structure is broken.
            if connected[i] != connected[i + 1] {
                canMove = false
            }
        }

        available.forEach{connect(with: $0.node, at: $0.dir.opposite())} // reconnect with neighbors
        return canMove
    }

    func canMove() -> Bool {
        return availableMoves().count > 0
    }

    /**
    TODO: implement
    */
    func canMove(to newPlace: Route) -> Bool {
        return false
    }

    /**
    TODO: implement
    */
    func move(to newPlace: Route) {

    }

    //Not the perfect solution... but it works like a charm!
    func numConnected() -> Int {
        let pool = [HexNode]()
        return numConnected(pool, 1) - numConnected(pool, 0)
    }

    func connect(with node: HexNode, at dir: Direction) {
        assert(node.neighbors[dir] == nil)
        node.neighbors[dir] = self
        neighbors[dir.opposite()] = node
    }

    func disconnect() {
        neighbors.available().map{$0.node}.forEach{$0.disconnect(with: self)}
    }

    func disconnect(with node: HexNode) {
        assert(node.neighbors.contains(self) != nil) // make sure that the reference exist
        node.remove(self)
        assert(node.neighbors.contains(self) == nil) // make sure the reference is removed
        assert(neighbors.contains(node) != nil)
        remove(node)
        assert(neighbors.contains(node) == nil)
    }

    /**
     @param pool: the HexNodes that are already accounted for
     @param i: 0 -> excluding leaf nodes; 1 -> leaf nodes + 2 * multi-directionally bounded nodes
     */
    private func numConnected(_ pool: [HexNode], _ i: Int) -> Int {
        var pool = pool // make pool mutable
        let pairs = neighbors.available() // get the nodes that are present
        let count = pairs.count // initial # of connected is the # of neighbors
        if pool.contains(where: { $0 === self }) {return 0}
        pool.append(self) // self is accounted for
        return count + pairs.map {$0.node}.filter { node in !pool.contains(where: { $0 === node })}
                .map {$0.numConnected(pool, i)}
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
    static let allDirections: [Direction] = (0..<8).map {Direction(rawValue: $0)!}
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
