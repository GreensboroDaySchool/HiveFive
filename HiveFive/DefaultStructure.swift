/**
 *
 *  This file is part of Hive Five.
 *
 *  Hive Five is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Hive Five is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Hive Five.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import Foundation
import Hive5Common

/**
 Default hive structure for viewing/debugging purposes
 */
extension Hive {
    static var defaultHive = {() -> Hive in
            let retrieved = savedStructures{$0.name == "#default"}
            if retrieved.count == 0 {
                let hive = makeNewDefaultHive()
                hive.save(name: "#default")
                return hive
            }
            return load(retrieved[0])
    }()
    
    static func makeNewDefaultHive() -> Hive {
        let ladyBug = LadyBug(color: .black)
        let grasshopper = Grasshopper(color: .white)
        let soldierAnt = SoldierAnt(color: .black)
        let beetle = Beetle(color: .black)
        let queenBee = QueenBee(color: .white)
        let spider = Spider(color: .white)
        let spider2 = Spider(color: .black)
        
        ladyBug.move(to: .lowerRight, of: spider)
        
        grasshopper.move(to: .down, of: spider) // grasshopper is beneath the spider
        soldierAnt.move(to: .lowerRight, of: grasshopper) // queen bee is to the lower right of grasshopper
        beetle.move(to: .lowerLeft, of: grasshopper) // beetle is to the lower left of grass hopper
        queenBee.move(to: .down, of: beetle) // soldier ant is beneath beetle
        spider2.move(to: .down, of: grasshopper) // spider2 is right beneath grasshopper
        
        SoldierAnt(color: .white).move(to: .down, of: spider2)
        Mosquito(color: .white).move(to: .upperLeft, of: beetle)
        Grasshopper(color: .black).move(to: .lowerLeft, of: beetle)
        
        let hive = Hive()
        hive.root = spider
        
        let blackHand: [Identity: Int] = [.grasshopper: 2, .queenBee: 1, .soldierAnt: 3, .beetle: 2]
        let whiteHand: [Identity: Int] = [.grasshopper: 2, .queenBee: 1, .soldierAnt: 3, .beetle: 2]
        hive.blackHand = blackHand
        hive.whiteHand = whiteHand
        return hive
    }
}
