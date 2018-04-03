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
            updateDisplay()
        }
    }
    
    //prevent users from creating giant/tiny nodes
    @IBInspectable var maxNodeRadius: CGFloat = 100
    @IBInspectable var minNodeRadius: CGFloat = 10
    
    var delegate: BoardViewDelegate?
    
    var rootCoordinate: CGPoint = .init(x: 0, y: 0) { // the coordinate of root node has changed (panning)
        didSet {updateDisplay()}
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
     This method should be called when the user is panning or zooming the structure.
     When rootCoordinate or nodeRadius changes, only the coordinates need to be updated.
     */
    func updateDisplay() {
        nodeViews.forEach {$0.update(radius: nodeRadius, rootCo: rootCoordinate)}
        subviews.forEach{$0.setNeedsDisplay()} // prevent pixelation, affects performance though
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
        paths.forEach {
            addSubview(NodeView(path: $0))
        }
        updateDisplay()
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
    
    func updateAvailablePositions() {
//        let positions = availablePositions
//        positions.forEach{}
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
