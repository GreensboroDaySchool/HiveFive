//
//  Hive+Encodable.swift
//  Hive Five
//
//  Created by Marcus Zhou on 4/27/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

extension Hive{
    enum HFHiveCoderKeys: String, CodingKey {
        case rootNode
        case references
        case blackHands
        case whiteHands
        
        enum HFHiveNodeCoderKeys: String, CodingKey{
            case identifier
            case identity
            case color
            case neighbors
        }
    }
    
    var allNodes: Set<HexNode>? {
        guard let root = root else { return nil }
        var set = Set<HexNode>()
        var processing = [HexNode]()
        processing.append(root)
        while !processing.isEmpty {
            let current = processing.removeFirst()
            set.insert(current)
            current.neighbors.nodes
                .filter{ return $0 !== nil && !set.contains($0!) }
                .forEach{ processing.append($0!) }
        }
        return set.count > 0 ? set : nil
    }
    
    func encode(to coder: Encoder) throws {
        guard let root = root else { throw HFCodingError.encodingError("root node not defined") }
        guard let nodes = allNodes else { throw HFCodingError.encodingError("nodes not defined") }
        var container = coder.container(keyedBy: HFHiveCoderKeys.self)
        
        //encode all the objects
        var referencesContainer = container.nestedUnkeyedContainer(forKey: .references)
        try nodes.forEach{
            node in
            var nodeContainer = referencesContainer.nestedContainer(keyedBy: HFHiveCoderKeys.HFHiveNodeCoderKeys.self)
            
            let hashes = node.neighbors.nodes.map{
                (node) -> Int in
                guard let hash = node?.hashValue else { return 0 }
                return hash
            }
            
            try nodeContainer.encode(node.hashValue, forKey: .identifier)
            try nodeContainer.encode(node.color.rawValue, forKey: .color)
            try nodeContainer.encode(node.identity.rawValue, forKey: .identity)
            try nodeContainer.encode(hashes, forKey: .neighbors)
        }
        
        //encode root reference
        try container.encode(root.hashValue, forKey: .rootNode)
        
        //encode hands
        var blackHandContainer = container.nestedContainer(keyedBy: Identity.self, forKey: .blackHands)
        try blackHand.forEach{ try blackHandContainer.encode($0.value, forKey: $0.key) }
        var whiteHandContainer = container.nestedContainer(keyedBy: Identity.self, forKey: .whiteHands)
        try whiteHand.forEach{ try whiteHandContainer.encode($0.value, forKey: $0.key)}
    }
}

extension Hive {
    static func decodeHive(from coder: Decoder) throws -> HexNode {
        var nodes = [Int:(HexNode,[Int])]()
        let container = try coder.container(keyedBy: HFHiveCoderKeys.self)
        var referencesContainer = try container.nestedUnkeyedContainer(forKey: .references)
        
        //First, instantiate all nodes
        while !referencesContainer.isAtEnd {
            let nodeContainer = try referencesContainer.nestedContainer(keyedBy: HFHiveCoderKeys.HFHiveNodeCoderKeys.self)
            
            guard let color = Color(rawValue: try nodeContainer.decode(Color.RawValue.self, forKey: .color)) else {
                throw HFCodingError.decodingError("invalid stored value for color")
            }
            guard let identity = Identity(rawValue: try nodeContainer.decode(Identity.RawValue.self, forKey: .identity)) else {
                throw HFCodingError.decodingError("invalid stored value for identity")
            }
            let hashValue = try nodeContainer.decode(Int.self, forKey: .identifier)
            let neighbors = try nodeContainer.decode([Int].self, forKey: .neighbors)
            
            let node = identity.new(color: color)
            node.hashValue = hashValue
            nodes[hashValue] = (node, neighbors)
        }
        
        //Then, connects hive structures
        nodes.forEach{
            current in
            current.value.0.neighbors.nodes = current.value.1.map{
                hash -> HexNode? in
                if hash != 0 {
                    if let neighborNode = nodes[hash]?.0 { return neighborNode }
                }
                return nil
            }
        }
        
        //Last, obtain the root node from nodes pool
        let rootHash = try container.decode(Int.self, forKey: .rootNode)
        guard let root = nodes[rootHash]?.0 else { throw HFCodingError.decodingError("root node not found from hash") }
        
        return root
    }
    
    static func decodeHands(from coder: Decoder) throws -> (black: Hand, white: Hand) {
        let container = try coder.container(keyedBy: HFHiveCoderKeys.self)
        let blackHandsContainer = try container.nestedContainer(keyedBy: Identity.self, forKey: .blackHands)
        var blackHand = Hand()
        try blackHandsContainer.allKeys.forEach{ blackHand[$0] = try blackHandsContainer.decode(Int.self, forKey: $0) }
        let whiteHandsContainer = try container.nestedContainer(keyedBy: Identity.self, forKey: .whiteHands)
        var whiteHand = Hand()
        try whiteHandsContainer.allKeys.forEach{ whiteHand[$0] = try whiteHandsContainer.decode(Int.self, forKey: $0) }
        return (blackHand, whiteHand)
    }
}

extension HexNode: Hashable {
    static func == (lhs: HexNode, rhs: HexNode) -> Bool { return lhs.hashValue == rhs.hashValue }
}

extension Identity: CodingKey, Codable { }
extension GameState: Codable { }
extension Color: Codable { }

enum HFCodingError: Error {
    case decodingError(String)
    case encodingError(String)
}
