//
//  Extension+UIGestureRecognizer.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import UIKit

extension UIGestureRecognizer {
    
    /**
     A little trick for cancelling detected gesture.
     */
    func cancel() {
        isEnabled = false
        isEnabled = true
    }
}
