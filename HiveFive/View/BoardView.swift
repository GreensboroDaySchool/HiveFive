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

let nodeRadius = 16.0

class BoardView: UIView {
    var hive: Hive?
    
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
}

fileprivate func location(for node: HexNode) -> CGPoint {
    return CGPoint()
}

extension BoardView {
    func layoutHive() {
        guard let hive = hive else { return }
        let centerDis = cos(1/12) * nodeRadius
        
    }
}
