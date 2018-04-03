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
class Spider: HexNode, InsectProtocol {
    var color: Color
    var insect: Insect = .spider
    
    required init(color: Color) {
        self.color = color
    }
    
    var neighbors = Neighbors()
    private let allowedMoves = 3
    
    func availableMoves() -> [Destination] {
        if (!canDisconnect()) {
            // if disconnecting the piece breaks the structure, then there are no available moves.
            return [Destination]()
        }
        
        // can't go back to previous location
        var traversed = [Destination]()
        let destinations = resolveDestinations(&traversed, allowedMoves)
        
        return destinations
    }
    
    private func resolveDestinations(_ traversed: inout [Destination], _ remaining: Int) -> [Destination] {
        registerTraversed(&traversed, self)
        let firstRoutes = oneStepMoves()
        let firstDestinations = firstRoutes.map{Destination.resolve(from: self, following: $0)}
        if remaining == 0 { // base case
            let location = neighbors.available()[0]
            return [Destination(node: location.node, dir: location.dir.opposite())]
        }
        return firstDestinations.filter{!traversed.contains($0)} // cannot go back to previous location
            .map{destination -> [Destination] in
                let neighbor = neighbors.available()[0]
                let anchor = Destination(node: neighbor.node, dir: neighbor.dir.opposite())
                self.move(to: destination) // move to next destination
                let destinations = resolveDestinations(&traversed, remaining - 1) // derive next step
                self.move(to: anchor) // move back to previous location
                return destinations
            }.flatMap{$0}
    }
    
    private func registerTraversed(_ traversed: inout [Destination], _ node: HexNode) {
        traversed.append(contentsOf: node.neighbors.available()
            .map{Destination(node: $0.node, dir: $0.dir.opposite())})
    }
}
