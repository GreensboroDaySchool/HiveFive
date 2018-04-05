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



@IBDesignable class BoardView: UIView, NodeViewDelegate {
    
    @IBInspectable var nodeRadius: CGFloat = 48 {
        didSet {
            nodeRadius = nodeRadius > maxNodeRadius ?
                maxNodeRadius : nodeRadius < minNodeRadius ?
                    minNodeRadius : nodeRadius
            updateNodeRadius()
        }
    }
    
    /**
     Prevent users from creating giant/tiny nodes
     */
    @IBInspectable var maxNodeRadius: CGFloat = 100
    @IBInspectable var minNodeRadius: CGFloat = 10
    
    /**
     This boolean dictates whether to redraw each node views when the user
     is zooming in/out; setting this to true dramatically affects performance in some cases.
     */
    @IBInspectable var dynamicUpdate = false
    
    var delegate: BoardViewDelegate?
    
    var rootCoordinate: CGPoint = .init(x: 0, y: 0) { // the coordinate of root node has changed (panning)
        didSet {updateNodeCoordinates()}
    }
    
    /**
     Patterns that are drawn on top of each node.
     */
    var patterns = Identity.defaultPatterns {
        didSet {
            redrawSubviews()
        }
    }
    
    /**
     The root node of the hive
     */
    var root: HexNode? { // the structure of the hive has changed
        didSet {updateStructure()}
    }
    
    var availablePositions = [Position]() {
        didSet {updateAvailablePositions()}
    }
    
    private var nodeViews: [NodeView] {
        get {
            return subviews.map{$0 as! NodeView}
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTapRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTapRecognizer()
    }
    
    /**
     This should only be called once in the initialzer; sets up the UITapGestureRecognizer and set
     self as its delegate
     */
    private func setupTapRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnBoard))
        tap.delegate = self
        addGestureRecognizer(tap)
    }
    
    /**
     This method should be called when the user is zooming the structure.
     When nodeRadius changes, only the radius of each need to be updated such that the new coordinates could be calculated
     */
    func updateNodeRadius() {
        nodeViews.forEach {$0.update(radius: nodeRadius)}
        if dynamicUpdate { // prevent pixelation at the cost of performance
            redrawSubviews()
        }
    }
    
    /**
     Redraw all of the subviews (nodeViews). This could affect performance in some cases,
     i.e. when drawing complex unicode symbols as identity grams.
     */
    private func redrawSubviews() {
        subviews.forEach{$0.setNeedsDisplay()}
    }
    
    /**
     Only updates the coordinate, the node views don't need to be redrawn.
     */
    func updateNodeCoordinates() {
        nodeViews.forEach{$0.update(rootCoordinate: rootCoordinate)}
    }
    
    /**
     When the structure of the hive changes, recalculate the paths leading to each node
     and update the psuedo relative coordinates of the subviews
     */
    func updateStructure(){
        guard let root = root else { return }
        var paths = root.derivePaths()
        paths.append(Path(route: Route(directions: []), destination: root))
        nodeViews.forEach{$0.removeFromSuperview()} // remove existing subviews. This is not expensive since there are not many subviews anyways.
        paths.sort{$0.route.translation.z < $1.route.translation.z} // sort according to z coordinate, toppest node get added last.
        paths.forEach {
            addSubview(NodeView(path: $0))
        }
        updateNodeRadius()
        updateNodeCoordinates()
    }
    
    /**
     This method should be called each time the selected node is updated.
     - Parameter node: When this is nil, cancel selection for all node views;
     otherwise when selected is a reference, the node view containing the reference
     to the node will be marked as selected.
     */
    func updateSelectedNode(_ node: HexNode?) {
        nodeViews.enumerated().forEach {(index, element) in
            if element.node === node {
                element.isSelected = true
                element.removeFromSuperview()
                addSubview(element) // bring selected node to foreground
            } else {
                element.isSelected = false
            }
        }
    }

    /**
     Update dummy nodes according to the new prompted positions provided by the Hive model
     */
    func updateAvailablePositions() {
        nodeViews.filter{$0.node.identity == .dummy}
            .forEach{$0.removeFromSuperview()}
        let knownPaths = nodeViews.map{$0.path!}
        availablePositions.forEach {position in
            var route = knownPaths.filter{$0.destination === position.node}
                .map{$0.route}[0]
            route = route.append([position.dir])
            let dummy = HexNode()
            dummy.neighbors[position.dir.opposite()] = position.node // make a uni-directional connection
            let path = Path(route: route, destination: dummy)
            addSubview(NodeView(path: path))
        }
        updateNodeRadius()
        updateNodeCoordinates()
    }
    
    /**
     Adjusts the root coordinate so that the hive structure is centered in the view.
     */
    func centerHiveStructure() {
        if subviews.count == 0 {return}
        let frames = subviews.map{$0.frame}
        let xCos = frames
            .map{$0.origin.x}
            .sorted(by: <)
        let yCos = frames
            .map{$0.origin.y}
            .sorted(by: <)
        
        let cellHeight = nodeRadius * 4 * sin(.pi / 3) / 3
        
        let minX = xCos.first!
        let maxX = xCos.last! + 2 * nodeRadius
        let minY = yCos.first!
        let maxY = yCos.last! + cellHeight
        
        let width = maxX - minX
        let height = maxY - minY
        
        let hiveCtr = CGPoint(x: minX + width / 2, y: minY + height / 2)
        let boardCtr = CGPoint(x: bounds.midX, y: bounds.midY)
        let translation = hiveCtr - boardCtr
        rootCoordinate = rootCoordinate - translation
    }
    
    /**
     The user has finished zooming in/out, redraw node views to prevent pixelation.
     */
    func pinchGestureDidEnd() {
        redrawSubviews()
    }

    /**
     The root node has been moved by the player; this is a special case, update the coordinates accordingly
     so that the physical location & structure of the node views remains unchanged.
     */
    func rootNodeMoved(by route: Route) {
        rootCoordinate = rootCoordinate + route.relativeCoordinate(radius: nodeRadius).flipY()
    }
    
    /**
     This method is called when the touch landed on one of the nodes
     */
    func didTap(node: HexNode) {
        delegate?.didTap(on: node)
    }
    
    /**
     This method is called when the touch landed on blank spaces
     */
    @objc func didTapOnBoard() {
        delegate?.didTapOnBoard()
    }
    
}

extension BoardView: UIGestureRecognizerDelegate {
    /**
     Only receive touch when it landed on self, i.e. not on the nodes.
     */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === self
    }
}

protocol BoardViewDelegate {
    func didTap(on node: HexNode) // touched on node
    func didTapOnBoard() // touched on blank areas
}
