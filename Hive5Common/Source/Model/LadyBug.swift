//
//  LadyBug.swift
//  Hive5CommoniOS
//
//  Created by Jiachen Ren on 5/1/19.
//  Copyright © 2019 Greensboro Day School. All rights reserved.
//

import Foundation

/// Lady bug moves on top of the hive structure for two steps, then move down
/// the hive structure in the last step.
public class LadyBug: HexNode {
    
    override public var identity: Identity {
        return .ladyBug
    }
    
    override public func _availableMoves() -> [Position] {
        var traversed = [Position]()
        let positions =  findPositions(&traversed, 2)
        return positions
    }
    
    private func findPositions(_ traversed: inout [Position], _ remaining: Int) -> [Position] {
        
        // Remember the traversed positions to prevent going backward
        traversed.append(contentsOf: self.neighbors.present().map {
            Position(node: $0.node, dir: $0.dir.opposite())
        })
        
        // Base case
        if remaining == 0 {
            let base = Hive.traverse(from: self, toward: .bottom)
            return base.neighbors.empty().map {
                Position(node: base, dir: $0)
                }.filter {
                    !traversed.contains($0) && $0.dir.is2D
            }
        }
        
        var positions = [Position]()
        let base = Hive.traverse(from: self, toward: .bottom)
        print(base === self)
        let baseNeighbors = base.neighbors.present().filter {
            $0.dir.is2D
        }
        let neighbor = self.neighbors.present()[0]
        let anchor = Position(node: neighbor.node, dir: neighbor.dir.opposite())
        for (_, node) in baseNeighbors {
            let topNeighbor = Hive.traverse(from: node, toward: .top)
            let dest = Position(node: topNeighbor, dir: .top)
            if traversed.contains(dest) {
                continue
            }
            self.move(to: dest)
            var branch = traversed
            positions.append(contentsOf: findPositions(&branch, remaining - 1))
            self.move(to: anchor)
        }
        
        return positions
    }
}
