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
     Whether the queen is required to be on the board in the first 4 moves.
     */
    var queenOutInFirstFour = true
    
    /**
     Default hand of a player by Hive's rule
     */
    static let defaultHand: Hand = [
            .grasshopper: 3,
            .queenBee: 1,
            .beetle: 2,
            .spider: 3,
            .soldierAnt: 3
        ]
    
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
    
    private var selectedNewNode = false
    
    var blackHand: Hand
    var whiteHand: Hand
    var currentPlayer: Color = .black
    var nextPlayer: Color {
        get {return currentPlayer.opposite}
    }
    var currentHand: Hand {
        get {return currentPlayer == .black ? blackHand : whiteHand}
    }
    var opponentHand: Hand {
        get {return currentPlayer == .black ? whiteHand : blackHand}
    }
    
    var history: History
    
    var delegate: HiveDelegate?
    
    init() {
        history = History()
        blackHand = Hive.defaultHand
        whiteHand = Hive.defaultHand
    }
    
    /**
     Reset the entire hive to "Factory" state
     Does not forget delegate, however.
     */
    func reset() {
        history = History()
        blackHand = Hive.defaultHand
        whiteHand = Hive.defaultHand
        root = nil
        currentPlayer = .black
        selectedNewNode = false
        selectedNode = nil
        availablePositions = []
        post(name: handUpdateNotification, object: (blackHand,Color.black))
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
                if available.count == 0 { // special case, first piece!
                    root = selectedNode
                } else {
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
                    
                    //record the move
                    //TODO: DEBUG!
                    let origins = selected.neighbors.available()
                        .map{Position(node: $0.node, dir: $0.dir.opposite())}
                    history.push(move: Move(selected, from: origins.first, to: position))
                }
                
                //if the piece just placed/moved is a new piece, then:
                if selectedNewNode {
                    post(name: didPlaceNewPiece, object: nil)
                    
                    //update black/white hands
                    let key = selectedNode!.identity
                    switch currentPlayer {
                    case .black: blackHand.updateValue(blackHand[key]! - 1, forKey: key)
                    case .white: whiteHand.updateValue(whiteHand[key]! - 1, forKey: key)
                    }
                    blackHand.keys.filter{blackHand[$0]! == 0}.forEach {
                        blackHand.remove(at: blackHand.index(forKey: $0)!)
                    }
                    whiteHand.keys.filter{whiteHand[$0]! == 0}.forEach {
                        whiteHand.remove(at: whiteHand.index(forKey: $0)!)
                    }
                    selectedNewNode = false
                }
                post(name: handUpdateNotification, object: (opponentHand,nextPlayer))
                
                delegate?.structureDidUpdate() //notify the delegate that the structure has updated
                currentPlayer = currentPlayer.opposite
            }
        default:
            if node.color != currentPlayer {
                //this prevents current player from selecting opponent's pieces
                return
            }
            selectedNode = node
            availablePositions = node.uniqueAvailableMoves()
            if selectedNewNode {
                post(name: didCancelNewPiece, object: nil)
                selectedNewNode = false
            }
        }
    }
    
    /**
     - Todo: Implement!
     */
    func select(newNode: HexNode) {
        selectedNode = newNode
        let specialCase = root?.connectedNodes().count == 1
        let color = specialCase ? root!.color : newNode.color
        availablePositions = availablePositions(color: color)
        selectedNewNode = true
    }
    
    /**
     The user has touched blank space between nodes, should cancel selection.
     */
    func cancelSelection() {
        selectedNode = nil
        availablePositions = []
        selectedNewNode = false
        post(name: didCancelNewPiece, object: nil)
        if root == nil {
            delegate?.hiveStructureRemoved()
        }
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
        
        func encode(_ hand: Hand) -> NSObject {
            return hand.map{(key: $0.key.rawValue, value: $0.value)}
                .reduce([String:Int]()){(dict: [String:Int], element: (key: String, value: Int)) in
                    var _dict = dict
                    _dict[element.key] = element.value
                    return _dict
                } as NSObject
        }
        
        structure.blackHand = encode(blackHand)
        structure.whiteHand = encode(whiteHand)
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
    static func savedStructures(_ shouldInclude: (HiveStructure) -> Bool = {_ in return true}) -> [HiveStructure] {
        if let structures = try? CoreData.context.fetch(HiveStructure.fetchRequest()) as! [HiveStructure] {
            return structures.filter(shouldInclude)
        }
        return []
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
        
        func decode(_ hand: NSObject) -> Hand {
            return (hand as! [String:Int])
                .keyValuePairs.reduce([Identity:Int]()) {(dict: [Identity:Int], element: (key: String, value: Int)) in
                    var _dict = dict
                    _dict[Identity(rawValue: element.key)!] = element.value
                    return _dict
            }
        }
        
        hive.root = root
        hive.blackHand = decode(structure.blackHand!)
        hive.whiteHand = decode(structure.whiteHand!)
        return hive
    }
    
    /**
     Positions in the hive in which a new node could be placed at.
     - Todo: Debug!!
     - Parameter color: The color of the new piece.
     */
    func availablePositions(color: Color) -> [Position] {
        guard let root = root else {return []}
        var paths = root.derivePaths()
        let path = Path(destination: root, route: Route(directions: []))
        paths.insert(path, at: 0)
        let dummy = Identity.dummy.new(color: color)
        return paths.filter{$0.destination.color == color}
            .map{($0, $0.destination.neighbors.empty())}
            .map{(arg) -> [Path] in
            let (path, dirs) = arg
            return dirs.map{Path(
                destination: path.destination,
                route: path.route.append([$0]))
            }
            }.flatMap{$0}
            .map{$0.route}
            .filterDuplicates(isDuplicate: ==)
            .map{Position.resolve(from: root, following: $0)}
            .filter{dummy.canPlace(at: $0)}
    }
    
    
}

protocol HiveDelegate {
    func structureDidUpdate()
    func selectedNodeDidUpdate()
    func availablePositionsDidUpdate()
    func rootNodeDidMove(by route: Route)
    func hiveStructureRemoved()
}

/**
 This struct is used to represent the available pieces at each player's disposal.
 */
typealias Hand = [Identity:Int]

enum Identity: String {
    
    /**
     A dictionary that defines the symbols that represent each node type
     */
    static var defaultPatterns: [Identity:String] = [
        .grasshopper:"𝝣",
        .queenBee:"𝝠",
        .beetle:"𝝧",
        .spider:"𝝮",
        .soldierAnt:"𝝭",
        .dummy:"𝝬"
    ]
    
    case grasshopper = "Grasshopper"
    case queenBee = "Queen Bee"
    case beetle = "Beetle"
    case spider = "Spider"
    case soldierAnt = "Soldier Ant"
    case dummy = "Dummy"
    
    var defaultPattern: String {
        get {return Identity.defaultPatterns[self]!}
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
}


protocol IdentityProtocol {
    var identity: Identity {get}
}

struct Move {
    var node: HexNode
    var from: Position?
    var to: Position
    
    init(_ node: HexNode, from: Position?, to: Position) {
        self.node = node
        self.from = from
        self.to = to
    }
}

class History {
    var moves = [Move]()
    
    /**
     Pops the last move from history stack and restore hive state
     - Returns: A node is the node was added; otherwise nil.
     */
    func pop() -> HexNode? {
        if moves.count == 0 {return nil}
        let move = moves.removeLast()
        if let from = move.from {
            move.node.move(to: from)
            return nil
        } else {
            move.node.disconnect()
            return move.node
        }
    }
    
    /**
     Push the move into the history stack.
     */
    func push(move: Move) {
        moves.append(move)
    }
}
