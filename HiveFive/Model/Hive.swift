//
//  Hive.swift
//  Hive Five
//
//  Created by Jiachen Ren on 3/28/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

/**
 The actual game has no boards, but we need an invisible board that is able to traverse/modify the HexNode ADT.
 */
class Hive {
    var root: HexNode
    
    init(root: HexNode) {
        self.root = root
    }
    
}
