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
class QueenBee: HexNode {
    var neighbors = Neighbors()

    func availableMoves() -> [Route] {
        if (!canDisconnect()) {
            // if disconnecting the piece breaks the structure, then there are no available moves.
            return [Route]()
        }
        return neighbors.available() // worked on the first try!
            .map{($0.dir, $0.node.neighbors
                .adjacent(of: $0.dir.opposite())
                .filter{$0.node == nil}
                .map{$0.dir})}
            .map{(arg) -> [Route] in let (dir, dirs) = arg; return {
                dirs.map{Route(directions: [dir, $0])}
                }()}
            .flatMap{$0}
    }
}
