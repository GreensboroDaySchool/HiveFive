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
                let queenBee = QueenBee(color: .black)
                let beetle = Beetle(color: .white)
                let soldierAnt = SoldierAnt(color: .black)
                let spider = Spider(color: .white)
                let spider2 = Spider(color: .black)
                
                beetle2.connect(with: spider, at: .upRight)
                
                grasshopper.connect(with: spider, at: .down) // grasshopper is beneath the spider
                queenBee.connect(with: grasshopper, at: .downRight) // queen bee is to the lower right of grasshopper
                beetle.connect(with: grasshopper, at: .downLeft) // beetle is to the lower left of grass hopper
                
                soldierAnt.connect(with: beetle, at: .down) // soldier ant is beneath beetle
                soldierAnt.connect(with: spider2, at: .downLeft) // soldier ant is also lower left of spider2
                
                spider2.connect(with: grasshopper, at: .down) // spider2 is right beneath grasshopper
                //in real world scenario, spider2 is also lower right of beetle and lower left of queen bee
                spider2.connect(with: queenBee, at: .downLeft) // spider2 is also lower left of queen bee
                spider2.connect(with: beetle, at: .downRight) // spider2 is also lower right of beetle
                
                SoldierAnt(color: .white).move(to: .down, of: spider2)
                QueenBee(color: .white).move(to: .up, of: beetle)
                Grasshopper(color: .black).move(to: .down, of: queenBee)
                
                let hive = Hive()
                hive.root = spider
                hive.save(name: "#default")
                return hive
            }
            return load(retrieved[0])
    }()
}
