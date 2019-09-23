//
//  Extension+UIView.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    /**
     Using a function since `var image` might conflict with an existing variable
     (like on `UIImageView`)
     */
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
