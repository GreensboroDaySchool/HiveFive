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
class Grasshopper: HexNode, InsectProtocol {
    var neighbors = Neighbors()
    var color: Color
    var insect: Insect = .grasshopper
    
    required init(color: Color) {
        self.color = color
    }
    
    
    func availableMoves() -> [Position] {
        if (!canDisconnect()) {
            // if disconnecting the piece breaks the structure, then there are no available moves.
            return [Position]()
        }
        
        return Direction.xyDirections
            .map{explore(dir: $0)}
            .filter{$0 != nil}
            .map{$0!}
    }
    
    private func explore(dir: Direction) -> Position? {
        guard var node = neighbors[dir] else {
            return nil
        }
        while node.neighbors[dir] != nil {
            node = node.neighbors[dir]!
        }
        return Position(node: node, dir: dir)
    }
}
