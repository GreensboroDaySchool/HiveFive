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
    
    let grasshopper = Grasshopper()
    let spider = Spider()
    let queenBee = QueenBee()
    let beetle = Beetle()
    let soldierAnt = SoldierAnt()
    let spider2 = Spider()
    let beetle2 = Beetle()
    
    var allPieces: [HexNode] {
        get {
            return [grasshopper, spider, queenBee, beetle, soldierAnt, spider2, beetle2]
        }
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        //set up hive
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
        //this is where we want to be when a structure is properly connected
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        allPieces.forEach{$0.disconnect()}
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

    func testCanDisconnect() {
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
        spider2.connect(with: queenBee, at: .downLeft)
        spider2.connect(with: beetle, at: .downRight)

        let nodes = spider.connectedNodes()
        debugPrint(nodes)
        assert(nodes.count == 6)

        assert(spider.numConnected() == 6)
        assert(grasshopper.numConnected() == 6)
        assert(queenBee.numConnected() == 6)
        assert(beetle.numConnected() == 6)
        assert(soldierAnt.numConnected() == 6)
        assert(spider2.numConnected() == 6)
        //still holds true -- there are only 6 pieces.

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

    func testNumConnected() {
        //test HexNode::numConnected
        assert(spider2.numConnected() == 7) // yes!!!
        assert(grasshopper.numConnected() == 7)
    }
    
    func testNeighborsAdjacent() {
        //test Neighbors::adjacent
        var result = grasshopper.neighbors.adjacent(of: .down)
        assert(result[0].node! === queenBee && result[0].dir == .downRight)
        assert(result[1].node! === beetle && result[1].dir == .downLeft)
        
        result = beetle.neighbors.adjacent(of: .down)
        assert(result[0].node === spider2 && result[0].dir == .downRight)
        assert(result[1].node == nil && result[1].dir == .downLeft)
    }
    
    func testBeetlesAvailableMoves() {
        //test QueenBee::availableMoves
        let destinations = queenBee.availableMoves()
        assert(destinations.count == 2)
    }

    func testDestinationResolve() {
        //test Destination::resolve
        let destinations = queenBee.availableMoves()
        assert(destinations[0].node === spider2 && destinations[0].dir == .downRight)
        assert(destinations[1].node === grasshopper && destinations[1].dir == .upRight)
    }
    
    func testHexNodeDerivePaths() {
        //test HexNode::derivePaths
        assert(spider.derivePaths().count == 6)
        assert(grasshopper.derivePaths().count == 6)
        assert(beetle.derivePaths().count == 6)
    }
    
    func testHexNodeMoveTo() {
        //test HexNode::move(to:)
        let destination = Destination(node: grasshopper, dir: .upRight)
        beetle2.move(to: destination)
        assert(grasshopper.numConnected() == 7)
        assert(beetle2.neighbors.available().count == 3)

        spider.move(to: Destination(node: beetle, dir: .downLeft))
        assert(spider.hasNeighbor(beetle) == .upRight)
        assert(spider.hasNeighbor(soldierAnt) == .downRight)
        assert(spider2.canDisconnect())
        
        grasshopper.move(to: Destination(node: beetle2, dir: .upRight))
        assert(spider2.neighbors.available().count == 3)
        assert(beetle2.neighbors.available().count == 2)
        assert(beetle.numConnected() == 7)
        assert(spider.derivePaths().count == 6)
        
        //test Beetle!!!
        beetle.move(to: Destination(node: spider2, dir: .above))
        assert(queenBee.availableMoves().count == 0)
        assert(soldierAnt.neighbors.available().count == 2)
        
        //at this point, the only available neighbor of beetle is the piece that is below it
        assert(beetle.neighbors.available().count == 1)
        assert(queenBee.derivePaths().count == 6)
        
        let beetle3 = Beetle() // add another beetle, beetle3, to the downRight of beetle and above soldierAnt
        beetle3.move(to: Destination(node: soldierAnt, dir: .above))
        //beetle and beetle3 have the same z coordinate, thus they should be automatically connected
        assert(beetle.neighbors.available().count == 2)
        assert(beetle3.neighbors.available().count == 2) // both beetles are on the plane z = 1
        assert(beetle.neighbors.contains(beetle3) == .downLeft) // works like a charm without modification to existing move(to:) algorithm!
        assert(beetle3.derivePaths().count == 7)
        assert(queenBee.availableMoves().count == 0)
        assert(beetle3.availableMoves().count == 6) // yes!!!
        
        beetle.move(to: Destination(node: spider2, dir: .upLeft))
        assert(beetle.derivePaths().count == 7)
        assert(beetle.neighbors.available().count == 3)
        assert(beetle.availableMoves().count == 5)
        assert(beetle3.availableMoves().count == 6)
        
        //test Grasshopper::availableMoves
        assert(grasshopper.availableMoves()[0] == Destination(node: beetle2, dir: .downLeft))
        grasshopper.move(to: grasshopper.availableMoves()[0])
        assert(grasshopper.neighbors.available().count == 4)
        assert(grasshopper.availableMoves().count == 4)
    }
    
    func testSpiderAvailableMoves() {
        let availableMoves = spider2.availableMoves()
        assert(availableMoves.count == 2) // yes!
        assert(availableMoves.contains(Destination(node: queenBee, dir: .upRight))) // yes!!
        assert(availableMoves.contains(Destination(node: soldierAnt, dir: .downLeft))) // yes!!!

        assert(spider2.neighbors.available().count == 4)
        assert(spider2.numConnected() == 7)
    }
    
    func testRouteSimplified() {
        //testing Route::equals
        assert(Route(directions: [.downLeft, .upLeft, .up, .upRight, .downRight]).equals(Route(directions: [.up])))
        assert(Route(directions: [.upLeft, .up, .upRight, .downRight, .down]).equals(Route(directions: [.upRight])))
        assert(Route(directions: [.up, .upRight, .downRight, .down, .downLeft]).equals(Route(directions: [.downRight])))
        assert(Route(directions: [.upRight, .downRight, .down, .downLeft, .upLeft]).equals(Route(directions: [.down])))

        //testing Route::simplified
        assert(Route(directions: [.downLeft, .upLeft, .up, .upRight, .downRight]).simplified().directions[0] == .up)
        assert(Route(directions: [.upLeft, .up, .upRight, .downRight, .down]).simplified().directions[0] == .upRight)
        assert(Route(directions: [.up, .upRight, .downRight, .down, .downLeft]).simplified().directions[0] == .downRight)
        assert(Route(directions: [.upRight, .downRight, .down, .downLeft, .upLeft]).simplified().directions[0] == .down)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
