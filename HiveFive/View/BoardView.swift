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

let nodeRadius: CGFloat = 32.0

class BoardView: UIView {
    var hive: Hive? = nil
    
    //Cache layout of the hive. Only re-layout when a node is moved/placed
    fileprivate var _cachedLayout: Set<NodeCoordination>? = nil
    //Since the views will only be added, so we will just not care about removing them
    private var subnodeViews = [NodeCoordination:NodeView]()
    
    func onNodeChanges(){
        guard let layout = layout else { return }
        
    }
    
//    override func draw(_ rect: CGRect) {
//
//    }
}

extension BoardView {
    fileprivate var layout: Set<NodeCoordination>? {
        if let cached = _cachedLayout { return cached }
        _cachedLayout = layoutHive()
        return _cachedLayout
    }
    
    fileprivate struct NodeCoordination: Hashable {
        var node: HexNode
        var source: Direction
        var coordination = CGPoint.zero
        var zIndex = 0
        
        //Use the node's neighbors to identify the coordination
        var hashValue: Int { return node.neighbors.hashValue }
        static func == (l: NodeCoordination, r: NodeCoordination) -> Bool {
            return l.hashValue == r.hashValue
        }
        
        //An easy access to the nodes array
        var neighbors: [HexNode?] { return node.neighbors.nodes }
        
        init(_ node: HexNode, from sourceDirection: Direction, at coordination: CGPoint, zIndex: Int){
            self.node = node
            self.source = sourceDirection
            self.coordination = coordination
            self.zIndex = zIndex
        }
        
        init(_ node: HexNode, direction: Direction, from sourceCoordination: NodeCoordination){
            self.node = node
            self.source = direction
            self.coordination = sourceCoordination.coordination
            self.zIndex = sourceCoordination.zIndex
        }
        
        init(_ node: HexNode) {
            self.init(node, from: .above, at: .zero, zIndex: 0)
        }
    }
    
    fileprivate func layoutHive() -> Set<NodeCoordination>? {
        //Only layout when there is a hive
        guard let hive = hive else { return nil }
        var pool = [NodeCoordination]() //A queue that stores all the nodes that need to be processed
        var processed = Set<NodeCoordination>()
        let root = NodeCoordination(hive.root, from: .above, at: .zero, zIndex: 0)
        
        //A wrapper function to provide a transformation closure to each surrounding node, withour coordinations
        func process(from sourceCoordination: NodeCoordination) -> (((offset: Int, element: HexNode?)) -> NodeCoordination) {
            func _process(_ enumerated: (offset: Int, element: HexNode?)) -> NodeCoordination {
                return NodeCoordination(
                    enumerated.element!,
                    from: Direction(rawValue: enumerated.offset)!,
                    at: sourceCoordination.coordination,
                    zIndex: sourceCoordination.zIndex
                )
            }
            return _process
        }
        
        //Assign (0, 0) to the root node
        processed.insert(root)
        //Append the neighbors to the queue
        pool.append(contentsOf: root.neighbors.enumerated().filter{ $0.element !== nil }.map(process(from: root)))
        
        //Transform node locations from the inside to the outside
        while(!pool.isEmpty){
            var current = pool.removeFirst()
            var transformed = current.coordination
            
            //If it is supressing another node, return the node's location with zIndex - 1
            //We don't need to trace up because the uppermost node is always connected to another node
            if case .below = current.source {
                current.coordination = transformed
                //Check if there is anymore to the node
                if let nodeBelow = current.node.neighbors[.below] {
                    let next = NodeCoordination(nodeBelow, from: .below, at: transformed, zIndex: current.zIndex - 1)
                    if !processed.contains(next) { pool.append(next) }
                }
                processed.insert(current)
                continue
            }
            
            //Left and Right (x-axis) are different from up/down (simpler)
            //thus using two switch statement to transform coordinations
            switch(current.source){
            case .upRight, .downRight: transformed.x += nodeRadius * 0.5
            case .upLeft, .downLeft: transformed.x -= nodeRadius * 0.5
            default: break
            }
            
            switch(current.source){
            case .upRight, .upLeft: transformed.y += nodeRadius * sin(.pi / 3)
            case .downLeft, .downRight: transformed.y -= nodeRadius * sin(.pi / 3)
            case .up: transformed.y += nodeRadius * sin(.pi / 3) * 2
            case .down: transformed.y -= nodeRadius * sin(.pi / 3) * 2
            default: break
            }
            
            current.coordination = transformed
            processed.insert(current)
            
            //Append current node's neighboors
            pool.append(contentsOf: current
                .neighbors
                .enumerated()
                .filter{ $0.element !== nil }
                .map{ NodeCoordination($0.element!, direction: Direction(rawValue: $0.offset)!, from: current) }
                .filter{ !processed.contains($0) })
        }
        
        return processed
    }
}
