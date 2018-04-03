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
    weak var node: HexNode!
    
    /**
     The radius of the node
     */
    var radius: CGFloat = 0
    
    /**
     Grabs the drawing core graphics context, for convenience.
     */
    var context: CGContext {
        return UIGraphicsGetCurrentContext()!
    }
    
    @IBInspectable var borderColor: UIColor = .gray
    @IBInspectable var borderWidthRatio: CGFloat = 1 / 16
    @IBInspectable var fillColor: UIColor = UIColor.gray.withAlphaComponent(0.8)

    /**
     Since the user can zoom in and out, a fixed borderWidth is no longer suitable.
     The border width should instead be derived from node radius by multiplying with a ratio.
     */
    var borderWidth: CGFloat {
        get {return radius * borderWidthRatio}
    }
    
    /**
     Each node view must be paired with a node.
     */
    init(node: HexNode) {
        super.init(frame: CGRect.zero)
        self.isOpaque = false
        self.node = node
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
     - Parameter coordinate: The new coordinate
     */
    func update(radius: CGFloat, coordinate: CGPoint) {
        self.frame = CGRect(origin: coordinate, size: calculateSize(radius: radius))
        self.radius = radius
    }
    
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        drawHexagon(rect)
        drawIdentityGram(rect)
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
            string: node.insect.rawValue,
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
        let hexagon = pathForPolygon(radius: radius, sides: 6)
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
