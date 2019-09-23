//
//  Mosquito.swift
//  HiveFive Core
//
//  Created by Jiachen Ren on 5/1/19.
//  Copyright © 2019 Greensboro Day School. All rights reserved.
//

import Foundation

/// Mosquito can mimic any of its adjacent pieces
/// If mosquito mimics a beetle and gets on top of the hive structure,
/// then it stays as a beetle until it gets down.
public class Mosquito: HexNode {
    
    override public var identity: Identity {
        return .mosquito
    }
    
    /// Find available moves by mimicing all of its neighbors
    override public func _availableMoves() -> [Position] {
        let neighbors = self.neighbors.present()
        
        // If the mosquito is currently on top of the hive, then it moves as a beetle until it gets down.
        if let base = self.neighbors[.bottom] {
            self.disconnect()
            let beetle = Identity.beetle.new(color: color)
            beetle.move(to: .top, of: base)
            let positions = beetle._availableMoves()
            beetle.disconnect()
            self.move(to: .top, of: base)
            return positions
        }
        
        // Mimics the behavior of any adjacent pieces
        var positions = [Position]()
        self.disconnect()
        for (dir, target) in neighbors {
            if target.identity == .mosquito {
                // A mosquito cannot mimic another mosquito
                continue
            }
            let mimic = target.identity.new(color: color)
            mimic.move(to: dir.opposite(), of: target)
            positions.append(contentsOf: mimic._availableMoves())
            mimic.disconnect()
        }
        let (dir, neighbor) = neighbors.first!
        self.move(to: dir.opposite(), of: neighbor)
        
        return positions
    }
}
