//
//  Extension+Decimal.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation

extension Decimal {
    
    /**
     IntValue of the Decimal - for convenience.
     */
    var intValue: Int {
        return NSDecimalNumber(decimal: self).intValue
    }
}
