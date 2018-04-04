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
 This is the parent of Hive, QueenBee, Beetle, Grasshopper, Spider, and SoldierAnt,
 since all of them are pieces that together consist a hexagonal board, a hexagonal node with
 references to all the neighbors is the ideal structure.
 */
class HexNode: IdentityProtocol {
    var neighbors = Neighbors()
    var color: Color
    var identity: Identity {
        get {return .dummy}
    }

    /**
     Initializer must specify the color
     */
    init(color: Color) {
        self.color = color
    }
    
    /**
     For initialization of a dummy node
     */
    convenience init() {
        self.init(color: .black)
    }

    /**
     The implementation for this method should be different for each class that conforms to the HexNode protocol.
     For example, a beetle's route may cover a piece while a Queen's route may never overlap another piece.
     - Note: Empty implementation for HexNode because it is just a dummy.
     - Returns: All possible positions
     */
    func availableMoves() -> [Position] {
        return []
    }
    
    /**
     - Returns: Available moves within one step
     - Warning: This is a helper method for QueenBee::availableMoves, Beetle, and Spider, don't use it!
     */
    func oneStepMoves() -> [Route] {
        return neighbors.available().filter{$0.dir.rawValue < 6} // only horizontal nodes
            .map{($0.dir, $0.node.neighbors
                .adjacent(of: $0.dir.opposite())
                .filter{$0.node == nil} // ensure that the spot is vacant
                .map{$0.dir})}
            .map{(arg) -> [Route] in let (dir, dirs) = arg; return {
                dirs.map{Route(directions: [dir, $0])} // ensure that the current node can squeeze in
                    .filter{canGetIn(dir: $0.simplified().directions[0])}
            }()}
            .flatMap{$0} // if two different routes lead to the same position, keep only one.
            .filterDuplicates(isDuplicate: ==)
    }
    
    private func blockedDirections() -> [Direction] {
        return Direction.xyDirections.filter{neighbors[$0] != nil || !canGetIn(dir: $0)}
    }

    /**
     Derive the Path to every HexNode in the hive
     - Returns: The paths leading to the rest of the pieces in the hive
     */
    func derivePaths() -> [Path] {
        var paths = [Path(route: Route(directions: []), destination: self)]
        derivePaths(&paths, paths[0].route) // the root path is initially []
        paths.removeFirst()
        return paths
    }

    /**
     - Parameter paths: Derived paths
     - Parameter root: The root path
     - Returns: Paths to the rest of the nodes in the hive from the current node
     */
    private func derivePaths(_ paths: inout [Path], _ root: Route) {
        let available = neighbors.available().filter {
            pair in !paths.contains(where: { pair.node === $0.destination })
        }
        
        if available.count == 0 {return} // base case
        let newPaths = available.map{Path(route: root.append([$0.dir]), $0.node)}
        paths.append(contentsOf: newPaths)
        newPaths.forEach{$0.destination.derivePaths(&paths, $0.route)} // recursive call
    }

    /**
     - Returns: Whether the current node could move
     */
    func canMove() -> Bool {
        return canDisconnect() && availableMoves().count > 0
    }
    
    /**
     Checks if a certain movement is legal
     */
    func canMove(to position: Position) -> Bool {
        if !canDisconnect() {return false}
        let availableMoves = self.availableMoves()
        let preserved = neighbors
        move(to: position)
        var canMove = false
        for move in availableMoves {
            let contains = neighbors.available()
                .map{(node: $0.node, dir: $0.dir.opposite())}
                .contains{Position(node: $0.node, dir: $0.dir) == move}
            if contains {
                canMove = true
                break
            }
        }
        disconnect() //restore the status of the hive
        self.neighbors = preserved
        return canMove
    }

    /**
     Checks if a certain piece could get move in a certain direction.
     For example, if we have a node 'a', and 'a' has 'b' and 'c' at .upLeft, .upRight respectively,
     Then the piece cannot move in the direction of .up; except when the piece is Beetle.
     Beetle should override this method to always return true.
     */
    func canGetIn(dir: Direction) -> Bool {
        var canGetIn = false
        for node in neighbors.adjacent(of: dir).map({$0.node}) {
            canGetIn = canGetIn || node == nil
        }
        return canGetIn
    }

    /**
     Checks whether a piece can initially connect to the hive at the designated position
     */
    func canPlace(at position: Position) -> Bool {
        let node = position.node
        let dir = position.dir
        if node.neighbors[dir] != nil {return false}
        let preserved = neighbors // preserve neighbors
        move(to: position)
        let opponents = neighbors.available()
            .map{Hive.traverse(from: $0.node, toward: .up)}
            .filter{$0.color != color}
            .count
        disconnect()
        self.neighbors = preserved
        return opponents == 0
    }

    /**
     - Attention: This is for initially putting down a piece; does not recommend using like move(to:)
     - Note: Will first check if the placement is allowed/legal
     */
    func place(at position: Position) {
        if !canPlace(at: position) {fatalError("Cannot place at \(position)")}
        if neighbors.available().count != 0 {fatalError("Still connected to the hive. Please disconnect first")}
        move(to: position)
    }
    
    /**
     The behavior is the same as place(at:), this is for convenient access
     - Parameter node: The destination node
     - Parameter dir: The direction in relation to the destination node in which the current piece is to be placed at
     */
    func place(at dir: Direction, of node: HexNode) {
        place(at: Position(node: node, dir: dir))
    }

    /**
     Move the piece to the designated position and **properly** connect the piece with the hive,
     i.e., handles multi-directional reference bindings, unlike connect(with:) which only handles bidirectional binding
     - Warning: This method assumes that the position is a valid position and that the route taken is legal.
     Maybe a more intuitive description is that this method snaps a piece off the hive and squeeze it into the position
     - Attention: Use this method to MOVE the piece, not to initially PLACE a piece.
     */
    func move(to position: Position) {
        self.disconnect() // disconnect from the hive
        let node = position.node
        let dir = position.dir
        connect(with: node, at: dir) // connect with position node
        inferAdditionalConnections(from: node, at: dir) // make additional connections
    }
    
    /**
     The behavior is the same as move(to:), this overloading method is for convenient access.
     - Parameter node: The destination node.
     - Parameter dir: The direction in relation to the destination node in which the current piece is moving to.
     */
    func move(to dir: Direction, of node: HexNode) {
        move(to: Position(node: node, dir: dir))
    }
    
    private func inferAdditionalConnections(from node: HexNode, at dir: Direction) {
        let pairs = Direction.allDirections.filter{$0 != dir.opposite()}
            .map{(dir: $0, trans: $0.translation())}
        // directions in which additional connections might need to be made
        
        derivePaths().map {path -> Position? in //make additional connections to complete the hive
            let filtered = pairs.filter {path.route.translation == $0.trans}
            return filtered.count == 0 ? nil :
                Position(node: path.destination, dir: filtered[0].dir)
            }.filter{$0 != nil}
            .map{$0!}
            .forEach{$0.node.connect(with: self, at: $0.dir)}
    }

    /**
     Moves the piece by following a certain route
     (just for convenience, because route is eventually resolved to a position)
     */
    func move(by route: Route) {
        move(to: Position.resolve(from: self, following: route))
    }

    /**
     - Returns: Whe number of nodes that are connected to the current node, including the current node
     */
    func numConnected() -> Int {
        return connectedNodes().count
    }

    /**
     Connect bidirectionally with another node at a certain neighboring position.
     - Attention: Does not connect properly with the entire hive structure; only a bidirectional reference binding.
     - Parameter node: The node in which a bidirectional connection is to be established
     - Parameter dir: The direction in relation to the node to be connected with
     */
    func connect(with node: HexNode, at dir: Direction) {
        assert(node.neighbors[dir] == nil)
        node.neighbors[dir] = self
        neighbors[dir.opposite()] = node
    }

    /**
     - Returns: Whether taking this node up will break the structure.
     */
    func canDisconnect() -> Bool {
        if self.neighbors[.above] != nil {return false} // little fucking beetle...
        let neighbors = self.neighbors // make a copy of the neighbors
        self.disconnect() // temporarily disconnect with all neighbors

        let available = neighbors.available() // extract all available neighbors
        let connected = available.map {$0.node.numConnected()}
        var canMove = true
        for i in (0..<(connected.count - 1)) {
            // if number of connected pieces are not the same for each piece after the current
            // node is removed from the structure, then the structure is broken.
            if connected[i] != connected[i + 1] {
                canMove = false
                break
            }
        }

        available.forEach {connect(with: $0.node, at: $0.dir.opposite())} // reconnect with neighbors
        return canMove
    }

    /**
     When the node disconnects from the structure, all references to it from the neighbors should be removed.
     - Attention: Disconnect with all neighbors, i.e. remove from the hive
     */
    func disconnect() {
        neighbors.available().map {$0.node}.forEach {$0.disconnect(with: self)}
    }

    /**
     Disconnect with the specified node
     - Attention: Disconnect ONLY with the specified node, does not disconnect with all the surrounding nodes
     - Parameter node: The node with which the bidirectional connection is to be broken
     */
    func disconnect(with node: HexNode) {
        node.remove(self)
        assert(node.neighbors.contains(self) == nil) // make sure the reference is removed
        remove(node)
        assert(neighbors.contains(node) == nil)
    }

    /**
     - Parameter pool: References to HexNodes that are already accounted for
     - Returns: An integer representing the number of nodesincluding self
     */
    private func deriveConnectedNodes(_ pool: inout [HexNode]) -> Int {
        let pairs = neighbors.available() // neighbors that are present
        if pool.contains(where: { $0 === self }) {return 0}
        pool.append(self) // add self to pool of accounted node such that it won't get counted again
        return pairs.map {$0.node}.filter { node in !pool.contains(where: { $0 === node })}
                .map {$0.deriveConnectedNodes(&pool)}
                .reduce(1) {$0 + $1}
    }

    /**
     - Returns: An array containing all the references to the connected pieces, including self; i.e. the entire hive
     */
    func connectedNodes() -> [HexNode] {
        var pool = [HexNode]()
        let _ = deriveConnectedNodes(&pool)
        return pool
    }

    /**
     Remove the reference to a specific node from its neighbors
     */
    func remove(_ node: HexNode) {
        neighbors = neighbors.remove(node)
    }

    /**
     Returns self for convenient chained modification.
     - Parameter nodes: references to the nodes to be removed
     - Returns: self
     */
    func removeAll(_ nodes: [HexNode]) -> HexNode {
        nodes.forEach(remove)
        return self
    }

    /**
     - Returns: Whether the node has [other] as an immediate neighbor
     */
    func hasNeighbor(_ other: HexNode) -> Direction? {
        return neighbors.contains(other)
    }
}

enum Color {
    case black, white
}
