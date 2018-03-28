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
class HexNode: NodeProtocol {
    var nodes = [HexNode?](repeating: nil, count: 6)

    var north: HexNode? {
        get {
            return nodes[0]
        }
        set {
            nodes[0] = newValue
        }
    }
    var northWest: HexNode? {
        get {
            return nodes[1]
        }
        set {
            nodes[1] = newValue
        }
    }
    var northEast: HexNode? {
        get {
            return nodes[2]
        }
        set {
            nodes[2] = newValue
        }
    }
    var south: HexNode? {
        get {
            return nodes[3]
        }
        set {
            nodes[3] = newValue
        }
    }
    var southWest: HexNode? {
        get {
            return nodes[4]
        }
        set {
            nodes[4] = newValue
        }
    }
    var southEast: HexNode? {
        get {
            return nodes[5]
        }
        set {
            nodes[5] = newValue
        }
    }

    init() {

    }

}

protocol NodeProtocol {
    var north: HexNode? { get set }
    var northEast: HexNode? {get set}
    var northWest: HexNode? {get set}
    var south: HexNode? {get set}
    var southEast: HexNode? {get set}
    var southWest: HexNode? {get set}
}