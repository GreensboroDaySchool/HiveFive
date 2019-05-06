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
@testable import Hive5Common

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
        beetle2.connect(with: spider, at: .upperRight)

        grasshopper.connect(with: spider, at: .down) // grasshopper is beneath the spider
        queenBee.connect(with: grasshopper, at: .lowerRight) // queen bee is to the lower right of grasshopper
        beetle.connect(with: grasshopper, at: .lowerLeft) // beetle is to the lower left of grass hopper

        soldierAnt.connect(with: beetle, at: .down) // soldier ant is beneath beetle
        soldierAnt.connect(with: spider2, at: .lowerLeft) // soldier ant is also lower left of spider2

        spider2.connect(with: grasshopper, at: .down) // spider2 is right beneath grasshopper
        //in real world scenario, spider2 is also lower right of beetle and lower left of queen bee
        spider2.connect(with: queenBee, at: .lowerLeft) // spider2 is also lower left of queen bee
        spider2.connect(with: beetle, at: .lowerRight) // spider2 is also lower right of beetle
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
        queenBee.connect(with: grasshopper, at: .lowerRight) // queen bee is to the lower right of grasshopper
        XCTAssert(spider.numConnected() == 3)
        XCTAssert(grasshopper.numConnected() == 3)
        XCTAssert(queenBee.numConnected() == 3)
        beetle.connect(with: grasshopper, at: .lowerLeft) // beetle is to the lower left of grass hopper
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
        spider2.connect(with: queenBee, at: .lowerLeft)
        spider2.connect(with: beetle, at: .lowerRight)

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
        XCTAssert(result[0].node! === queenBee && result[0].dir == .lowerRight)
        XCTAssert(result[1].node! === beetle && result[1].dir == .lowerLeft)
        
        result = beetle.neighbors.adjacent(of: .down)
        XCTAssert(result[0].node === spider2 && result[0].dir == .lowerRight)
        XCTAssert(result[1].node == nil && result[1].dir == .lowerLeft)
    }
    
    func testBeetlesAvailableMoves() {
        //test QueenBee::availableMoves
        let destinations = queenBee._availableMoves()
        XCTAssert(destinations.count == 2)
    }

    func testPositionResolve() {
        //test Position::resolve
        let destinations = queenBee._availableMoves()
        XCTAssert(destinations[0].node === spider2 && destinations[0].dir == .lowerRight)
        XCTAssert(destinations[1].node === grasshopper && destinations[1].dir == .upperRight)
    }
    
    func testHexNodeDerivePaths() {
        //test HexNode::derivePaths
        XCTAssert(spider.derivePaths().count == 6)
        XCTAssert(grasshopper.derivePaths().count == 6)
        XCTAssert(beetle.derivePaths().count == 6)
    }
    
    func testHexNodeMoveTo() {
        //test HexNode::move(to:)
        let destination = Position(node: grasshopper, dir: .upperRight)
        beetle2.move(to: destination)
        XCTAssert(grasshopper.numConnected() == 7)
        XCTAssert(beetle2.neighbors.present().count == 3)

        spider.move(to: Position(node: beetle, dir: .lowerLeft))
        XCTAssert(spider.hasNeighbor(beetle) == .upperRight)
        XCTAssert(spider.hasNeighbor(soldierAnt) == .lowerRight)
        XCTAssert(spider2.canDisconnect())
        
        grasshopper.move(to: Position(node: beetle2, dir: .upperRight))
        XCTAssert(spider2.neighbors.present().count == 3)
        XCTAssert(beetle2.neighbors.present().count == 2)
        XCTAssert(beetle.numConnected() == 7)
        XCTAssert(spider.derivePaths().count == 6)
        
        //test Beetle!!!
        beetle.move(to: Position(node: spider2, dir: .top))
        XCTAssert(queenBee._availableMoves().count == 0)
        XCTAssert(soldierAnt.neighbors.present().count == 2)
        
        //at this point, the only available neighbor of beetle is the piece that is below it
        XCTAssert(beetle.neighbors.present().count == 1)
        XCTAssert(queenBee.derivePaths().count == 6)
        
        let beetle3 = Beetle(color: .white) // add another beetle, beetle3, to the lowerRight of beetle and above soldierAnt
        beetle3.move(to: Position(node: soldierAnt, dir: .top))
        //beetle and beetle3 have the same z coordinate, thus they should be automatically connected
        XCTAssert(beetle.neighbors.present().count == 2)
        XCTAssert(beetle3.neighbors.present().count == 2) // both beetles are on the plane z = 1
        XCTAssert(beetle.neighbors.contains(beetle3) == .lowerLeft) // works like a charm without modification to existing move(to:) algorithm!
        XCTAssert(beetle3.derivePaths().count == 7)
        XCTAssert(queenBee._availableMoves().count == 0)
        XCTAssert(beetle3._availableMoves().count == 6) // yes!!!
        
        beetle.move(to: Position(node: spider2, dir: .upperLeft))
        XCTAssert(beetle.derivePaths().count == 7)
        XCTAssert(beetle.neighbors.present().count == 3)
        XCTAssert(beetle._availableMoves().count == 5)
        XCTAssert(beetle3._availableMoves().count == 6)
        
        //test Grasshopper::availableMoves
        XCTAssert(grasshopper._availableMoves()[0] == Position(node: beetle2, dir: .lowerLeft))
        grasshopper.move(to: grasshopper._availableMoves()[0])
        XCTAssert(grasshopper.neighbors.present().count == 4)
        XCTAssert(grasshopper._availableMoves().count == 4)
    }
    
    func testSpiderAvailableMoves() {
        let availableMoves = spider2._availableMoves()
        XCTAssert(availableMoves.count == 2) // yes!
        XCTAssert(availableMoves.contains(Position(node: queenBee, dir: .upperRight))) // yes!!
        XCTAssert(availableMoves.contains(Position(node: soldierAnt, dir: .lowerLeft))) // yes!!!

        XCTAssert(spider2.neighbors.present().count == 4)
        XCTAssert(spider2.numConnected() == 7)
    }
    
    func testRouteSimplified() {
        //testing Route::equals
        XCTAssert(Route(directions: [.downLeft, .upLeft, .up, .upperRight, .downRight]) == Route(directions: [.up]))
        XCTAssert(Route(directions: [.upLeft, .up, .upperRight, .downRight, .down]) == Route(directions: [.upperRight]))
        XCTAssert(Route(directions: [.up, .upperRight, .downRight, .down, .downLeft]) == Route(directions: [.downRight]))
        XCTAssert(Route(directions: [.upperRight, .downRight, .down, .downLeft, .upLeft]) == Route(directions: [.down]))

        //testing Route::simplified
        XCTAssert(Route(directions: [.downLeft, .upLeft, .up, .upperRight, .downRight]).simplified().directions[0] == .up)
        XCTAssert(Route(directions: [.upLeft, .up, .upperRight, .downRight, .down]).simplified().directions[0] == .upperRight)
        XCTAssert(Route(directions: [.up, .upperRight, .downRight, .down, .downLeft]).simplified().directions[0] == .downRight)
        XCTAssert(Route(directions: [.upperRight, .downRight, .down, .downLeft, .upLeft]).simplified().directions[0] == .down)
    }
    
    func testCanGetIn() {
        let grasshopper2 = Grasshopper(color: .black)
        let queenBee2 = QueenBee(color: .black)
        grasshopper2.move(to: Position(node: beetle2, dir: .lowerRight))
        queenBee2.move(to: Position(node: grasshopper2, dir: .down))
        XCTAssert(!queenBee2.canGetIn(dir: .upperLeft))
        var availableMoves = queenBee2._availableMoves()
        XCTAssert(availableMoves.count == 2) // yes !
        XCTAssert(availableMoves.contains(Position(node: grasshopper2, dir: .lowerRight))) // yes !!
        XCTAssert(availableMoves.contains(Position(node: queenBee, dir: .lowerRight))) // yes !!!
        
        //test Beetle canGetIn
        queenBee2.disconnect()
        let beetle3 = Beetle(color: .white)
        beetle3.move(to: Position(node: grasshopper2, dir: .down))
        XCTAssert(beetle3.canGetIn(dir: .upperLeft))
        availableMoves = beetle3._availableMoves()
        XCTAssert(availableMoves.count == 5)
        XCTAssert(availableMoves.contains(Position(node: grasshopper2, dir: .lowerLeft)))
        
        //test SoldierAnt::availableMoves
        beetle3.disconnect()
        XCTAssert(soldierAnt._availableMoves().count == 13) // yes !!
        soldierAnt.move(to: Position(node: queenBee, dir: .up))
        XCTAssert(soldierAnt.neighbors.present().count == 5)
        XCTAssert(soldierAnt._availableMoves().count == 0)
    }
    
    func testCanMoveToAndCanPlaceAt() {
        XCTAssert(beetle2.canMove(to: Position(node: spider, dir: .lowerRight)))
        XCTAssert(beetle2.canMove(to: Position(node: spider, dir: .top)))
        XCTAssert(beetle2.neighbors.present().count == 1)
        XCTAssert(beetle2._availableMoves().count == 3)
        
        //test canPlace(at:)
        let blackGrasshopper = Grasshopper(color: .black)
        let whiteSoldierAnt = SoldierAnt(color: .white)
        
        XCTAssert(!blackGrasshopper.canPlace(at: Position(node: beetle2, dir: .top)))
        XCTAssert(!blackGrasshopper.canPlace(at: Position(node: beetle2, dir: .up))) //Test fails!
        XCTAssert(!blackGrasshopper.canPlace(at: Position(node: queenBee, dir: .up)))
        XCTAssert(blackGrasshopper.canPlace(at: Position(node: queenBee, dir: .upperRight)))
        
        blackGrasshopper.place(at: Position(node: queenBee, dir: .upperRight))
        XCTAssert(blackGrasshopper.hasNeighbor(queenBee) == .lowerLeft && blackGrasshopper.neighbors.available().count == 1)
        
        whiteSoldierAnt.place(at: Position(node: beetle, dir: .upperLeft))
        XCTAssert(whiteSoldierAnt.neighbors.present().count == 1)
        XCTAssert(whiteSoldierAnt.numConnected() == 9)
        XCTAssert(whiteSoldierAnt.canMove(to: Position(node: beetle2, dir: .upperRight)))
        XCTAssert(!whiteSoldierAnt.canMove(to: Position(node: beetle2, dir: .down)))
        
        XCTAssert(blackGrasshopper._availableMoves().count == 1)
        XCTAssert(blackGrasshopper.canMove(to: Position(node: soldierAnt, dir: .lowerLeft)))
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
        XCTAssert(fetched.count == 1)
        let pieces = fetched[0].pieces as! [String]
        let routes = fetched[0].routes as! [[Int]]

        XCTAssert(pieces.first == "Beetle")
        XCTAssert(routes[0] == [0,2,3,4,5])
    }
    
    func testHiveSerialization() {
        
        deleteHiveStuctures()
        
        let hive = Hive()
        hive.root = spider
        hive.save(name: "game1")
        
        let game1 = Hive.savedStructures().first!
        let retrieved = Hive.load(game1)
        XCTAssert(retrieved.root!.connectedNodes().count == allPieces.count)
    }
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
