//
//  SoldierAnt.swift
//  Hive Five
//
//  Created by Jiachen Ren on 3/28/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

public class SoldierAnt: HexNode {
    override public var identity: Identity {
        return .soldierAnt
    }

    override public func availableMoves() -> [Position] {
        if (!canDisconnect()) {
            // if disconnecting the piece breaks the structure, then there are no available moves.
            return [Position]()
        }

        // can go to anywhere outside the hive, can't squeeze into tiny openings though
        var traversed = [Position]()
        var destinations = [Position]()
        resolvePositions(&traversed, &destinations)
        return destinations.filterDuplicates(isDuplicate: ==) // will do for now
    }

    private func resolvePositions(_ traversed: inout [Position], _ destinations: inout [Position]) {
        traversed.append(contentsOf: neighbors.present()
            .map{Position(node: $0.node, dir: $0.dir.opposite())})
        let firstRoutes = oneStepMoves()
        let firstPositions = firstRoutes.map{Position.resolve(from: self, following: $0)}
        let filtered = firstPositions.filter{!traversed.contains($0)}
        if filtered.count == 0 { // base case
            return
        }
        destinations.append(contentsOf: filtered) // add current destinations
        filtered.forEach{destination in
            let neighbor = neighbors.present()[0]
            let anchor = Position(node: neighbor.node, dir: neighbor.dir.opposite())
            self.move(to: destination) // move to next destination
            resolvePositions(&traversed, &destinations) // derive next step
            self.move(to: anchor) // move back to previous location
        }
    }
}
