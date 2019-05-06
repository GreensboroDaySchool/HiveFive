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
import Hive5Common

class HistoryViewController: UIViewController {

    @IBOutlet weak var boardView: BoardView!
    
    var hive: Hive {
        return Hive.sharedInstance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardView.delegate = self
        
        observe(.structureUpdated, #selector(structureDidUpdate))
        observe(.selectedNodeUpdated, #selector(selectedNodeDidUpdate))
        observe(.availablePositionsUpdated, #selector(availablePositionsDidUpdate))
        observe(.rootNodeMoved, #selector(rootNodeDidMove(_:)))
        observe(.hiveStructureRemoved, #selector(hiveStructureRemoved))
        observe(.themeUpdated, #selector(themeUpdated))
    }
    
    @objc func themeUpdated(_ notification: Notification) {
        boardView.patterns = notification.object! as! [Identity:String]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        boardView.sizeStructureToFit(fillRatio: 0.6)
        boardView.centerHiveStructure()
    }
    
    @IBAction func barButtonTapped(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 0: hive.revert()
        case 1: hive.restore()
        default: break
        }
        boardView.sizeStructureToFit(fillRatio: 0.6)
        boardView.centerHiveStructure()
    }
}

extension HistoryViewController: BoardViewDelegate {
    func didTap(on node: HexNode) {
        if node.color != hive.currentPlayer && node.identity != .dummy {
            post(key: .displayMessage, object: "\(hive.currentPlayer == .black ? "Black" : "White")'s turn")
        }
        let _ = hive.select(node: node)
    }
    
    func didTapOnBoard() {
        hive.cancelSelection()
    }
}

// Bad quality code...
extension HistoryViewController: HiveDelegate {
    func handDidUpdate(hand: Hand, color: Color) {}
    
    func didPlace(newNode: HexNode) {}
    
    func didDeselect() {}
    
    func gameHasEnded() {}
    
    func didWin(player: Color) {}
    
    /// Transfer the updated root structure from hive to boardview for display
    @objc func structureDidUpdate() {
        boardView.root = hive.root
    }
    
    @objc func selectedNodeDidUpdate() {
        boardView.updateSelectedNode(hive.selectedNode)
    }
    
    @objc func availablePositionsDidUpdate() {
        boardView.availablePositions = hive.availablePositions
    }
    
    @objc func rootNodeDidMove(_ notification: Notification) {
        rootNodeDidMove(by: notification.object as! Route)
    }
    
    func rootNodeDidMove(by route: Route) {
        boardView.rootNodeMoved(by: route)
    }
    
    @objc func hiveStructureRemoved() {
        boardView.clear()
    }
    
}
