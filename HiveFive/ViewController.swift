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

class ViewController: UIViewController {
    var board: BoardView { return view.viewWithTag(233) as! BoardView }
    var hive: Hive {
        get {return Hive.sharedInstance}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let root = QueenBee(color: .black)
        let anotherNode = Grasshopper(color: .black)
        anotherNode.connect(with: root, at: .downLeft)
        let anotherAnotherNode = Spider(color: .black)
        anotherAnotherNode.connect(with: root, at: .upRight)
        let oneSubSubNode = Beetle(color: .black)
        oneSubSubNode.connect(with: anotherAnotherNode, at: .down)
        
        hive.delegate = self
        hive.root = root
        board.rootCoordinate = CGPoint(x: board.bounds.midX, y: board.bounds.midY)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: HiveDelegate {
    func hiveDidUpdate() {
        // transfer the updated root to boardview for display
        board.root = hive.root
    }
}
