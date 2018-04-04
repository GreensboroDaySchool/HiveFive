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

import Foundation

/**
 The actual game has no boards, but we need an invisible board that is able to traverse/modify the HexNode ADT.
 This is the Model of the MVC design pattern
 */
class Hive {
    
    /**
     There should only be one instance of Hive throughout the application
     */
    static var sharedInstance: Hive = {
        return Hive()
    }()
    
    var root: HexNode? {
        didSet {delegate?.structureDidUpdate()}
    }
    
    /**
     Assistive positions that indicated the spacial layout of the physical
     coordinates of the available moves, etc.
     */
    var availablePositions = [Position]() {
        didSet {delegate?.availablePositionsDidUpdate()}
    }
    
    /**
     The node that is currently selected by the user
     */
    var selectedNode: HexNode? {
        didSet {delegate?.selectedNodeDidUpdate()}
    }
    
    var blackHand: Hand
    var whiteHand: Hand
    var delegate: HiveDelegate?
    
    init() {
        blackHand = Hand()
        whiteHand = Hand()
    }
    
    /**
     The hive reacts according to the type of node that is selected and the node that is previously selected.
     1) If QueenBee is previously selected and now a destination node is selected, the hive would
     react by moving QueenBee to the destination node and tell the delegate that the structure has updated.
     - Todo: Implement
     */
    func select(node: HexNode) {
        switch node.identity {
        case .dummy:
            if selectedNode != nil {
                let available = node.neighbors.available()
                assert(available.count == 1)
                let dest = available[0]
                let position = Position(node: dest.node, dir: dest.dir.opposite())
                selectedNode!.move(to: position)
                delegate?.structureDidUpdate()
            }
        default:
            selectedNode = node
            availablePositions = node.uniqueAvailableMoves()
        }
    }
    
    /**
     The user has touched blank space between nodes, should cancel selection.
     */
    func cancelSelection() {
        selectedNode = nil
        availablePositions = []
    }
    
    /**
     - Returns: The furthest node in the given direction
     - Parameter from: Starting node
     - Parameter toward: The direction of trasversal propagation
     */
    static func traverse(from node: HexNode, toward dir: Direction) -> HexNode {
        var path = Path(route: Route(directions: []), destination: node)
        while path.destination.neighbors[dir] != nil {
            let dest = path.destination.neighbors[dir]!
            path = Path(route: path.route.append([dir]), destination: dest)
        }
        return path.destination
    }
    
}

protocol HiveDelegate {
    func structureDidUpdate()
    func selectedNodeDidUpdate()
    func availablePositionsDidUpdate()
}

/**
 This struct is used to represent the available pieces at each player's disposal.
 */
struct Hand {
    var grasshoppers = 3
    var queenBees = 1
    var beetles = 2
    var spiders = 2
    var soldierAnts = 3
}

enum Identity: String {
//    case grasshopper = "蜢", queenBee = "皇", beetle = "甲", spider = "蛛", soldierAnt = "蚁", dummy = "笨"
//    case grasshopper = "✡︎", queenBee = "✪", beetle = "✶", spider = "★", soldierAnt = "✩", dummy = "▲"
//    case grasshopper = "𝔾", queenBee = "ℚ", beetle = "𝔹", spider = "𝕊", soldierAnt = "𝔸", dummy = "𝔻"
//    case grasshopper = "𝜞", queenBee = "𝜟", beetle = "𝜭", spider = "𝜮", soldierAnt = "𝜴", dummy = "𝜩"
//    case grasshopper = "𝞝", queenBee = "𝞡", beetle = "𝞨", spider = "𝞚", soldierAnt = "𝞧", dummy = "𝞦"
//    case grasshopper = "𝝣", queenBee = "𝝠", beetle = "𝝧", spider = "𝝮", soldierAnt = "𝝭", dummy = "𝝬"
//    case grasshopper = "♞", queenBee = "♛", beetle = "♟", spider = "♝", soldierAnt = "♜", dummy = "♚"
    case grasshopper = "♘", queenBee = "♕", beetle = "♙", spider = "♗", soldierAnt = "♖", dummy = "♔"
//      case grasshopper = "$", queenBee = "€", beetle = "¥", spider = "¢", soldierAnt = "£", dummy = "₽"
//    case grasshopper = "😀", queenBee = "😆", beetle = "🙃", spider = "🤪", soldierAnt = "😎", dummy = "🤩"
}

protocol IdentityProtocol {
    var identity: Identity {get}
}
