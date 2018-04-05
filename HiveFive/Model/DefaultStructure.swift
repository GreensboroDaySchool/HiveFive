//
//  DefaultStructure.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/5/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

/**
 Default hive structure for viewing/debugging purposes
 */
extension Hive {
    static var defaultHive = {() -> Hive in
            let retrieved = savedStructures{$0.name == "#default"}
            if retrieved.count == 0 {
                let beetle2 = Beetle(color: .black)
                let grasshopper = Grasshopper(color: .white)
                let soldierAnt = SoldierAnt(color: .black)
                let beetle = Beetle(color: .black)
                let queenBee = QueenBee(color: .white)
                let spider = Spider(color: .white)
                let spider2 = Spider(color: .black)
                
                beetle2.move(to: .downRight, of: spider)
                
                grasshopper.move(to: .down, of: spider) // grasshopper is beneath the spider
                soldierAnt.move(to: .downRight, of: grasshopper) // queen bee is to the lower right of grasshopper
                beetle.move(to: .downLeft, of: grasshopper) // beetle is to the lower left of grass hopper
                queenBee.move(to: .down, of: beetle) // soldier ant is beneath beetle
                spider2.move(to: .down, of: grasshopper) // spider2 is right beneath grasshopper
                
                SoldierAnt(color: .white).move(to: .down, of: spider2)
                QueenBee(color: .white).move(to: .upLeft, of: beetle)
                Grasshopper(color: .black).move(to: .downLeft, of: beetle)
                
                let hive = Hive()
                hive.root = spider
                hive.save(name: "#default")
                return hive
            }
            return load(retrieved[0])
    }()
}
