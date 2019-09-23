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
import HiveFiveCore

/**
 This is the Controller of the MVC design pattern.
 >   Model:      Hive
 >   View:       BoardView
 >   Controller: ViewController
 */
class BoardViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var pan: UIPanGestureRecognizer!
    @IBOutlet var pinch: UIPinchGestureRecognizer!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var hiveBarItem: UIBarButtonItem!
    
    /// Records the previous translation to detect change
    private var lastTranslation: CGPoint?
    
    /// View
    var board: BoardView { return view.viewWithTag(233) as! BoardView }
    
    /// Model
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
        
        // Delegate binding
        hive.delegate = self // establish communication with Model
        board.delegate = self // establish communication with View
        
        // User defaults
        toolBar.isHidden = !UserDefaults.toolBarVisible()
        
        // Notification binding
        observe(.themeUpdated, #selector(themeDidUpdate(_:)))
        observe(.didSelectNewNode, #selector(didSelectNewNode(_:)))
        observe(.toolBarVisibleUpdated, #selector(toolBarVisibilityDidUpdate(_:)))
        observe(.presetUpdated, #selector(updateToolBarItemTint))
        observe(.kpHackableUpdated, #selector(updateToolBarItemTint))
        observe(.queen4Updated, #selector(updateQueen4))
        observe(.immobilized4Updated, #selector(updateImmobilized4))
        observe(.expansionPackUpdated, #selector(updateExpansionPack))
        
        // Additional setup
        hiveBarItem.image = [#imageLiteral(resourceName: "hive_img"),#imageLiteral(resourceName: "hive_2_img"),#imageLiteral(resourceName: "solid_honeycomb"),#imageLiteral(resourceName: "bee")].random()
        updateToolBarItemTint()
        hive.queen4 = UserDefaults.useQueen4()
        hive.immobilized4 = UserDefaults.useImmobilized4()
        hive.expansionPackEnabled = UserDefaults.useExpansionPack()
        
        // Toolbar setup (make tool bar transparent)
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolBar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hive.delegate = self
        board.delegate = self
    }
    
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        let focus = sender.location(in: board)
        var scale = sender.scale
        let origin = board.rootCoordinate
        
        // Exclude these states because at these moments the change (first derivative) does not exist
        switch sender.state {
        case .began: scale = 1
        case .ended:
            scale = 1
            board.pinchGestureDidEnd() // notify the board that the pinch gesture has ended.
        default: break
        }
        
        // Change node radius based on the scale
        if board.nodeRadius >= board.maxNodeRadius && scale > 1
            || board.nodeRadius <= board.minNodeRadius && scale < 1 {
            return
        }
        board.nodeRadius *= scale
        
        // Calculate the escaping direction of root coordinate to create an optical illusion.
        // This way users will be able to scale to exactly where they wanted on the screen
        let escapeDir = Vec2D(point: origin)
            .sub(Vec2D(point: focus)) //translate to focus's coordinate system by subtracting it
            .mult(Float(scale)) //elongate or shrink according to the scale.
        
        // Compensate change in coordinate, since escapeDir is now in focus's coordinate system.
        board.rootCoordinate = escapeDir
            .add(Vec2D(point: focus))
            .cgPoint
        
        // Reset the scale so that sender.scale is always the first derivative
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
    
    @IBAction func barButtonPressed(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 0: container?.openLeft()
        case 1: hive.revert()
        case 2: hive.restore()
        case 3: restart()
        case 4: board.centerHiveStructure()
        default: break
        }
    }
    
    func restart() {
        board.clear()
        hive.reset()
    }
    
    override func viewDidLayoutSubviews() {
        board.centerHiveStructure()
    }
    
}

extension BoardViewController: BoardViewDelegate {
    func didTap(on node: HexNode) {
        switch hive.select(node: node) {
        case .tappedWrongNode: post(key: .displayMessage, object: "\(hive.currentPlayer == .black ? "Black" : "White")'s turn")
        case .violatedImmobilized4: post(key: .displayMessage, object: "Cannot Move")
        default: return
        }
    }
    
    func didTapOnBoard() {
        hive.cancelSelection()
    }
}

extension BoardViewController: HiveDelegate {
    
    /// Transfer the updated root structure from hive to boardview for display
    func structureDidUpdate() {
        board.root = hive.root
        post(key: .structureUpdated)
    }
    
    func selectedNodeDidUpdate() {
        board.updateSelectedNode(hive.selectedNode)
        post(key: .selectedNodeUpdated)
    }
    
    func availablePositionsDidUpdate() {
        board.availablePositions = hive.availablePositions
        post(key: .availablePositionsUpdated)
    }

    func rootNodeDidMove(by route: Route) {
        board.rootNodeMoved(by: route)
        post(key: .rootNodeMoved, object: route)
    }
    
    func hiveStructureRemoved() {
        board.clear()
        post(key: .hiveStructureRemoved)
    }
    
    func handDidUpdate(hand: Hand, color: Color) {
        post(key: .handUpdated, object: (hand,color))
    }
    
    func didPlace(newNode: HexNode) {
        // Play piece moved/placed sound effect
        Sound.play(file: "落子#1", fileExtension: "mp3", numberOfLoops: 0)
        post(key: .didPlaceSelection)
    }
    
    func didDeselect() {
        post(key: .didCancelSelection)
    }
    
    func gameHasEnded() {
        post(key: .displayMessage, object: "Hit Restart ↻")
    }
    
    func didWin(player: Color) {
        let msg = "\(player == .black ? "Black" : "White") Wins!"
        post(key: .displayMessage, object: msg)
    }
    
}

extension BoardViewController: SlideMenuControllerDelegate {
    
    /**
     Works perfectly!
     Disable pan gesture controls when menu will become visible.
     */
    func leftWillOpen() {
        pan.cancel()
    }
    
    func rightWillOpen() {
        pan.cancel()
    }
}

// MARK: Notification handling
extension BoardViewController {
    @objc func didSelectNewNode(_ notification: Notification) {
        hive.select(newNode: notification.object as! HexNode)
    }
    
    @objc func themeDidUpdate(_ notification: Notification) {
        board.patterns = notification.object! as! [Identity:String]
    }
    
    @objc func toolBarVisibilityDidUpdate(_ notification: Notification) {
        toolBar.isHidden = !UserDefaults.toolBarVisible()
    }
    
    // Hack... bad practice
    @objc private func updateToolBarItemTint() {
        toolBar.items?.forEach {
            $0.tintColor = UserDefaults.currentPreset()
            .properties.filter {$0.key == "Theme"}[0]
            .getValue() as? UIColor
        }
    }

    @objc func updateQueen4() {
        hive.queen4 = UserDefaults.useQueen4()
    }
    
    @objc func updateImmobilized4() {
        hive.immobilized4 = UserDefaults.useImmobilized4()
    }
    
    @objc func updateExpansionPack() {
        hive.expansionPackEnabled = UserDefaults.useExpansionPack()
    }
    
}
