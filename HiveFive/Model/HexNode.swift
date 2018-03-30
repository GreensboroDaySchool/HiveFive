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
     Moves the piece to the designated destination and **properly** connect the piece with the hive,
     i.e., handles multi-directional reference bindings, unlike connect(with:) which only handles bidirectional binding
     */
    func move(to destination: Destination)

    /**
     Moves the piece by following a certain route
     (just for convenience, because route is eventually resolved to a destination)
     */
    func move(by route: Route)

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
     Note: disconnect with all neighbors, i.e. remove from the hive
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

    /**
     @return an array containing all the references to the connected pieces, including self; i.e. the entire hive
     */
    func connectedNodes() -> [HexNode]
}

extension HexNode {
    func canDisconnect() -> Bool {
        let neighbors = self.neighbors // make a copy of the neighbors
        // I am not using map, reduce, etc. because clarity outweighs conciseness
        self.disconnect() // temporarily disconnect with all neighbors

        let available = neighbors.available() // extract all available neighbors
        let connected = available.map {$0.node.numConnected()}
        var canMove = true
        for i in (0..<(connected.count - 1)) {
            // if number of connected pieces are not the same for each piece after the current
            // node is removed from the structure, then the structure is broken.
            if connected[i] != connected[i + 1] {
                canMove = false
            }
        }

        available.forEach {connect(with: $0.node, at: $0.dir.opposite())} // reconnect with neighbors
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

    func numConnected() -> Int {
        return connectedNodes().count
    }

    func connect(with node: HexNode, at dir: Direction) {
        assert(node.neighbors[dir] == nil)
        node.neighbors[dir] = self
        neighbors[dir.opposite()] = node
    }

    func disconnect() {
        neighbors.available().map {
            $0.node
        }.forEach {
            $0.disconnect(with: self)
        }
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
     @param pool: references to HexNodes that are already accounted for
     @return an integer representing the number of nodes
     */
    private func deriveConnectedNodes(_ pool: inout [HexNode]) -> Int {
        let pairs = neighbors.available() // get the nodes that are present
        if pool.contains(where: { $0 === self }) {return 0}
        pool.append(self) // self is accounted for, thus add to pool of accounted node such that it won't get counted again
        return pairs.map {$0.node}.filter { node in !pool.contains(where: { $0 === node })}
                .map {$0.deriveConnectedNodes(&pool)}
                .reduce(1) {$0 + $1}
    }

    func connectedNodes() -> [HexNode] {
        var pool = [HexNode]()
        let _ = deriveConnectedNodes(&pool)
        return pool
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
