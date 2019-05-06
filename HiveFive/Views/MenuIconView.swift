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

@IBDesignable class MenuIconView: UIView {
    
    @IBInspectable var iconColor: UIColor = UIColor.blue
    @IBInspectable var iconLineWidth: CGFloat = 5
    @IBInspectable var lineCap: Int = 1
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.backgroundColor = UIColor(white: 0, alpha: 0)
        iconColor.setStroke()
        pathForIcon().stroke()
    }
    
    private func pathForIcon() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.origin.x + iconLineWidth / 2, y: bounds.origin.y + iconLineWidth * 3 / 2 ))
        path.addLine(to: CGPoint(x: bounds.maxX - iconLineWidth / 2 - 5, y: bounds.origin.y + iconLineWidth * 3 / 2))
        
        path.move(to: CGPoint(x: bounds.origin.x + iconLineWidth / 2, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.maxX - iconLineWidth / 2, y: bounds.midY))
        
        path.move(to: CGPoint(x: bounds.origin.x + iconLineWidth / 2, y: bounds.maxY - iconLineWidth * 3 / 2))
        path.addLine(to: CGPoint(x: bounds.maxX - iconLineWidth / 2 - 10, y: bounds.maxY - iconLineWidth * 3 / 2))
        
        path.lineWidth = iconLineWidth
        path.lineCapStyle = CGLineCap(rawValue: CGLineCap.RawValue(lineCap))!
        return path
    }
    
}
