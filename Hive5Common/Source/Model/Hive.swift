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
public class Hive: Codable {
    
    /**
     There should only be one instance of Hive throughout the application
     */
    public static var sharedInstance: Hive = {
        return Hive()
    }()
    
    public var root: HexNode? {
        didSet {delegate?.structureDidUpdate()}
    }
    
    /**
     Whether the queen is required to be on the board in the first 4 moves.
     Defaults to true.
     */
    public var queen4 = true
    
    /**
     Whether the pieces can move in the first 4 moves.
     */
    public var immobilized4 = true
    
    /**
     Default hand of a player by Hive's rule
     */
    public static let defaultHand: Hand = [
            .grasshopper: 3,
            .queenBee: 1,
            .beetle: 2,
            .spider: 2,
            .soldierAnt: 3
        ]
    
    /**
     Assistive positions that indicated the spacial layout of the physical
     coordinates of the available moves, etc.
     */
    public var availablePositions = [Position]() {
        didSet {delegate?.availablePositionsDidUpdate()}
    }
    
    /**
     The node that is currently selected by the user
     */
    public var selectedNode: HexNode? {
        didSet {delegate?.selectedNodeDidUpdate()}
    }
    
    /**
     Whether the user has selected a new node.
     */
    private var selectedNewNode = false
    
    /**
     Game State
     */
    public var hasEnded = false
    
    public var blackHand: Hand
    public var whiteHand: Hand
    public var currentPlayer: Color = .black
    public var nextPlayer: Color {
        get {return currentPlayer.opposite}
    }
    public var currentHand: Hand {
        get {return currentPlayer == .black ? blackHand : whiteHand}
    }
    public var opponentHand: Hand {
        get {return currentPlayer == .black ? whiteHand : blackHand}
    }
    
    public var history: History
    
    public var delegate: HiveDelegate?
    
    public init() {
        history = History()
        blackHand = Hive.defaultHand
        whiteHand = Hive.defaultHand
    }
    
    /**
     Reset the entire hive to "Factory" state
     Does not forget delegate, however.
     */
    public func reset() {
        history = History()
        blackHand = Hive.defaultHand
        whiteHand = Hive.defaultHand
        root = nil
        currentPlayer = .black
        selectedNewNode = false
        selectedNode = nil
        availablePositions = []
        hasEnded = false
        delegate?.handDidUpdate(hand: blackHand, color: .black)
    }
    
    /**
     Checks if the player violates immobilized4 rule.
     - Returns: False if the rule is violated.
     - Todo: I might have misinterpretted this rule.
     */
    public func canMove(color: Color) -> Bool {
        return !immobilized4 || containsNode{$0.valueEquals(QueenBee(color: color))}
    }
    
    /**
     The hive reacts according to the type of node that is selected and the node that is previously selected.
     1) If QueenBee is previously selected and now a destination node is selected, the hive would
     react by moving QueenBee to the destination node and tell the delegate that the structure has updated.
     - Todo: Implement
     */
    public func select(node: HexNode) -> ExitStatus {
        if hasEnded {
            delegate?.gameHasEnded()
            return .gameEnded
        }
        switch node.identity {
        case .dummy:
            if let selected = selectedNode {
                let available = node.neighbors.available()
                if available.count == 0 { // Special case, first piece!
                    root = selectedNode
                } else {
                    let dest = available[0]
                    let position = Position(node: dest.node, dir: dest.dir.opposite())

                    // If the root moves, then the root coordinate needs to be updated
                    if selected === root {
                        let route = root!.derivePaths().filter{$0.destination === position.node}[0]
                            .route.append([position.dir])
                        delegate?.rootNodeDidMove(by: route)
                    }
                    
                    // Record the move
                    let origins = selected.neighbors.available()
                        .map{Position(node: $0.node, dir: $0.dir.opposite())}
                    history.push(move: Move(selected, from: origins.first, to: position))

                    // Move to the designated position
                    selected.move(to: position)
                }
                
                // If the piece just placed/moved is a new piece, then:
                if selectedNewNode {
                    delegate?.didPlace(newNode: selected)
                    
                    // Update black/white hands
                    let key = selectedNode!.identity
                    switch currentPlayer {
                    case .black: blackHand.updateValue(blackHand[key]! - 1, forKey: key)
                    case .white: whiteHand.updateValue(whiteHand[key]! - 1, forKey: key)
                    }
                    selectedNewNode = false
                }
                
                // Pass the player's turn
                passTurn()
            }
            
            updateGameState() // Detect if a winner has emerged.
            return .normal
        default:
            if node.color != currentPlayer {
                // Prevent the current player from selecting opponent's pieces
                return .tappedWrongNode
            } else if immobilized4 && !canMove(color: currentPlayer) {
                return .violatedImmobilized4
            }
            
            selectedNode = node
            availablePositions = node.uniqueAvailableMoves()
            if selectedNewNode {
                delegate?.didDeselect()
                selectedNewNode = false
            }
            return .normal
        }
    }
    
    public enum ExitStatus {
        case violatedImmobilized4
        case tappedWrongNode
        case gameEnded
        case normal
    }
    
    /**
     Remove used up nodes from each player's hands
     */
    private func removeExhaustedNodes() {
        blackHand.keys.filter{blackHand[$0]! == 0}.forEach {
            blackHand.remove(at: blackHand.index(forKey: $0)!)
        }
        whiteHand.keys.filter{whiteHand[$0]! == 0}.forEach {
            whiteHand.remove(at: whiteHand.index(forKey: $0)!)
        }
    }
    
    /**
     Update the state of the hive based on who's winning/losing.
     */
    public func updateGameState() {
        if let winner = detectWinnder() {
            hasEnded = true
            delegate?.didWin(player: winner)
        }
    }
    
    /**
     - Returns: The color of the winning player; nil if not found.
     */
    public func detectWinnder() -> Color? {
        if let root = root {
            let candidates = root.connectedNodes()
                .filter{$0.identity == .queenBee
                    && $0.neighbors.available().filter{
                            $0.dir.is2D
                        }.count == 6
                }
            if candidates.count == 1 {
                return candidates[0].color.opposite
            }
        }
        return nil
    }
    
    /**
     Selects a new node that is going to be connected to the hive.
     */
    public func select(newNode: HexNode) {
        selectedNode = newNode
        let specialCase = root?.connectedNodes().count == 1
        let color = specialCase ? root!.color : newNode.color
        availablePositions = availablePositions(color: color)
        selectedNewNode = true
    }
    
    /**
     The user has touched blank space between nodes, should cancel selection.
     */
    public func cancelSelection() {
        delegate?.didDeselect()
        selectedNode = nil
        availablePositions = []
        selectedNewNode = false
        if root == nil {
            delegate?.hiveStructureRemoved()
        }
    }
    
    /**
     - Returns: The furthest node in the given direction
     - Parameter from: Starting node
     - Parameter toward: The direction of trasversal propagation
     */
    public static func traverse(from node: HexNode, toward dir: Direction) -> HexNode {
        var path = Path(route: Route(directions: []), destination: node)
        while path.destination.neighbors[dir] != nil {
            let dest = path.destination.neighbors[dir]!
            path = Path(route: path.route.append([dir]), destination: dest)
        }
        return path.destination
    }
    
    /**
     Revert the history of the hive to one step before.
     */
    public func revert() {
        if history.moves.count == 0 {return}
        if let node = history.pop() {
            let identity = node.identity
            switch currentPlayer {
            case .black where whiteHand[identity] != nil: whiteHand[identity]! += 1
            case .black: whiteHand[identity] = 1
            case .white where blackHand[identity] != nil: blackHand[identity]! += 1
            case .white: blackHand[identity] = 1
            }
        }
        passTurn()
    }
    
    /**
     Restore the history of the hive to one step after.
     */
    public func restore() {
        if history.popped.count == 0 {return}
        if let node = history.restore() {
            switch currentPlayer {
            case .black: blackHand[node.identity]! -= 1
            case .white: whiteHand[node.identity]! -= 1
            }
        }
        passTurn()
    }
    
    /**
     Passes the current player's turn
     */
    private func passTurn(handChanged: Bool = true) {
        removeExhaustedNodes()
        if handChanged {
            // Check if any rules are violated, and if, enforce them.
            var hand = opponentHand
            if queen4 && countNodes(criterion: {$0.color == nextPlayer}) == 3
                && !containsNode{$0.identity == .queenBee && $0.color == nextPlayer} {
                // Force the player to delt a queen bee
                hand = [.queenBee : 1]
            }
            // Present the opponent's hand, since it is now the next player's turn
            delegate?.handDidUpdate(hand: hand, color: nextPlayer)
        }
        delegate?.structureDidUpdate()
        selectedNode = nil
        currentPlayer = currentPlayer.opposite
    }
    
    /**
     Positions in the hive in which a new node could be placed at.
     - Parameter color: The color of the new piece.
     */
    public func availablePositions(color: Color) -> [Position] {
        guard let root = root else {return []}
        let positions = root.connectedNodes().filter{$0.neighbors[.below] == nil}.map{node in
            node.neighbors.empty().filter{$0.rawValue < 6}
                .map{Position(node: node, dir: $0)}
            }.flatMap{$0}
        
        var paths = root.derivePaths()
        let path = Path(destination: root, route: Route(directions: []))
        paths.insert(path, at: 0)
        
        // Pair paths with positions
        typealias Pair = (path: Path, pos: Position)
        var paired = [Pair]()
        positions.forEach {position in
            paths.forEach { path in
                if path.destination === position.node {
                    paired.append((path,position))
                }
            }
        }
        
        let uniquePairs = paired.filterDuplicates {
            $0.path.route.append([$0.pos.dir]) == $1.path.route.append([$1.pos.dir])
        }
        
        return uniquePairs.map{$0.pos}.filter{Identity.dummy.new(color: color).canPlace(at: $0)}
    }

    public func pathTo(node: HexNode) -> Path {
        return root!.derivePaths().filter{$0.destination === node}[0]
    }
    
    /**
     Count the number of nodes in the hive that meet the given criterion.
     - Parameter criterion: The criterion by which a node should meet in order to be counted.
     */
    public func countNodes(criterion: (HexNode) -> Bool) -> Int {
        return root?.connectedNodes().filter(criterion).count ?? 0
    }
    
    public func containsNode(criterion: (HexNode) -> Bool) -> Bool {
        return root?.connectedNodes().contains(where: criterion) ?? false
    }

    public required init(from decoder: Decoder) throws{
        history = History()
        root = try Hive.decodeHive(from: decoder)
        (blackHand, whiteHand) = try Hive.decodeHands(from: decoder)
    }
}

public protocol HiveDelegate {
    func structureDidUpdate()
    func selectedNodeDidUpdate()
    func availablePositionsDidUpdate()
    func rootNodeDidMove(by route: Route)
    func hiveStructureRemoved()
    func handDidUpdate(hand: Hand, color: Color)
    func didPlace(newNode: HexNode)
    func didDeselect()
    func gameHasEnded()
    func didWin(player: Color)
}

/**
 This struct is used to represent the available pieces at each player's disposal.
 */
public typealias Hand = [Identity:Int]

public enum Identity: String, CodingKey, Codable {
    
    /**
     A dictionary that defines the symbols that represent each node type
     */
    public static var defaultPatterns: [Identity: String] = [
        .grasshopper: "𝝣",
        .queenBee: "𝝠",
        .beetle: "𝝧",
        .spider: "𝝮",
        .soldierAnt: "𝝭",
        .dummy: "𝝬",
        .mosquito: "𝝨",
        .ladyBug: "𝝳"
    ]
    
    case grasshopper = "Grasshopper"
    case queenBee = "Queen Bee"
    case beetle = "Beetle"
    case spider = "Spider"
    case soldierAnt = "Soldier Ant"
    case dummy = "Dummy"
    case mosquito = "Mosquito"
    case ladyBug = "Lady Bug"
    
    public var defaultPattern: String {
        get {return Identity.defaultPatterns[self]!}
    }
    
    /**
     Construct a new HexNode object based on the type...
     there might be a better way of doing this, but for now this will do.
     - Parameter color: The color of the new node.
     */
    public func new(color: Color) -> HexNode {
        switch self {
        case .grasshopper: return Grasshopper(color: color)
        case .queenBee: return QueenBee(color: color)
        case .beetle: return Beetle(color: color)
        case .spider: return Spider(color: color)
        case .soldierAnt: return SoldierAnt(color: color)
        case .dummy: return HexNode(color: color)
        case .mosquito: return Mosquito(color: color)
        case .ladyBug: return LadyBug(color: color)
        }
    }
}


public protocol IdentityProtocol {
    var identity: Identity {get}
}

public struct Move {
    public var node: HexNode
    public var from: Position?
    public var to: Position
    
    public init(_ node: HexNode, from: Position?, to: Position) {
        self.node = node
        self.from = from
        self.to = to
    }
}

public class History {
    public var moves = [Move]()
    public var popped = [Move]()
    
    /**
     Pops the last move from history stack and restore hive state
     - Returns: A node if the node was added; otherwise nil.
     */
    public func pop() -> HexNode? {
        if moves.count == 0 {return nil}
        let move = moves.removeLast()
        popped.append(move)
        if let from = move.from {
            move.node.move(to: from)
            return nil
        } else {
            move.node.disconnect()
            return move.node
        }
    }
    
    /**
     Restore reverted history
     - Returns: The new node that was placed on the board; otherwise nil.
     */
    public func restore() -> HexNode? {
        if popped.count == 0 {return nil}
        let move = popped.removeLast()
        move.node.move(to: move.to)
        moves.append(move)
        return move.from == nil ? move.node : nil
    }
    
    /**
     Push the move into the history stack.
     */
    public func push(move: Move) {
        moves.append(move)
    }
}
