//
//  Grasshopper.swift
//  Hive Five
//
//  Created by Jiachen Ren on 3/28/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//


import Foundation

public class Grasshopper: HexNode {
    override public var identity: Identity {
        return .grasshopper
    }
    
    
    override public func availableMoves() -> [Position] {
        if (!canDisconnect()) {
            // if disconnecting the piece breaks the structure, then there are no available moves.
            return [Position]()
        }
        
        return Direction.xyDirections
            .map{explore(dir: $0)}
            .filter{$0 != nil}
            .map{$0!}
    }
    
    private func explore(dir: Direction) -> Position? {
        guard var node = neighbors[dir] else {
            return nil
        }
        while node.neighbors[dir] != nil {
            node = node.neighbors[dir]!
        }
        return Position(node: node, dir: dir)
    }
}
