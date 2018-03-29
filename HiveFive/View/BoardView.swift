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

import UIKit

let nodeRadius = 16.0

fileprivate typealias BoardCoordinationPair = (node: HexNode, coordination: CGPoint)

class BoardView: UIView {
    var hive: Hive?
    
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
}

extension BoardView {
    fileprivate func layoutHive() -> [BoardCoordinationPair]? {
        guard let hive = hive else { return nil }
        var fifo = [HexNode]() //A queue that stores all the nodes that need to be processed
        var processed = [BoardCoordinationPair]()
        
        var current = BoardCoordinationPair(hive.root, CGPoint(x: 0, y: 0))
        processed.append(current)
        
        while(fifo.count > 0){
            let current = fifo.removeFirst()
            
        }
        
        return processed
    }
}
