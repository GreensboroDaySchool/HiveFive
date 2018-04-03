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
    weak var node: HexNode?
    
    var radius: CGFloat = 0
    
    @IBInspectable var borderColor: UIColor = .gray
    @IBInspectable var borderWidth: CGFloat = 3.0
    @IBInspectable var fillColor: UIColor = UIColor.gray.withAlphaComponent(0.8)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //Allow transparent background
        self.isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isOpaque = false
    }
    
    private func calculateSize(radius: CGFloat) -> CGSize {
        return CGSize(
            width: 2 * radius + borderWidth,
            height: 2 * sin(.pi / 3) * radius + borderWidth
        )
    }
    
    func update(radius: CGFloat, coordinate: CGPoint) {
        self.frame = CGRect(origin: coordinate, size: calculateSize(radius: radius))
        self.radius = radius
    }
    
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let offset = CGPoint(x: borderWidth / 2, y: borderWidth / 2)
        let polygon = UIBezierPath()
        
        polygon.move(to: CGPoint(
            x: offset.x + (radius * 0.5),
            y: offset.y))
        polygon.addLine(to: CGPoint(
            x: offset.x + (radius * 1.5),
            y: offset.y))
        polygon.addLine(to: CGPoint(
            x: offset.x + (radius * 2),
            y: offset.y + (radius * sin(.pi / 3))))
        polygon.addLine(to: CGPoint(
            x: offset.x + (radius * 1.5),
            y: offset.y + (radius * sin(.pi / 3) * 2)))
        polygon.addLine(to: CGPoint(
            x: offset.x + (radius * 0.5),
            y: offset.y + (radius * sin(.pi / 3) * 2)))
        polygon.addLine(to: CGPoint(
            x: offset.x,
            y: offset.y + (radius * sin(.pi / 3))))
        polygon.close()
        borderColor.setStroke()
        polygon.lineWidth = borderWidth
        polygon.stroke()
        fillColor.setFill()
        polygon.fill()
    }
}
