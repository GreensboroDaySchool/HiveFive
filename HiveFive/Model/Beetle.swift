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
    
    override var identity: Identity {
        return .beetle
    }
    
    
    
    override func availableMoves() -> [Position] {
        var moves = [Position]()
        if (!canDisconnect()) {
            // if disconnecting the piece breaks the structure, then there are no available moves.
            return moves
        }
        
        let base = Hive.traverse(from: self, toward: .below)
        moves.append(contentsOf: base.neighbors.available()
            .filter{$0.dir.rawValue < 6}
            .map{getTopNode(of: $0.node)}
            .map{Position(node: $0, dir: .above)})
        let moreMoves = base === self ? oneStepMoves().map{Position.resolve(from: base, following: $0)} :
            Direction.xyDirections.map{(dir: $0, node: base.neighbors[$0])}
            .filter{$0.node == nil}
            .map{Position(node: base, dir: $0.dir)}
        moves.append(contentsOf: moreMoves)
        
        return moves
    }
    
    /**
     Beetle can get in anywhere! Yay beetle!
     */
    override func canGetIn(dir: Direction) -> Bool {
        return true
    }
    
    /**
     - Returns: The node at the top of the stack
     */
    private func getTopNode(of base: HexNode) -> HexNode {
        return Hive.traverse(from: base, toward: .above)
    }
}
