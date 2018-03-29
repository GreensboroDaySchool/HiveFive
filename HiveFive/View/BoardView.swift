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

let nodeRadius: CGFloat = 16.0

//This is used to store the processed coordination
fileprivate typealias BoardCoordinationPair = (node: HexNode, coordination: CGPoint)
//This is used to queue the pair into the line for later processes
fileprivate typealias QueuedNodePair = (node: HexNode, sourceCoordination: CGPoint, sourceDirection: Direction)

class BoardView: UIView {
    var hive: Hive?
    
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
}

extension BoardView {
    fileprivate func layoutHive() -> [BoardCoordinationPair]? {
        //Only layout when there is a hive
        guard let hive = hive else { return nil }
        var fifo = [QueuedNodePair]() //A queue that stores all the nodes that need to be processed
        var processed = [BoardCoordinationPair]()
        
        //Assign (0, 0) to the root node
        processed.append(BoardCoordinationPair(hive.root, CGPoint(x: 0, y: 0)))
        
        fifo.append(contentsOf: processed.first!
            .node
            .neighbors
            .nodes//all the neighboring nodes of the root cell
            .enumerated()
            .filter({ $0.element !== nil })//Filter out nil nodes
            .map({ QueuedNodePair($0.element!, CGPoint(x: 0, y: 0), Neighbors.allDirections[$0.offset]) }))//map to our QueuedNodePair tuple
        
        //Transform node locations from the inside to the outside
        while(fifo.count > 0){
            let current = fifo.removeFirst()
            var transformed = current.sourceCoordination
            
            //Left and Right (x-axis) are different from up/down (simpler)
            //thus using two switch statement to transform coordinations
            switch(current.sourceDirection){
            case .upRight, .downRight: transformed.x += nodeRadius * 0.5
            case .upLeft, .downLeft: transformed.x -= nodeRadius * 0.5
            default: break
            }
            
            switch(current.sourceDirection){
            case .upRight, .upLeft: transformed.y += nodeRadius * sin(.pi / 3)
            case .downLeft, .downRight: transformed.y -= nodeRadius * sin(.pi / 3)
            case .up: transformed.y += nodeRadius * sin(.pi / 3) * 2
            case .down: transformed.y -= nodeRadius * sin(.pi / 3) * 2
            }
            
            processed.append(BoardCoordinationPair(current.node, transformed))
            
            //Append current node's neighboors
            fifo.append(contentsOf: processed.last!
                .node
                .neighbors
                .nodes//all the neighboring nodes of the root cell
                .enumerated()
                .filter({ n in n.element !== nil && !processed.contains{ n.element?.neighbors.equals($0.node.neighbors) == true } })//Filter out nil nodes and nodes that have been processed
                .map({ QueuedNodePair($0.element!, CGPoint(x: 0, y: 0), Neighbors.allDirections[$0.offset]) }))
        }
        
        return processed
    }
}
