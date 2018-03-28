//
//  HexNode.swift
//  Hive Five
//
//  Created by Jiachen Ren on 3/27/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

/**
 This is the parent of Hive, QueenBee, Beetle, Grasshopper, Spider, and SoldierAnt, since all of them are pieces that together consist a hexagonal board.
 */
class HexNode {
    var north: HexNode?
    var northWest: HexNode?
    var northEast: HexNode?
    var south: HexNode?
    var southWest: HexNode?
    var southEast: HexNode?
    
    init() {
        
    }
    
}
