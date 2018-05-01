//
//  HiveMaster_Tests.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/30/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import XCTest
@testable import Hive_Five

class HiveMaster_Tests: XCTestCase {
    
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testHexNodeClone() {
        let hive = Hive.defaultHive
        let cloned = HexNode.clone(root: hive.root!)
        XCTAssert(hive.root?.availableMoves().count == cloned.availableMoves().count)
        hive.root!.connectedNodes().forEach {node in
            XCTAssert(!cloned.connectedNodes() // Make sure that thre are no duplicate references
                .map{$0.hashValue}
                .contains{node.hashValue == $0})
        }
    }
    
}
