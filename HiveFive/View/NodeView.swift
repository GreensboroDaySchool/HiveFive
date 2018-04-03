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

@IBDesignable
class NodeView: UIView {
    
    /**
     Path contains information about both node and relative position
     */
    let path: Path!
    
    var node: HexNode {
        return path!.destination
    }
    
    
    
    /**
     The radius of the node (outer radius)
     */
    private var radius: CGFloat = 0
    
    /**
     This indicates whether the node is currently selected. The outlook/color should change accordingly
     */
    var isSelected = false {
        didSet {
            if oldValue != isSelected {
                setNeedsDisplay()
            }
        }
    }
    
    /**
     Since the superview of NodeView should always be its delegate, this is much more convenient.
     */
    var delegate: NodeViewDelegate {
        return self.superview! as! NodeViewDelegate
    }
    
    /**
     Radius of the circle that fits in the hexagon
     */
    var innerRadius: CGFloat {
        get {return bounds.height / 2}
    }
    
    /**
     Actual radius of the polygon that is drawn on screen
     */
    var displayRadius: CGFloat {
        get {return radius * displayRadiusRatio}
    }
    
    /**
     Grabs the drawing core graphics context, for convenience.
     */
    var context: CGContext {
        return UIGraphicsGetCurrentContext()!
    }
    
    @IBInspectable var regularBorderColor: UIColor = .gray
    @IBInspectable var selectedBorderColor: UIColor = .red
    var borderColor: UIColor {
        return isSelected ? selectedBorderColor : regularBorderColor
    }
    
    @IBInspectable var regularFillColor: UIColor = UIColor.gray.withAlphaComponent(0.3)
    @IBInspectable var selectedFillColor: UIColor = UIColor.red.withAlphaComponent(0.3)
    var fillColor: UIColor {
        return isSelected ? selectedFillColor : regularFillColor
    }
    
    @IBInspectable var dummyBorderColor: UIColor = UIColor.green
    @IBInspectable var dummyFillColor: UIColor = UIColor.green.withAlphaComponent(0.2)
    
    /**
     Ratio acquired by doing (borderWidth / radius)
     */
    @IBInspectable var borderWidthRatio: CGFloat = 1 / 16
    
    /**
     Ratio acquired by doing (dummyBorderRatio / radius)
     */
    @IBInspectable var dummyBorderWidthRatio: CGFloat = 1 / 16
    
    /**
     Ratio acquired by doing (displayRadius / radius)
     */
    @IBInspectable var displayRadiusRatio: CGFloat = 15 / 16

    
    /**
     Since the user can zoom in and out, a fixed borderWidth is no longer suitable.
     The border width should instead be derived from node radius by multiplying with a ratio.
     */
    var borderWidth: CGFloat {
        get {return radius * borderWidthRatio}
    }
    
    var dummyBorderWidth: CGFloat {
        get {return radius * dummyBorderWidthRatio}
    }
    
    /**
     Each node view must be paired with a path.
     */
    init(path: Path) {
        self.path = path
        super.init(frame: CGRect.zero)
        self.isOpaque = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.path = nil
        super.init(coder: aDecoder)
    }
    
    @objc func handleTap() {
        print("Tapped: \(node.identity.rawValue)")
        delegate.didTap(node: node)
    }
    
    /**
     Calculte the rectangular size of the node based on the given radius
     - Parameter radius: The radius of the node
     */
    private func calculateSize(radius: CGFloat) -> CGSize {
        return CGSize(
            width: 2 * radius + borderWidth,
            height: 2 * sin(.pi / 3) * radius + borderWidth
        )
    }
    
    /**
     Update the radius and coordinate of the current node view.
     - Parameter radius: The new radius
     - Parameter rootCo: The new root coordinate
     */
    func update(radius: CGFloat, rootCo: CGPoint) {
        let route = path.route
        var offset = route.relativeCoordinate(radius: radius)
        offset.y *= -1 // the y coordinate on screen is inverted
        self.frame = CGRect(
            origin: rootCo + offset,
            size: calculateSize(radius: radius)
        )
        self.radius = radius
    }
    
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        switch node.identity {
        case .dummy: drawDummy()
        default:
            drawHexagon(rect)
            drawIdentityGram(rect)
        }
    }
    
    private func drawDummy() {
        let dummy = pathForPolygon(radius: displayRadius, sides: 6)
        context.saveGState()
        context.translateBy(x: bounds.midX, y: bounds.midY)
        dummyFillColor.setFill()
        dummyBorderColor.setStroke()
        dummy.lineWidth = dummyBorderWidth
        dummy.fill()
        dummy.stroke()
        context.restoreGState()
    }
    
    /**
     The bounds of each node view is rectangular by default - this is not appropriate because it overlaps
     and inteferes with other nodes. Overriding this method provides a more pixel-accurate method for
     determining which node view is acutually being touched.
     */
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // point is in relation to bounds.origin
        let ctr = bounds.origin.translate(bounds.midX, bounds.midY) // center of the hexagon
        return ctr.dist(to: point) < innerRadius // make sure the touch is within the inner radius, not the outer.
    }
    
    /**
     Draws the letter "identity gram" at the center of each node that indicates the identity of each node.
     - Note: This is only temporary.
     */
    private func drawIdentityGram(_ rect: CGRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes : [NSAttributedStringKey:NSObject] = [
            .paragraphStyle  : paragraphStyle,
            .font            : UIFont.systemFont(ofSize: radius),
            .foregroundColor : borderColor,
        ]
        
        let attrString = NSAttributedString(
            string: node.identity.rawValue,
            attributes: attributes
        )
        
        let textHeight = attrString.height(withConstrainedWidth: bounds.size.width) / 2
        let origin = CGPoint(x: bounds.origin.x, y: textHeight / 2 + bounds.origin.y)
        let rect = CGRect(origin: origin, size: bounds.size)
        attrString.draw(in: rect)
    }
    
    /**
     Draws the body and contour of the hexagon
     This should be the same for every node, except maybe color
     */
    private func drawHexagon(_ rect: CGRect) {
        let hexagon = pathForPolygon(radius: displayRadius, sides: 6)
        context.saveGState() // save
        borderColor.setStroke()
        context.translateBy(x: bounds.midX, y: bounds.midY)
        hexagon.lineWidth = borderWidth
        hexagon.stroke()
        fillColor.setFill()
        hexagon.fill()
        context.restoreGState() // restore
    }
    
    /**
     Construct the UIBezierPath for a polygon, utilizing the convenience provided by Vec2D lib.
     - Parameter radius: The radius of the polygon
     - Parameter sides:  Number of sides of the polygon
     - Returns:          UIBezierPath for the requested polygon
     */
    private func pathForPolygon(radius: CGFloat, sides: Int) -> UIBezierPath {
        let path = UIBezierPath()
        let step = CGFloat.pi * 2 / CGFloat(sides)
        path.move(to: Vec2D(x: cos(step), y: sin(step)).setMag(radius).cgPoint)
        for i in 1...(sides - 1) {
            let angle = step * CGFloat(i + 1)
            let dir = Vec2D(x: cos(angle), y: sin(angle))
                .setMag(radius).cgPoint
            path.addLine(to: dir)
        }
        path.close()
        return path
    }
}

/**
 The delegate protocol helps to pass on the action to the delegate
 */
protocol NodeViewDelegate {
    func didTap(node: HexNode)
}
