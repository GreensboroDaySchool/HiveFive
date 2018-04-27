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
        guard let nodes = allNodes else { return }
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
        try container.encode(root!.hashValue, forKey: .rootNode)
        
        //encode hands
        var blackHandContainer = container.nestedContainer(keyedBy: Identity.self, forKey: .blackHands)
        try blackHand.forEach{ try blackHandContainer.encode($0.value, forKey: $0.key) }
        var whiteHandContainer = container.nestedContainer(keyedBy: Identity.self, forKey: .whiteHands)
        try whiteHand.forEach{ try whiteHandContainer.encode($0.value, forKey: $0.key)}
    }
}

extension HexNode: Hashable {
    var hashValue: Int { return ObjectIdentifier(self).hashValue }
    
    static func == (lhs: HexNode, rhs: HexNode) -> Bool { return lhs.hashValue == rhs.hashValue }
}

extension Identity: CodingKey {}
