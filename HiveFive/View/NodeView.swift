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
    var path: Path!
    
    var node: HexNode {
        return path!.destination
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let node = Identity.dummy.new(color: .black)
        path = Path(destination: node, route: Route(directions: []))
    }
    
    
    /**
     The radius of the node (outer radius)
     */
    private var radius: CGFloat = 0
    /**
     The coordinate of the root node
     */
    private var rootCoordinate: CGPoint = .zero
    
    
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
    
    var displayHeight: CGFloat {
        get {
            return displayRadius * sin(.pi / 3) * 2
        }
    }
    
    var displayWidth: CGFloat {
        get {
            return displayRadius * 2
        }
    }
    
    /**
     Actual radius of the polygon that is drawn on screen
     */
    var displayRadius: CGFloat {
        get {
            return radius * displayRadiusRatio * pow(CGFloat(overlapShrinkRatio), CGFloat(nodesBelow()))
        }
    }
    
    /**
     Defines by how much the radius of a piece should shrink when it goes on top of another piece
     */
    var overlapShrinkRatio: CGFloat = 0.92
    
    var patterns: [Identity:String]? {
        return (superview as? BoardView)?.patterns
    }
    
    /**
     Grabs the drawing core graphics context, for convenience.
     */
    var context: CGContext {
        return UIGraphicsGetCurrentContext()!
    }
    
    /**
     A completely different style - only one color
     */
    var isMonochromatic = true
    
    @IBInspectable var monocromaticColor: UIColor = .black // this must be a solid color
    @IBInspectable var monocromaticSelectedColor: UIColor = .red // this must be a solid color as well
    
    @IBInspectable var whiteBorderColor: UIColor = .black
    @IBInspectable var whiteFillColor: UIColor = UIColor.white.withAlphaComponent(1)
    
    @IBInspectable var blackBorderColor: UIColor = .black
    @IBInspectable var blackFillColor: UIColor = UIColor.lightGray.withAlphaComponent(1)
    
    @IBInspectable var selectedBorderColor: UIColor = .orange
    @IBInspectable var selectedFillColor: UIColor = UIColor.orange.withAlphaComponent(0.2)
    @IBInspectable var selectedIdentityColor: UIColor = .orange

    @IBInspectable var dummyColor: UIColor = .green
    @IBInspectable var dummyColorAlpha: CGFloat = 0.2
    
    var regularBorderColor: UIColor {
        if isMonochromatic {return monocromaticColor}
        return node.color == .black ? blackBorderColor : whiteBorderColor
    }
    var regularFillColor: UIColor {
        if isMonochromatic {return node.color == .black ? monocromaticColor : .white}
        return node.color == .black ? blackFillColor : whiteFillColor
    }
    var regularIdentityColor: UIColor {
        if isMonochromatic {return node.color == .black ? .white : monocromaticColor}
        return _borderColor
    }
    
    var monocromaticSelectedBorderColor: UIColor {
        return node.color == .black ? monocromaticSelectedColor : monocromaticSelectedColor
    }
    var monocromaticSelectedFillColor: UIColor {
        return node.color == .black ? monocromaticSelectedColor : .white
    }
    var monocromaticSelectedIdentityColor: UIColor {
        return node.color == .black ? .white : monocromaticSelectedColor
    }
    
    var _borderColor: UIColor {
        return isSelected ? isMonochromatic ? monocromaticSelectedBorderColor : selectedBorderColor : regularBorderColor
    }
    var fillColor: UIColor {
        return isSelected ? isMonochromatic ? monocromaticSelectedFillColor : selectedFillColor : regularFillColor
    }
    var identityColor: UIColor {
        return isSelected ? isMonochromatic ? monocromaticSelectedIdentityColor : selectedIdentityColor : regularIdentityColor
    }
    
    /**
     Ratio acquired by doing (_borderWidth / radius)
     */
    @IBInspectable var borderWidthRatio: CGFloat = 1/100
    
    /**
     Ratio acquired by doing (_borderWidth / radius) when selected
     */
    @IBInspectable var selectedBorderWidthRatio: CGFloat = 1/100
    
    /**
     Ratio acquired by doing (dummyBorderRatio / radius)
     */
    @IBInspectable var dummyBorderWidthRatio: CGFloat = 1/100
    
    /**
     Ratio acquired by doing (displayRadius / radius)
     */
    @IBInspectable var displayRadiusRatio: CGFloat = 15 / 16

    
    /**
     Since the user can zoom in and out, a fixed borderWidth is no longer suitable.
     The border width should instead be derived from node radius by multiplying with a ratio.
     */
    var _borderWidth: CGFloat {
        get {return radius * (isSelected ? selectedBorderWidthRatio: borderWidthRatio)}
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
        Profile.defaultProfile.apply(on: self)
        
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
            width: 2 * radius + _borderWidth,
            height: 2 * sin(.pi / 3) * radius + _borderWidth
        )
    }
    
    /**
     Update the radius and coordinate of the current node view.
     - Parameter radius: The new radius
     - Parameter rootCo: The new root coordinate
     */
    private func update() {
        let route = path.route
        var offset = route.relativeCoordinate(radius: radius)
        offset.y *= -1 // the y coordinate on screen is inverted
        self.frame = CGRect(
            origin: rootCoordinate + offset,
            size: calculateSize(radius: radius)
        )
    }
    
    /**
     - Parameter rootCoordinate: The coordinate of the root node.
     */
    func update(rootCoordinate: CGPoint) {
        self.rootCoordinate = rootCoordinate
        update()
    }
    
    /**
     - Parameter radius: The new Radius.
     */
    func update(radius: CGFloat) {
        self.radius = radius
        update()
    }
    
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        switch node.identity {
        case .dummy: drawDummy()
        default:
            context.saveGState()
            if isMonochromatic && isSelected && nodesBelow() > 0 {
                context.setAlpha(0.5)
            }
            drawHexagon(rect)
            drawIdentityGram(rect)
            context.restoreGState()
        }
    }
    
    /**
     Draws the dummy piece, i.e. the prompted positions.
     */
    private func drawDummy() {
        let dummy = pathForPolygon(radius: displayRadius, sides: 6)
        context.saveGState()
        context.translateBy(x: bounds.midX, y: bounds.midY)
        if isMonochromatic { //monocromatic - only one color. The drawing logic should be different.
            dummy.lineWidth = dummyBorderWidth
            monocromaticSelectedColor.setStroke()
            monocromaticSelectedColor.withAlphaComponent(dummyColorAlpha).setFill()
            dummy.fill()
            dummy.stroke()
        } else {
            dummyColor.withAlphaComponent(dummyColorAlpha).setFill()
            dummyColor.setStroke()
        }
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
        // if current node is not the topmost node, then ignore.
        if node.neighbors[.above] != nil {return false}
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
            .foregroundColor : identityColor,
        ]
        
        let attrString = NSAttributedString(
            string: patterns?[node.identity] ?? node.identity.defaultPattern,
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
        _borderColor.setStroke()
        fillColor.setFill()
        context.translateBy(x: bounds.midX, y: bounds.midY)
        hexagon.lineWidth = _borderWidth
        hexagon.fill()
        hexagon.stroke()
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
        path.lineJoinStyle = .round
        return path
    }
    
    /**
     - Returns: The number of nodes that are below the current node
     */
    private func nodesBelow() -> Int {
        var current = node
        var count = 0
        while current.neighbors[.below] != nil {
            current = current.neighbors[.below]!
            count += 1
        }
        return count
    }
}

/**
 The delegate protocol helps to pass on the action to the delegate
 */
protocol NodeViewDelegate {
    func didTap(node: HexNode)
}

extension NodeView {
    func set(color: UIColor, forKeyPath path: ReferenceWritableKeyPath<NodeView, UIColor>) {
        self[keyPath: path] = color
    }
    func set(val: CGFloat, forKeyPath path: ReferenceWritableKeyPath<NodeView, CGFloat>) {
        self[keyPath: path] = val
    }
    func set(bool: Bool, forKeyPath path: ReferenceWritableKeyPath<NodeView, Bool>) {
        self[keyPath: path] = bool
    }
}
