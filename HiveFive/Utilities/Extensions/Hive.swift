//
//  Extension+Hive.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import CoreData
import Hive5Common

extension Hive {
    /**
     Serialize the structure of the hive and store it in core data.
     - Parameter name: Name of the newly saved hive structure
     */
    func save(name: String) {
        guard let root = root else {return}
        var paths = root.derivePaths()
        let context = CoreData.context
        paths.insert(Path(route: Route(directions: []), destination: root), at: 0)
        let encoded = paths.map{($0.destination.identity.rawValue, $0.route.encode())}
        let structure = HiveStructure(context: context)
        let pieces = encoded.map{$0.0}
        let routes = encoded.map{$0.1}
        let colors = root.connectedNodes().map{$0.color.rawValue} // black == 0
        structure.pieces = pieces as NSObject // [String]
        structure.routes = routes as NSObject // [[Int]]
        structure.colors = colors as NSObject // [Int]
        
        func encode(_ hand: Hand) -> NSObject {
            return hand.map{(key: $0.key.rawValue, value: $0.value)}
                .reduce([String:Int]()){(dict: [String:Int], element: (key: String, value: Int)) in
                    var _dict = dict
                    _dict[element.key] = element.value
                    return _dict
                } as NSObject
        }
        
        structure.blackHand = encode(blackHand)
        structure.whiteHand = encode(whiteHand)
        structure.name = name
        
        var id: Int16 = 0
        if let retrivedID = UserDefaults.object(forKey: .hiveStructure) as? Int16 {
            id = retrivedID + 1
        }
        UserDefaults.set(id, forKey: .hiveStructure)
        structure.id = id
        
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    /**
     Retrieve saved hive structures from core data.
     - Parameter shouldInclude: Whether the HiveStructure should be returned as part of the results.
     */
    static func savedStructures(_ shouldInclude: (HiveStructure) -> Bool = {_ in return true}) -> [HiveStructure] {
        if let structures = try? CoreData.context.fetch(HiveStructure.fetchRequest()) as? [HiveStructure] {
            return structures.filter(shouldInclude)
        }
        return []
    }
    
    /**
     Retrives & loads a serialized HiveStructure and convert it to a Hive object
     - Parameter structure: The hive structure to be retrived from core data and reconstructed to a Hive object
     */
    static func load(_ structure: HiveStructure) -> Hive {
        let hive = Hive()
        let pieces = structure.pieces as! [String]
        let colors = (structure.colors as! [Int]).map{Color(rawValue: $0)!}
        let nodes = zip(pieces, colors).map{Identity(rawValue: $0.0)!.new(color: $0.1)}
        let routes = (structure.routes as! [[Int]]).map{Route.decode($0)}
        var paths = zip(nodes, routes).map{Path(route: $0.1, destination: $0.0)}
        
        let root = paths.removeFirst().destination
        paths.forEach {path in
            let position = Position.resolve(from: root, following: path.route)
            path.destination.move(to: position)
        }
        
        func decode(_ hand: NSObject) -> Hand {
            return (hand as! [String:Int])
                .keyValuePairs.reduce([Identity:Int]()) {(dict: [Identity:Int], element: (key: String, value: Int)) in
                    var _dict = dict
                    _dict[Identity(rawValue: element.key)!] = element.value
                    return _dict
            }
        }
        
        hive.root = root
        hive.blackHand = decode(structure.blackHand!)
        hive.whiteHand = decode(structure.whiteHand!)
        return hive
    }
}
