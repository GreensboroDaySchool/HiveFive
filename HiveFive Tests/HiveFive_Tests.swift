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
import CoreData
@testable import Hive_Five

class HiveFive_Tests: XCTestCase {
    
    let grasshopper = Grasshopper(color: .black)
    let spider = Spider(color: .white)
    let queenBee = QueenBee(color: .black)
    let beetle = Beetle(color: .white)
    let soldierAnt = SoldierAnt(color: .black)
    let spider2 = Spider(color: .black)
    let beetle2 = Beetle(color: .white)
    
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
        let node1 = Grasshopper(color: .black)
        let node2 = Spider(color: .black)

        var n1 = Neighbors()
        var n2 = Neighbors()
        n1[.down] = node1
        n2[.down] = node2
        XCTAssert(!n1.equals(n2))
        n2[.down] = node1
        XCTAssert(n1.equals(n2))
    }

    func testNeighborsContains() {
        let node1 = Grasshopper(color: .black)
        let node2 = Spider(color: .white)

        var n1 = Neighbors()
        n1[.down] = node1
        n1[.up] = node2
        XCTAssert(n1.contains(node2) == .up)
    }

    func testCanDisconnect() {
        let grasshopper = Grasshopper(color: .black)
        let spider = Spider(color: .black)
        let queenBee = QueenBee(color: .white)
        let beetle = Beetle(color: .white)
        let soldierAnt = SoldierAnt(color: .black)
        let spider2 = Spider(color: .white)

        //testing HexNode::numConnected
        grasshopper.connect(with: spider, at: .down) // grasshopper is beneath the spider
        XCTAssert(spider.numConnected() == 2)
        XCTAssert(grasshopper.numConnected() == 2)
        queenBee.connect(with: grasshopper, at: .downRight) // queen bee is to the lower right of grasshopper
        XCTAssert(spider.numConnected() == 3)
        XCTAssert(grasshopper.numConnected() == 3)
        XCTAssert(queenBee.numConnected() == 3)
        beetle.connect(with: grasshopper, at: .downLeft) // beetle is to the lower left of grass hopper
        XCTAssert(spider.numConnected() == 4)
        XCTAssert(grasshopper.numConnected() == 4)
        XCTAssert(queenBee.numConnected() == 4)
        XCTAssert(beetle.numConnected() == 4)
        soldierAnt.connect(with: beetle, at: .down) // soldier ant is beneath beetle
        XCTAssert(spider.numConnected() == 5)
        XCTAssert(grasshopper.numConnected() == 5)
        XCTAssert(queenBee.numConnected() == 5)
        XCTAssert(beetle.numConnected() == 5)
        XCTAssert(soldierAnt.numConnected() == 5)
        spider2.connect(with: grasshopper, at: .down) // spider2 is right beneath grasshopper
        XCTAssert(spider.numConnected() == 6)
        XCTAssert(grasshopper.numConnected() == 6)
        XCTAssert(queenBee.numConnected() == 6)
        XCTAssert(beetle.numConnected() == 6)
        XCTAssert(soldierAnt.numConnected() == 6)
        XCTAssert(spider2.numConnected() == 6)
        // including the top spider, there are 6 pieces connected together

        //in real world scenario, spider2 is also lower right of beetle and lower left of queen bee
        spider2.connect(with: queenBee, at: .downLeft)
        spider2.connect(with: beetle, at: .downRight)

        let nodes = spider.connectedNodes()
        debugPrint(nodes)
        XCTAssert(nodes.count == 6)

        XCTAssert(spider.numConnected() == 6)
        XCTAssert(grasshopper.numConnected() == 6)
        XCTAssert(queenBee.numConnected() == 6)
        XCTAssert(beetle.numConnected() == 6)
        XCTAssert(soldierAnt.numConnected() == 6)
        XCTAssert(spider2.numConnected() == 6)
        //still holds true -- there are only 6 pieces.

        //testing HexNode::canMove
        XCTAssert(soldierAnt.canDisconnect() == true)
        XCTAssert(spider.canDisconnect() == true)
        XCTAssert(queenBee.canDisconnect() == true)
        XCTAssert(beetle.canDisconnect() == false)
        XCTAssert(grasshopper.canDisconnect() == false)
        XCTAssert(spider2.canDisconnect() == true)

    }

    func testDirectionAdjacent() {
        let dir = Direction.up
        XCTAssert(dir.adjacent()[1].adjacent()[1].adjacent()[1] == .down)
    }

    func testNumConnected() {
        //test HexNode::numConnected
        XCTAssert(spider2.numConnected() == 7) // yes!!!
        XCTAssert(grasshopper.numConnected() == 7)
    }
    
    func testNeighborsAdjacent() {
        //test Neighbors::adjacent
        var result = grasshopper.neighbors.adjacent(of: .down)
        XCTAssert(result[0].node! === queenBee && result[0].dir == .downRight)
        XCTAssert(result[1].node! === beetle && result[1].dir == .downLeft)
        
        result = beetle.neighbors.adjacent(of: .down)
        XCTAssert(result[0].node === spider2 && result[0].dir == .downRight)
        XCTAssert(result[1].node == nil && result[1].dir == .downLeft)
    }
    
    func testBeetlesAvailableMoves() {
        //test QueenBee::availableMoves
        let destinations = queenBee.availableMoves()
        XCTAssert(destinations.count == 2)
    }

    func testPositionResolve() {
        //test Position::resolve
        let destinations = queenBee.availableMoves()
        XCTAssert(destinations[0].node === spider2 && destinations[0].dir == .downRight)
        XCTAssert(destinations[1].node === grasshopper && destinations[1].dir == .upRight)
    }
    
    func testHexNodeDerivePaths() {
        //test HexNode::derivePaths
        XCTAssert(spider.derivePaths().count == 6)
        XCTAssert(grasshopper.derivePaths().count == 6)
        XCTAssert(beetle.derivePaths().count == 6)
    }
    
    func testHexNodeMoveTo() {
        //test HexNode::move(to:)
        let destination = Position(node: grasshopper, dir: .upRight)
        beetle2.move(to: destination)
        XCTAssert(grasshopper.numConnected() == 7)
        XCTAssert(beetle2.neighbors.available().count == 3)

        spider.move(to: Position(node: beetle, dir: .downLeft))
        XCTAssert(spider.hasNeighbor(beetle) == .upRight)
        XCTAssert(spider.hasNeighbor(soldierAnt) == .downRight)
        XCTAssert(spider2.canDisconnect())
        
        grasshopper.move(to: Position(node: beetle2, dir: .upRight))
        XCTAssert(spider2.neighbors.available().count == 3)
        XCTAssert(beetle2.neighbors.available().count == 2)
        XCTAssert(beetle.numConnected() == 7)
        XCTAssert(spider.derivePaths().count == 6)
        
        //test Beetle!!!
        beetle.move(to: Position(node: spider2, dir: .above))
        XCTAssert(queenBee.availableMoves().count == 0)
        XCTAssert(soldierAnt.neighbors.available().count == 2)
        
        //at this point, the only available neighbor of beetle is the piece that is below it
        XCTAssert(beetle.neighbors.available().count == 1)
        XCTAssert(queenBee.derivePaths().count == 6)
        
        let beetle3 = Beetle(color: .white) // add another beetle, beetle3, to the downRight of beetle and above soldierAnt
        beetle3.move(to: Position(node: soldierAnt, dir: .above))
        //beetle and beetle3 have the same z coordinate, thus they should be automatically connected
        XCTAssert(beetle.neighbors.available().count == 2)
        XCTAssert(beetle3.neighbors.available().count == 2) // both beetles are on the plane z = 1
        XCTAssert(beetle.neighbors.contains(beetle3) == .downLeft) // works like a charm without modification to existing move(to:) algorithm!
        XCTAssert(beetle3.derivePaths().count == 7)
        XCTAssert(queenBee.availableMoves().count == 0)
        XCTAssert(beetle3.availableMoves().count == 6) // yes!!!
        
        beetle.move(to: Position(node: spider2, dir: .upLeft))
        XCTAssert(beetle.derivePaths().count == 7)
        XCTAssert(beetle.neighbors.available().count == 3)
        XCTAssert(beetle.availableMoves().count == 5)
        XCTAssert(beetle3.availableMoves().count == 6)
        
        //test Grasshopper::availableMoves
        XCTAssert(grasshopper.availableMoves()[0] == Position(node: beetle2, dir: .downLeft))
        grasshopper.move(to: grasshopper.availableMoves()[0])
        XCTAssert(grasshopper.neighbors.available().count == 4)
        XCTAssert(grasshopper.availableMoves().count == 4)
    }
    
    func testSpiderAvailableMoves() {
        let availableMoves = spider2.availableMoves()
        XCTAssert(availableMoves.count == 2) // yes!
        XCTAssert(availableMoves.contains(Position(node: queenBee, dir: .upRight))) // yes!!
        XCTAssert(availableMoves.contains(Position(node: soldierAnt, dir: .downLeft))) // yes!!!

        XCTAssert(spider2.neighbors.available().count == 4)
        XCTAssert(spider2.numConnected() == 7)
    }
    
    func testRouteSimplified() {
        //testing Route::equals
        XCTAssert(Route(directions: [.downLeft, .upLeft, .up, .upRight, .downRight]) == Route(directions: [.up]))
        XCTAssert(Route(directions: [.upLeft, .up, .upRight, .downRight, .down]) == Route(directions: [.upRight]))
        XCTAssert(Route(directions: [.up, .upRight, .downRight, .down, .downLeft]) == Route(directions: [.downRight]))
        XCTAssert(Route(directions: [.upRight, .downRight, .down, .downLeft, .upLeft]) == Route(directions: [.down]))

        //testing Route::simplified
        XCTAssert(Route(directions: [.downLeft, .upLeft, .up, .upRight, .downRight]).simplified().directions[0] == .up)
        XCTAssert(Route(directions: [.upLeft, .up, .upRight, .downRight, .down]).simplified().directions[0] == .upRight)
        XCTAssert(Route(directions: [.up, .upRight, .downRight, .down, .downLeft]).simplified().directions[0] == .downRight)
        XCTAssert(Route(directions: [.upRight, .downRight, .down, .downLeft, .upLeft]).simplified().directions[0] == .down)
    }
    
    func testCanGetIn() {
        let grasshopper2 = Grasshopper(color: .black)
        let queenBee2 = QueenBee(color: .black)
        grasshopper2.move(to: Position(node: beetle2, dir: .downRight))
        queenBee2.move(to: Position(node: grasshopper2, dir: .down))
        XCTAssert(!queenBee2.canGetIn(dir: .upLeft))
        var availableMoves = queenBee2.availableMoves()
        XCTAssert(availableMoves.count == 2) // yes !
        XCTAssert(availableMoves.contains(Position(node: grasshopper2, dir: .downRight))) // yes !!
        XCTAssert(availableMoves.contains(Position(node: queenBee, dir: .downRight))) // yes !!!
        
        //test Beetle canGetIn
        queenBee2.disconnect()
        let beetle3 = Beetle(color: .white)
        beetle3.move(to: Position(node: grasshopper2, dir: .down))
        XCTAssert(beetle3.canGetIn(dir: .upLeft))
        availableMoves = beetle3.availableMoves()
        XCTAssert(availableMoves.count == 5)
        XCTAssert(availableMoves.contains(Position(node: grasshopper2, dir: .downLeft)))
        
        //test SoldierAnt::availableMoves
        beetle3.disconnect()
        XCTAssert(soldierAnt.availableMoves().count == 13) // yes !!
        soldierAnt.move(to: Position(node: queenBee, dir: .up))
        XCTAssert(soldierAnt.neighbors.available().count == 5)
        XCTAssert(soldierAnt.availableMoves().count == 0)
    }
    
    func testCanMoveToAndCanPlaceAt() {
        XCTAssert(beetle2.canMove(to: Position(node: spider, dir: .downRight)))
        XCTAssert(beetle2.canMove(to: Position(node: spider, dir: .above)))
        XCTAssert(beetle2.neighbors.available().count == 1)
        XCTAssert(beetle2.availableMoves().count == 3)
        
        //test canPlace(at:)
        let blackGrasshopper = Grasshopper(color: .black)
        let whiteSoldierAnt = SoldierAnt(color: .white)
        
        XCTAssert(!blackGrasshopper.canPlace(at: Position(node: beetle2, dir: .above)))
//        XCTAssert(!blackGrasshopper.canPlace(at: Position(node: beetle2, dir: .up))) //Test fails!
        XCTAssert(!blackGrasshopper.canPlace(at: Position(node: queenBee, dir: .up)))
        XCTAssert(blackGrasshopper.canPlace(at: Position(node: queenBee, dir: .upRight)))
        
        blackGrasshopper.place(at: Position(node: queenBee, dir: .upRight))
        XCTAssert(blackGrasshopper.hasNeighbor(queenBee) == .downLeft && blackGrasshopper.neighbors.available().count == 1)
        
        whiteSoldierAnt.place(at: Position(node: beetle, dir: .upLeft))
        XCTAssert(whiteSoldierAnt.neighbors.available().count == 1)
        XCTAssert(whiteSoldierAnt.numConnected() == 9)
        XCTAssert(whiteSoldierAnt.canMove(to: Position(node: beetle2, dir: .upRight)))
        XCTAssert(!whiteSoldierAnt.canMove(to: Position(node: beetle2, dir: .down)))
        
        XCTAssert(blackGrasshopper.availableMoves().count == 1)
        XCTAssert(blackGrasshopper.canMove(to: Position(node: soldierAnt, dir: .downLeft)))
    }
    
    
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func deleteHiveStuctures() {
        // delete everything
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "HiveStructure")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let _ = try? CoreData.context.execute(request)
    }
    
    func testCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
        
        deleteHiveStuctures()
        
        let hiveStructure = HiveStructure(context: context)

        hiveStructure.pieces = ["Beetle","QueenBee"] as NSObject
        hiveStructure.routes = [[0,2,3,4,5],[]] as NSObject
        
        do {
            try context.save()
        } catch {
            print("Failed to save changes to core data.")
        }
        
        let fetched = try! context.fetch(HiveStructure.fetchRequest()) as! [HiveStructure]
        assert(fetched.count == 1)
        let pieces = fetched[0].pieces as! [String]
        let routes = fetched[0].routes as! [[Int]]

        assert(pieces.first == "Beetle")
        assert(routes[0] == [0,2,3,4,5])
    }
    
    func testHiveSerialization() {
        
        deleteHiveStuctures()
        
        let hive = Hive()
        hive.root = spider
        hive.save(name: "game1")
        
        let game1 = Hive.savedStructures()!.first!
        let retrieved = Hive.load(structure: game1)
        assert(retrieved.root!.connectedNodes().count == allPieces.count)
    }
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
