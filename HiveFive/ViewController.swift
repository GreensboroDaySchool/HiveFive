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
    
    @IBOutlet var pan: UIPanGestureRecognizer!
    @IBOutlet var pinch: UIPinchGestureRecognizer!
    
    /**
     This variable records the previous translation to detect change
     */
    private var lastTranslation: CGPoint?
    
    var board: BoardView { return view.viewWithTag(233) as! BoardView }
    var hive: Hive {
        get {return Hive.sharedInstance}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let blackQueenBee = QueenBee(color: .black)
        let blackGrasshopper = Grasshopper(color: .black)
        let blackSpider = Spider(color: .black)
        let blackBeetle = Beetle(color: .black)
        
        blackGrasshopper.place(at: .downLeft, of: blackQueenBee)
        blackSpider.place(at: .upRight, of: blackQueenBee)
        blackBeetle.place(at: .down, of: blackSpider)
        
        hive.delegate = self
        hive.root = blackQueenBee
        board.rootCoordinate = CGPoint(x: board.bounds.midX, y: board.bounds.midY)
        
    }
    
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        let focus = sender.location(in: board)
        var scale = sender.scale
        let origin = board.rootCoordinate
        
        //Exclude these states because at these moments the change (first derivative) does not exist
        switch sender.state {
        case .began: scale = 1
        case .ended: scale = 1
        default: break
        }
        
        //Change node radius based on the scale
        if board.nodeRadius >= board.maxNodeRadius && scale > 1
            || board.nodeRadius <= board.minNodeRadius && scale < 1 {
            return
        }
        board.nodeRadius *= scale
        
        /*
         Calculate the escaping direction of root coordinate to create an optical illusion.
         This way users will be able to scale to exactly where they wanted on the screen
         */
        let escapeDir = Vec2D(point: origin)
            .sub(Vec2D(point: focus)) //translate to focus's coordinate system by subtracting it
            .mult(scale) //elongate or shrink according to the scale.
        
        //Compensating change in coordinate, since escapeDir is now in focus's coordinate system.
        board.rootCoordinate = escapeDir
            .add(Vec2D(point: focus))
            .cgPoint
        
        //Reset the scale so that sender.scale is always the first derivative
        sender.scale = 1
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let last = lastTranslation else {
            lastTranslation = sender.translation(in: board)
            return
        }
        
        switch sender.state {
        case .ended: lastTranslation = nil
            return
        default: break
        }
        
        let current = sender.translation(in: board)
        let change = current - last
        let newCoordinate = board.rootCoordinate + change
        board.rootCoordinate = newCoordinate
        lastTranslation = current
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
