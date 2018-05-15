//
//  Extension+Dictionary.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

public extension Dictionary {
    var keyValuePairs: [(key: Key,value: Value)] {
        get {
            return zip(self.keys,self.values).map{(key: $0.0, value: $0.1)}
        }
    }
}

public extension Dictionary where Value: Equatable {
    func key(for value: Value) -> Key? {
        return first(where: { $1 == value })?.key
    }
}
