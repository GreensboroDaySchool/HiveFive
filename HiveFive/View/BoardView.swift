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

var nodeRadius: CGFloat = 48

class BoardView: UIView {
    
    var centerOffset: CGPoint = .init(x: 0, y: 0) {
        didSet {
            _cachedLayout = layoutHive()
            onNodeChanges()
        }
    }
    
    //the board view shouldn't know about hive; it should only know about the structure.
    var hiveRoot: HexNode? {
        didSet {
            onNodeChanges()
        }
    }
    
    
    //Cache layout of the hive. Only re-layout when a node is moved/placed
    fileprivate var _cachedLayout: Set<NodeCoordinate>? = nil
    //Since the views will only be added, so we will just not care about removing them
    private var subnodeViews = [NodeCoordinate:NodeView]()
    
    func onNodeChanges(){
        guard let layout = layout else { return }
        layout.forEach{
            current in
            let view = subnodeViews[current] ?? { let _view = NodeView(frame: .zero)
                self.addSubview(_view)
                return _view
                }()
            
            view.node = current.node
            //Just assign it right here. Later can be used for animation purposes
            view.frame = CGRect(origin: current.coordinate, size: view.expectedSize)
        }
    }
    
//    override func draw(_ rect: CGRect) {
//
//    }
}

extension BoardView {
    
    fileprivate var layout: Set<NodeCoordinate>? {
        if let cached = _cachedLayout { return cached }
        _cachedLayout = layoutHive()
        return _cachedLayout
    }
    
    fileprivate struct NodeCoordinate: Hashable {
        var node: HexNode
        var dir: Direction
        var coordinate: CGPoint = .zero
        var zIndex = 0
        
        //Use the node's neighbors to identify the coordination
        var hashValue: Int { return node.neighbors.hashValue }
        static func == (l: NodeCoordinate, r: NodeCoordinate) -> Bool {
            return l.hashValue == r.hashValue
        }
        
        //An easy access to the nodes array
        var neighbors: [HexNode?] { return node.neighbors.nodes }
        
        init(_ node: HexNode, from sourceDirection: Direction, at coordination: CGPoint, zIndex: Int){
            self.node = node
            self.dir = sourceDirection
            self.coordinate = coordination
            self.zIndex = zIndex
        }
        
        init(_ node: HexNode, direction: Direction, from sourceCoordination: NodeCoordinate){
            self.node = node
            self.dir = direction
            self.coordinate = sourceCoordination.coordinate
            self.zIndex = sourceCoordination.zIndex
        }
        
        init(_ node: HexNode) {
            self.init(node, from: .above, at: .zero, zIndex: 0)
        }
    }
    
    fileprivate func layoutHive() -> Set<NodeCoordinate>? {
        //Only layout when there is a hive
        guard let hiveRoot = hiveRoot else { return nil }
        var pool = [NodeCoordinate]() //A queue that stores all the nodes that need to be processed
        var processed = Set<NodeCoordinate>()
        let root = NodeCoordinate(hiveRoot, from: .above, at: centerOffset, zIndex: 0)
        
        //A wrapper function to provide a transformation closure to each surrounding node, withour coordinations
        func process(from sourceCoordinate: NodeCoordinate) -> (((offset: Int, element: HexNode?)) -> NodeCoordinate) {
            func _process(_ enumerated: (offset: Int, element: HexNode?)) -> NodeCoordinate {
                return NodeCoordinate(
                    enumerated.element!,
                    from: Direction(rawValue: enumerated.offset)!,
                    at: sourceCoordinate.coordinate,
                    zIndex: sourceCoordinate.zIndex
                )
            }
            return _process
        }
        
        //Assign (midX, midY) to the root node
        processed.insert(root)
        //Append the neighbors to the queue
        pool.append(contentsOf: root.neighbors.enumerated().filter{ $0.element !== nil }.map(process(from: root)))
        
        //Transform node locations from the inside to the outside
        while(!pool.isEmpty){
            var current = pool.removeFirst()
            var transformed = current.coordinate
            
            //If it is supressing another node, return the node's location with zIndex - 1
            //We don't need to trace up because the uppermost node is always connected to another node
            if case .below = current.dir {
                current.coordinate = transformed
                //Check if there is anymore to the node
                if let nodeBelow = current.node.neighbors[.below] {
                    let next = NodeCoordinate(nodeBelow, from: .below, at: transformed, zIndex: current.zIndex - 1)
                    if !processed.contains(next) { pool.append(next) }
                }
                processed.insert(current)
                continue
            }
            
            //Left and Right (x-axis) are different from up/down (simpler)
            //thus using two switch statement to transform coordinations
            switch(current.dir){
            case .upRight, .downRight: transformed.x += nodeRadius * 1.5
            case .upLeft, .downLeft: transformed.x -= nodeRadius * 1.5
            default: break
            }
            
            switch(current.dir){
            case .upRight, .upLeft: transformed.y -= nodeRadius * sin(.pi / 3)
            case .downLeft, .downRight: transformed.y += nodeRadius * sin(.pi / 3)
            case .up: transformed.y -= nodeRadius * sin(.pi / 3) * 2
            case .down: transformed.y += nodeRadius * sin(.pi / 3) * 2
            default: break
            }
            
            current.coordinate = transformed
            processed.insert(current)
            
            //Append current node's neighboors
            pool.append(contentsOf: current
                .neighbors
                .enumerated()
                .filter{ $0.element !== nil }
                .map{ NodeCoordinate($0.element!, direction: Direction(rawValue: $0.offset)!, from: current) }
                .filter{ !processed.contains($0) })
        }
        
        return processed
    }
}
