//
//  Mosquito.swift
//  Hive5CommoniOS
//
//  Created by Jiachen Ren on 5/1/19.
//  Copyright © 2019 Greensboro Day School. All rights reserved.
//

import Foundation

/// Mosquito mimics  any of its adjacent pieces
/// If mosquito mimics a beetle and gets on top of the hive structure,
/// then it stays as a beetle until it gets down.
public class Mosquito: HexNode {
    
    override public var identity: Identity {
        return .mosquito
    }
}
