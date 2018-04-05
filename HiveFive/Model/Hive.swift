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
            if let selected = selectedNode {
                let available = node.neighbors.available()
                assert(available.count == 1)
                let dest = available[0]
                let position = Position(node: dest.node, dir: dest.dir.opposite())

                // if the root moves, then the root coordinate needs to be updated
                if selected === root {
                    let route = root!.derivePaths().filter{$0.destination === position.node}[0]
                        .route.append([position.dir])
                    delegate?.rootNodeDidMove(by: route)
                }

                //move to the designated position
                selected.move(to: position)
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
    
    /**
     Serialize the structure of the hive and store it in core data.
     - Parameter name: Name of the newly saved hive structure
     */
    func save(name: String) {
        guard let root = root else {return}
        var paths = root.derivePaths()
        let context = CoreData.context
        paths.insert(Path(route: Route(directions: []), destination: root), at: 0)
        let encoded = paths.map{($0.destination.identity.rawValue, $0.route.encode())}
        let structure = HiveStructure(context: context)
        let pieces = encoded.map{$0.0}
        let routes = encoded.map{$0.1}
        let colors = root.connectedNodes().map{$0.color.rawValue} // black == 0
        structure.pieces = pieces as NSObject // [String]
        structure.routes = routes as NSObject // [[Int]]
        structure.colors = colors as NSObject // [Int]
        structure.name = name
        
        var id: Int16 = 0
        if let retrivedID = Utils.retrieveFromUserDefualt(key: "hiveStructId") as? Int16 {
            id = retrivedID + 1
        }
        Utils.saveToUserDefault(obj: id, key: "hiveStructId")
        structure.id = id
        
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    /**
     Retrieve saved hive structures from core data.
     - Parameter shouldInclude: Whether the HiveStructure should be returned as part of the results.
     */
    static func savedStructures(_ shouldInclude: (HiveStructure) -> Bool = {_ in return true}) -> [HiveStructure]? {
        if let structures = try? CoreData.context.fetch(HiveStructure.fetchRequest()) as! [HiveStructure] {
            return structures.filter(shouldInclude)
        }
        return nil
    }
    
    /**
     Retrives & loads a serialized HiveStructure and convert it to a Hive object
     - Parameter structure: The hive structure to be retrived from core data and reconstructed to a Hive object
     */
    static func load(_ structure: HiveStructure) -> Hive {
        let hive = Hive()
        let pieces = structure.pieces as! [String]
        let colors = (structure.colors as! [Int]).map{Color(rawValue: $0)!}
        let nodes = zip(pieces, colors).map{Identity(rawValue: $0.0)!.new(color: $0.1)}
        let routes = (structure.routes as! [[Int]]).map{Route.decode($0)}
        var paths = zip(nodes, routes).map{Path(route: $0.1, destination: $0.0)}
        
        let root = paths.removeFirst().destination
        paths.forEach {path in
            let position = Position.resolve(from: root, following: path.route)
            path.destination.move(to: position)
        }
        
        hive.root = root
        return hive
    }
    
    
    
}

protocol HiveDelegate {
    func structureDidUpdate()
    func selectedNodeDidUpdate()
    func availablePositionsDidUpdate()
    func rootNodeDidMove(by route: Route)
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
    
    /**
     A dictionary that defines the symbols that represent each node type
     */
    static var symbols: [Identity:String] = [
        .grasshopper:"𝝣",
        .queenBee:"𝝠",
        .beetle:"𝝧",
        .spider:"𝝮",
        .soldierAnt:"𝝭",
        .dummy:"𝝬"
    ]
    
    case grasshopper
    case queenBee
    case beetle
    case spider
    case soldierAnt
    case dummy
    
    var symbol: String {
        get {return Identity.symbols[self]!}
    }
    
    /**
     Construct a new HexNode object based on the type...
     there might be a better way of doing this, but for now this will do.
     - Parameter color: The color of the new node.
     */
    func new(color: Color) -> HexNode {
        switch self {
        case .grasshopper: return Grasshopper(color: color)
        case .queenBee: return QueenBee(color: color)
        case .beetle: return Beetle(color: color)
        case .spider: return Spider(color: color)
        case .soldierAnt: return SoldierAnt(color: color)
        case .dummy: return HexNode(color: color)
        }
    }
    
//    case grasshopper = "蜢", queenBee = "皇", beetle = "甲", spider = "蛛", soldierAnt = "蚁", dummy = "笨"
//    case grasshopper = "✡︎", queenBee = "✪", beetle = "✶", spider = "★", soldierAnt = "✩", dummy = "▲"
//    case grasshopper = "𝔾", queenBee = "ℚ", beetle = "𝔹", spider = "𝕊", soldierAnt = "𝔸", dummy = "𝔻"
//    case grasshopper = "𝜞", queenBee = "𝜟", beetle = "𝜭", spider = "𝜮", soldierAnt = "𝜴", dummy = "𝜩"
//    case grasshopper = "𝞝", queenBee = "𝞡", beetle = "𝞨", spider = "𝞚", soldierAnt = "𝞧", dummy = "𝞦"
//    case grasshopper = "♞", queenBee = "♛", beetle = "♟", spider = "♝", soldierAnt = "♜", dummy = "♚"
//    case grasshopper = "♘", queenBee = "♕", beetle = "♙", spider = "♗", soldierAnt = "♖", dummy = "♔"
//      case grasshopper = "$", queenBee = "€", beetle = "¥", spider = "¢", soldierAnt = "£", dummy = "₽"
//    case grasshopper = "😀", queenBee = "😆", beetle = "🙃", spider = "🤪", soldierAnt = "😎", dummy = "🤩"
}


protocol IdentityProtocol {
    var identity: Identity {get}
}
