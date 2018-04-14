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
class SoldierAnt: HexNode {
    override var identity: Identity {
        return .soldierAnt
    }

    override func availableMoves() -> [Position] {
        if (!canDisconnect()) {
            // if disconnecting the piece breaks the structure, then there are no available moves.
            return [Position]()
        }

        // can go to anywhere outside the hive, can't squeeze into tiny openings though
        var traversed = [Position]()
        var destinations = [Position]()
        resolvePositions(&traversed, &destinations)
        return destinations.filterDuplicates(isDuplicate: ==) // will do for now
    }

    private func resolvePositions(_ traversed: inout [Position], _ destinations: inout [Position]) {
        traversed.append(contentsOf: neighbors.available()
            .map{Position(node: $0.node, dir: $0.dir.opposite())})
        let firstRoutes = oneStepMoves()
        let firstPositions = firstRoutes.map{Position.resolve(from: self, following: $0)}
        let filtered = firstPositions.filter{!traversed.contains($0)}
        if filtered.count == 0 { // base case
            return
        }
        destinations.append(contentsOf: filtered) // add current destinations
        filtered.forEach{destination in
            let neighbor = neighbors.available()[0]
            let anchor = Position(node: neighbor.node, dir: neighbor.dir.opposite())
            self.move(to: destination) // move to next destination
            resolvePositions(&traversed, &destinations) // derive next step
            self.move(to: anchor) // move back to previous location
        }
    }
}
