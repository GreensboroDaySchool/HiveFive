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
class Beetle: HexNode {
    var neighbors = Neighbors()
    
    func availableMoves() -> [Destination] {
        var moves = [Destination]()
        if (!canDisconnect()) {
            // if disconnecting the piece breaks the structure, then there are no available moves.
            return moves
        }
        
        let base = getBaseNode() ?? self
        moves.append(contentsOf: base.neighbors.available()
            .filter{$0.dir.rawValue < 6}
            .map{getTopNode(of: $0.node)}
            .map{Destination(node: $0, dir: .above)})
        let moreMoves = base === self ? oneStepMoves().map{Destination.resolve(from: base, following: $0)} :
            Direction.xyDirections.map{(dir: $0, node: base.neighbors[$0])}
            .filter{$0.node == nil}
            .map{Destination(node: base, dir: $0.dir)}
        moves.append(contentsOf: moreMoves)
        
        return moves
    }
    
    /**
     Beetle can get in anywhere! Yay beetle!
     */
    func canGetIn(dir: Direction) -> Bool {
        return true
    }
    
    /**
     - Returns: The node at the base level if it exists
     */
    private func getBaseNode() -> HexNode? {
        var path = Path(route: Route(directions: []), destination: self)
        while path.destination.neighbors[.below] != nil {
            let dest = path.destination.neighbors[.below]!
            path = Path(route: path.route.append([.below]), destination: dest)
        }
        return path.destination === self ? nil : path.destination
    }
    
    /**
     - Returns: The route to top of node
     */
    private func getTopNode(of base: HexNode) -> HexNode {
        var path = Path(route: Route(directions: []), destination: base)
        while path.destination.neighbors[.above] != nil {
            let dest = path.destination.neighbors[.above]!
            path = Path(route: path.route.append([.above]), destination: dest)
        }
        return path.destination
    }
}
