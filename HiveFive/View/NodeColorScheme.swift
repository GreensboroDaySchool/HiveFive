//
//  NodeColorScheme.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/7/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import UIKit

struct Profile {
    var name: String?
    var content: [KPHackable]
    
    func apply(on nodeView: NodeView) {
        content.forEach{$0.apply(on: nodeView)}
    }
}

extension Profile {
    static let defaultProfile = Profile(name: "default", content: [
        KPStringConvertible(keyPath: \NodeView.isMonocromatic, key: "Monocromatic", value: false)
//        "Monochromatic" : .bool(true),
//        "Theme Color" : .color(.black),
//        "Selected Color" : .color(.red),
//
//        "White Border Color": .color(.black),
//        "White Fill Color": .color(.white),
//        "Black Border Color": .color(.black),
//        "Black Fill Color": .color(.lightGray),
//
//        "Selected Border Color": .color(.orange),
//        "Selected Fill Color": .color(UIColor.orange.withAlphaComponent(0.2)),
//        "Selected Identity Color": .color(.orange),
//
//        "Dummy Color" : .color(.black),
//        "Dummy Color Alpha" : .number(0.2),
//
//        "Border Width Ratio" : .number(0.01),
//        "Overlap Shrink Ratio" : .number(0.92),
//        "Selected Border Width Ratio" : .number(0.01),
//        "Dummy Border Width Ratio" : .number(0.01),
//        "Display Radius Ratio" : .number(0.9375)
    ])
}

/*
 Destroy type safety.
 */
protocol KPHackable {
    func apply(on obj: Any)
}

struct KPStringConvertible<RootType,Type>: KPHackable {
    let keyPath: ReferenceWritableKeyPath<RootType,Type>
    let key: String
    let value: Type
    
    func apply(on rootType: RootType) {
        rootType[keyPath: keyPath] = value
    }
    
    func apply(on obj: Any) {
        apply(on: obj as! RootType)
    }
    
    typealias KeyValuePair = (key: String, value: Type)
    
    func encode() -> KeyValuePair {
        return (key: key, value: value)
    }
}

enum CustomValue {
    case color(UIColor)
    case number(CGFloat)
    case bool(Bool)
}
