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

import XCTest
@testable import Hive_Five

class HiveFive_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testNeighborsReferencesEquals() {
        let node1 = Grasshopper()
        let node2 = Spider()
        
        var n1 = Neighbors()
        var n2 = Neighbors()
        n1[.down] = node1
        n2[.down] = node2
        assert(!n1.equals(n2))
        n2[.down] = node1
        assert(n1.equals(n2))
    }

    func testNeighborsContains() {
        let node1 = Grasshopper()
        let node2 = Spider()

        var n1 = Neighbors()
        n1[.down] = node1
        n1[.up] = node2
        assert(n1.contains(node2) == .up)
    }

    func testCanMove() {
        let grasshopper = Grasshopper()
        let spider = Spider()
        let queenBee = QueenBee()
        let beetle = Beetle()
        let soldierAnt = SoldierAnt()
        let spider2 = Spider()

        //testing HexNode::numConnected
        grasshopper.connect(with: spider, at: .down) // grasshopper is beneath the spider
        assert(spider.numConnected() == 2)
        assert(grasshopper.numConnected() == 2)
        queenBee.connect(with: grasshopper, at: .downRight) // queen bee is to the lower right of grasshopper
        assert(spider.numConnected() == 3)
        assert(grasshopper.numConnected() == 3)
        assert(queenBee.numConnected() == 3)
        beetle.connect(with: grasshopper, at: .downLeft) // beetle is to the lower left of grass hopper
        assert(spider.numConnected() == 4)
        assert(grasshopper.numConnected() == 4)
        assert(queenBee.numConnected() == 4)
        assert(beetle.numConnected() == 4)
        soldierAnt.connect(with: beetle, at: .down) // soldier ant is beneath beetle
        assert(spider.numConnected() == 5)
        assert(grasshopper.numConnected() == 5)
        assert(queenBee.numConnected() == 5)
        assert(beetle.numConnected() == 5)
        assert(soldierAnt.numConnected() == 5)
        spider2.connect(with: grasshopper, at: .down) // spider2 is right beneath grasshopper
        assert(spider.numConnected() == 6)
        assert(grasshopper.numConnected() == 6)
        assert(queenBee.numConnected() == 6)
        assert(beetle.numConnected() == 6)
        assert(soldierAnt.numConnected() == 6)
        assert(spider2.numConnected() == 6)
         // including the top spider, there are 6 pieces connected together

        //in real world scenario, spider2 is also lower right of beetle and lower left of queen bee
        //TODO: failed!
        spider2.connect(with: queenBee, at: .downLeft)
        spider2.connect(with: beetle, at: .downRight)
        assert(spider.numConnected() == 6)
        assert(grasshopper.numConnected() == 6)
        assert(queenBee.numConnected() == 6)
        assert(beetle.numConnected() == 6)
        assert(soldierAnt.numConnected() == 6)
        assert(spider2.numConnected() == 6)

        //testing HexNode::canMove
        assert(soldierAnt.canDisconnect() == true)
        assert(spider.canDisconnect() == true)
        assert(queenBee.canDisconnect() == true)
        assert(beetle.canDisconnect() == false)
        assert(grasshopper.canDisconnect() == false)
        assert(spider2.canDisconnect() == true)

    }
    
    func testDirectionAdjacent() {
        let dir = Direction.up
        assert(dir.adjacent()[1].adjacent()[1].adjacent()[1] == .down)
    }
    
    func testNeighborsAdjacent() {
        let grasshopper = Grasshopper()
        let spider = Spider()
        let queenBee = QueenBee()
        let beetle = Beetle()
        let soldierAnt = SoldierAnt()
        let spider2 = Spider()
        
        grasshopper.connect(with: spider, at: .down) // grasshopper is beneath the spider
        queenBee.connect(with: grasshopper, at: .downRight) // queen bee is to the lower right of grasshopper
        beetle.connect(with: grasshopper, at: .downLeft) // beetle is to the lower left of grass hopper
        soldierAnt.connect(with: beetle, at: .down) // soldier ant is beneath beetle
        spider2.connect(with: grasshopper, at: .down) // spider2 is right beneath grasshopper

        var result = grasshopper.neighbors.adjacent(of: .down)
        assert(result[0].node! === queenBee && result[0].dir == .downRight)
        assert(result[1].node! === beetle && result[1].dir == .downLeft)
        
        result = beetle.neighbors.adjacent(of: .down)
        assert(result[0].node == nil && result[0].dir == .downRight)
        assert(result[1].node == nil && result[1].dir == .downLeft)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
