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



@IBDesignable class BoardView: UIView {
    
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
    
    var rootCoordinate: CGPoint = .init(x: 0, y: 0) {
        didSet { // the coordinate of root node has changed (panning)
            updateDisplay()
        }
    }
    
    /**
     The root node of the hive
     */
    var root: HexNode? {
        didSet { // the structure of the hive has changed
            updateStructure()
        }
    }
    
    private var paths = [Path]()
    private var nodeViews: [NodeView] {
        get {
            return subviews.map{$0 as! NodeView}
        }
    }
    
    /**
     This method should be called when the user is panning or zooming the structure.
     When rootCoordinate or nodeRadius changes, only the coordinates need to be updated.
     */
    func updateDisplay() {
        assert(subviews.count == paths.count)
        nodeViews.enumerated().forEach {(index, element) in
            let route = paths[index].route
            let offset = route.relativeCoordinate(radius: nodeRadius)
            element.update(
                radius: nodeRadius,
                coordinate: offset + rootCoordinate
            )
        }
        subviews.forEach{$0.setNeedsDisplay()} // prevent pixelation, affects performance though
    }
    
    /**
     When the structure of the hive changes, recalculate the paths leading to each node
     and update the psuedo relative coordinates of the subviews
     */
    func updateStructure(){
        guard let root = root else { return }
        paths = root.derivePaths()
        paths.append(Path(route: Route(directions: []), destination: root))
        subviews.forEach{$0.removeFromSuperview()} // remove existing subviews. This is not expensive since there are not many subviews anyways.
        paths.forEach {
            addSubview(NodeView(node: $0.destination))
        }
        updateDisplay()
    }
    
//    override func draw(_ rect: CGRect) {
//
//    }
}
