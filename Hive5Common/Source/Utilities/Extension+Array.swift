//
//  Extension+Array.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

public extension Array {
    /**
     Filters the array according to a given condition
     - Parameter isDuplicate: Condition that is true when the two elements are duplicates
     - Return: The filtered Array containing no duplicates by filtering by given conditions
     */
    public func filterDuplicates(isDuplicate: @escaping (_ lhs: Element, _ rhs: Element) -> Bool) -> [Element]{
        var results = [Element]()
        forEach { element in
            let existingElements = results.filter {isDuplicate(element, $0)}
            if existingElements.count == 0 {
                results.append(element)
            }
        }
        return results
    }
    
    public func random() -> Element {
        return self[Int(Double.random() * Double(count))]
    }
}
