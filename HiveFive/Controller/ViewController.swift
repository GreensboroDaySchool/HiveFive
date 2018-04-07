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
    @IBOutlet weak var toolBar: UIToolbar!
    
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
    
    var container: ContainerViewController? {
        get {
            return parent as? ContainerViewController
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: delegate binding
        hive.delegate = self // establish communication with Model
        board.delegate = self // establish communication with View
        
        //MARK: user defaults
        toolBar.isHidden = !toolBarShouldBeVisible()
        
        
        //MARK: Notification binding
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidUpdate(_:)),
            name: themeUpdateNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didSelectNewNode(_:)),
            name: didSelectNewNodeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(toolBarVisibilityDidUpdate(_:)),
            name: toolBarVisibilityNotification,
            object: nil
        )
        
        //MARK: additional setup
        board.patterns = designatedTheme().patterns
    }
    
    
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        let focus = sender.location(in: board)
        var scale = sender.scale
        let origin = board.rootCoordinate
        
        //Exclude these states because at these moments the change (first derivative) does not exist
        switch sender.state {
        case .began: scale = 1
        case .ended:
            scale = 1
            board.pinchGestureDidEnd() // notify the board that the pinch gesture has ended.
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
        case .began: fallthrough
        case .ended:
            lastTranslation = nil
            return
        default: break
        }
        
        let current = sender.translation(in: board)
        let change = current - last
        let newCoordinate = board.rootCoordinate + change
        board.rootCoordinate = newCoordinate
        lastTranslation = current
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        container?.openLeft() //open menu
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Works flawlessly!
     */
    override func viewDidLayoutSubviews() {
        board.centerHiveStructure()
    }
    
}

extension ViewController: BoardViewDelegate {
    func didTap(on node: HexNode) {
        if node.color != hive.currentPlayer && node.identity != .dummy {
            post(name: displayMsgNotification, object: "\(hive.currentPlayer == .black ? "Black" : "White")'s turn")
        }
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

    func rootNodeDidMove(by route: Route) {
        board.rootNodeMoved(by: route)
    }
    
    func hiveStructureRemoved() {
        board.clear()
    }
    
}

extension ViewController: SlideMenuControllerDelegate {
    
    /**
     Works perfect!
     Disable pan gesture controls when menu will become visible.
     */
    func leftWillOpen() {
        pan.cancel()
    }
}

//MARK: Notification handling
extension ViewController {
    @objc func didSelectNewNode(_ notification: Notification) {
        hive.select(newNode: notification.object as! HexNode)
    }
    
    @objc func themeDidUpdate(_ notification: Notification) {
        board.patterns = notification.object! as! [Identity:String]
    }
    
    @objc func toolBarVisibilityDidUpdate(_ notification: Notification) {
        toolBar.isHidden = !toolBarShouldBeVisible()
    }
}
