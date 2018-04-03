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
class SoldierAnt: HexNode, InsectProtocol {
    var neighbors = Neighbors()
    var color: Color
    var insect: Insect = .soldierAnt
    
    required init(color: Color) {
        self.color = color
    }

    func availableMoves() -> [Destination] {
        if (!canDisconnect()) {
            // if disconnecting the piece breaks the structure, then there are no available moves.
            return [Destination]()
        }

        // can go to anywhere outside the hive, can't squeeze into tiny openings though
        var traversed = [Destination]()
        var destinations = [Destination]()
        resolveDestinations(&traversed, &destinations)
        return destinations.filterDuplicates(isDuplicate: ==) // will do for now
    }

    private func resolveDestinations(_ traversed: inout [Destination], _ destinations: inout [Destination]) {
        traversed.append(contentsOf: neighbors.available()
            .map{Destination(node: $0.node, dir: $0.dir.opposite())})
        let firstRoutes = oneStepMoves()
        let firstDestinations = firstRoutes.map{Destination.resolve(from: self, following: $0)}
        let filtered = firstDestinations.filter{!traversed.contains($0)} 
        if filtered.count == 0 { // base case
            return
        }
        destinations.append(contentsOf: filtered) // add current destinations
        filtered.forEach{destination in
            let neighbor = neighbors.available()[0]
            let anchor = Destination(node: neighbor.node, dir: neighbor.dir.opposite())
            self.move(to: destination) // move to next destination
            resolveDestinations(&traversed, &destinations) // derive next step
            self.move(to: anchor) // move back to previous location
        }
    }
}
