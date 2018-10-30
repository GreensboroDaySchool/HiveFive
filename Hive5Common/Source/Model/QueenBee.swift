//
//  QueenBee.swift
//  Hive Five
//
//  Created by Jiachen Ren on 3/28/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//


import Foundation

public class QueenBee: HexNode {
    
    override public var identity: Identity {
        return .queenBee
    }

    override public func availableMoves() -> [Position] {
        if (!canDisconnect()) {
            // if disconnecting the piece breaks the structure, then there are no available moves.
            return [Position]()
        }
        return oneStepMoves().map{Position.resolve(from: self, following: $0)}
    }
}
