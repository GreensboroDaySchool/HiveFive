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

class HelpItemViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nodeBoard: BoardView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var demonstrationBoard: BoardView!
    
    var nodeDescription: NodeDescription?
    var hive: Hive = {
        let hive = Hive()
        hive.immobilized4 = false // Turn off rule violation checks
        hive.queen4 = false
        return hive
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up help item controller
        demonstrationBoard.backgroundColor = .none
        nodeBoard.backgroundColor = .none
        
        // MARK: delegation
        hive.delegate = self
        demonstrationBoard.delegate = self
        
        if let nodeDescription = nodeDescription {
            hive.root = nodeDescription.demonstration
            demonstrationBoard.root = hive.root
            descriptionTextView.text = nodeDescription.description
            
            // Synchronize theme
            nodeBoard.patterns = designatedTheme().patterns
            demonstrationBoard.patterns = designatedTheme().patterns
            
            let color = Color(rawValue: Int(Double.random() * 2))! // 是不是有点做作了？😂
            nodeBoard.root = nodeDescription.identity.new(color: color)
            nameLabel.text = nodeDescription.identity.rawValue
            hive.root?.connectedNodes()
                .filter{$0.identity == nodeDescription.identity}
                .sorted{$0.availableMoves().count < $1.availableMoves().count}
                .forEach{select(node: $0)}
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        // Configure identity node
        demonstrationBoard.nodeRadius = [30,35,40][nodeSizeIndex()]
        demonstrationBoard.centerHiveStructure()
        demonstrationBoard.rootCoordinate = demonstrationBoard.rootCoordinate.translate(-20, -26)
//        demonstrationBoard.clipsToBounds = true
        
        // Configure demonstration board
        nodeBoard.nodeRadius = nodeBoard.bounds.midX - 5
        nodeBoard.centerHiveStructure()
        nodeBoard.rootCoordinate = nodeBoard.rootCoordinate.translate(-8, -8)
        
        // Scroll to top, thanks to
        // https://stackoverflow.com/questions/28053140/uitextview-is-not-scrolled-to-top-when-loaded
        let contentHeight = descriptionTextView.contentSize.height
        let offSet = descriptionTextView.contentOffset.x
        let contentOffset = contentHeight - offSet
        descriptionTextView.contentOffset = CGPoint(x: 0, y: -contentOffset)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HelpItemViewController: BoardViewDelegate {
    
    /**
     Small hacks make life easier! Select regardless of color
     */
    private func select(node: HexNode) {
        if node.identity == .dummy {return} // Moves are not allowed.
        let preserved = node.color
        node.color = hive.currentPlayer
        let _ = hive.select(node: node)
        node.color = preserved
    }
    
    func didTap(on node: HexNode) {
        select(node: node)
    }
    
    func didTapOnBoard() {
        hive.cancelSelection()
    }
}

extension HelpItemViewController: HiveDelegate {
    func handDidUpdate(hand: Hand, color: Color) {}
    
    func didPlace(newNode: HexNode) {}
    
    func didDeselect() {}
    
    func gameHasEnded() {}
    
    func didWin(player: Color) {}
    

    func structureDidUpdate() {
        demonstrationBoard.root = hive.root
    }
    
    func selectedNodeDidUpdate() {
        demonstrationBoard.updateSelectedNode(hive.selectedNode)
    }
    
    func availablePositionsDidUpdate() {
        demonstrationBoard.availablePositions = hive.availablePositions
    }
    
    func rootNodeDidMove(by route: Route) {
        demonstrationBoard.rootNodeMoved(by: route)
    }
    
    func hiveStructureRemoved() {
        demonstrationBoard.clear()
    }
    
}
