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
class Spider: HexNode {
    override var identity: Identity {
        return .spider
    }
    
    private let allowedMoves = 3
    
    override func availableMoves() -> [Position] {
        if (!canDisconnect()) {
            // if disconnecting the piece breaks the structure, then there are no available moves.
            return [Position]()
        }
        
        // can't go back to previous location
        var traversed = [Position]()
        let destinations = resolvePositions(&traversed, allowedMoves)
        
        return destinations
    }
    
    private func resolvePositions(_ traversed: inout [Position], _ remaining: Int) -> [Position] {
        registerTraversed(&traversed, self)
        let firstRoutes = oneStepMoves()
        let firstPositions = firstRoutes.map{Position.resolve(from: self, following: $0)}
        if remaining == 0 { // base case
            let location = neighbors.available()[0]
            return [Position(node: location.node, dir: location.dir.opposite())]
        }
        return firstPositions.filter{!traversed.contains($0)} // cannot go back to previous location
            .map{position -> [Position] in
                let neighbor = neighbors.available()[0]
                let anchor = Position(node: neighbor.node, dir: neighbor.dir.opposite())
                self.move(to: position) // move to next destination
                let positions = resolvePositions(&traversed, remaining - 1) // derive next step
                self.move(to: anchor) // move back to previous location
                return positions
            }.flatMap{$0}
    }
    
    private func registerTraversed(_ traversed: inout [Position], _ node: HexNode) {
        traversed.append(contentsOf: node.neighbors.available()
            .map{Position(node: $0.node, dir: $0.dir.opposite())})
    }
}
