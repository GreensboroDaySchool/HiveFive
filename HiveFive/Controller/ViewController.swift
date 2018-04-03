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

/**
 This is the Controller of the MVC design pattern.
 In this case -
 >   Model:      Hive
 >   View:       BoardView
 >   Controller: ViewController
 */
class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var pan: UIPanGestureRecognizer!
    @IBOutlet var pinch: UIPinchGestureRecognizer!
    
    /**
     This variable records the previous translation to detect change
     */
    private var lastTranslation: CGPoint?
    
    /**
     View
     */
    var board: BoardView { return view.viewWithTag(233) as! BoardView }
    
    /**
     Model
     */
    var hive: Hive {
        get {return Hive.sharedInstance}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hive.delegate = self // establish communication with Model
        board.delegate = self // establish communication with View
        
        let beetle2 = Beetle(color: .black)
        let grasshopper = Grasshopper(color: .black)
        let queenBee = QueenBee(color: .black)
        let beetle = Beetle(color: .black)
        let soldierAnt = SoldierAnt(color: .black)
        let spider = Spider(color: .black)
        let spider2 = Spider(color: .black)
        
        beetle2.connect(with: spider, at: .upRight)
        
        grasshopper.connect(with: spider, at: .down) // grasshopper is beneath the spider
        queenBee.connect(with: grasshopper, at: .downRight) // queen bee is to the lower right of grasshopper
        beetle.connect(with: grasshopper, at: .downLeft) // beetle is to the lower left of grass hopper
        
        soldierAnt.connect(with: beetle, at: .down) // soldier ant is beneath beetle
        soldierAnt.connect(with: spider2, at: .downLeft) // soldier ant is also lower left of spider2
        
        spider2.connect(with: grasshopper, at: .down) // spider2 is right beneath grasshopper
        //in real world scenario, spider2 is also lower right of beetle and lower left of queen bee
        spider2.connect(with: queenBee, at: .downLeft) // spider2 is also lower left of queen bee
        spider2.connect(with: beetle, at: .downRight) // spider2 is also lower right of beetle
        
        hive.root = spider
        let ctr = CGPoint(x: board.bounds.midX, y: board.bounds.midY)
        board.rootCoordinate = ctr
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

extension ViewController: BoardViewDelegate {
    func didTap(on node: HexNode) {
        hive.select(node: node)
    }
    
    func didTapOnBoard() {
        hive.cancelSelection()
    }
}

extension ViewController: HiveDelegate {
    /**
     Transfer the updated root structure from hive to boardview for display
     */
    func structureDidUpdate() {
        board.root = hive.root
    }
    
    func selectedNodeDidUpdate() {
        board.updateSelectedNode(hive.selectedNode)
    }
    
    func availablePositionsDidUpdate() {
        board.availablePositions = hive.availablePositions
    }
}
