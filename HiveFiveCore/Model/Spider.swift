//
//  Spider.swift
//  Hive Five
//
//  Created by Jiachen Ren on 3/28/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

public class Spider: HexNode {
    override public var identity: Identity {
        return .spider
    }
    
    private let numMoves = 3
    
    override public func _availableMoves() -> [Position] {
        var traversed = [Position]()
        let destinations = resolvePositions(&traversed, numMoves)
        
        return destinations
    }
    
    /// Spiders move three steps at a time, and it cannot go back to previous locations!
    private func resolvePositions(_ traversed: inout [Position], _ remaining: Int) -> [Position] {
        registerTraversed(&traversed, self)
        let firstRoutes = oneStepMoves()
        let firstPositions = firstRoutes.map {Position.resolve(from: self, following: $0)}
        
        // Base case
        if remaining == 0 {
            let location = neighbors.present()[0]
            return [Position(node: location.node, dir: location.dir.opposite())]
        }
        
        return firstPositions.filter {
            // Cannot go back to previous location
            !traversed.contains($0)
            }.map {position -> [Position] in
                let neighbor = neighbors.present()[0]
                let anchor = Position(node: neighbor.node, dir: neighbor.dir.opposite())
                
                // Move to next destination
                self.move(to: position)
                
                // This guarantees that traversals in different routes don't interfere with each other!
                // (Fixes a crucial bug)
                var branch = traversed
                
                // Recursively derive next step
                let positions = resolvePositions(&branch, remaining - 1)
                
                // Move back to previous location
                self.move(to: anchor)
                return positions
            }.flatMap{$0}
    }
    
    private func registerTraversed(_ traversed: inout [Position], _ node: HexNode) {
        traversed.append(contentsOf: node.neighbors.present()
            .map{Position(node: $0.node, dir: $0.dir.opposite())})
    }
}
