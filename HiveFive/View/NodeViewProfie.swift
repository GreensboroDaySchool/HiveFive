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
    static let defaultProfile = Profile(name: "default", content: defaultKeyPaths)

    var name: String?
    var content: [KPHackable]

    func apply(on nodeView: NodeView) {
        content.forEach{$0.apply(on: nodeView)}
    }
}

/*
 Destroy type safety.
 */
protocol KPHackable {
    func apply<T>(on obj: T)
    func setValue<T>(_ val: T) -> KPHackable
    var key: String {get}

    static func make<V>(from key: String, value: V) -> KPHackable
}

extension KPHackable {
    static func make<V>(from key: String, value: V) -> KPHackable {
        let new = defaultKeyPaths.filter{$0.key == key}[0]
        return new.setValue(value)
    }
}

struct KPNamespace<RootType,Value>: KPHackable {
    func apply<T>(on obj: T) {
        apply(on: obj as! RootType)
    }

    func setValue<T>(_ val: T) -> KPHackable {
        return KPNamespace(keyPath: keyPath, key: key, value: val as! Value)
    }

    let keyPath: ReferenceWritableKeyPath<RootType,Value>
    let key: String
    var value: Value

    func apply(on rootType: RootType) {
        rootType[keyPath: keyPath] = value
    }

    typealias KeyValuePair = (key: String, value: Value)

    func encode() -> KeyValuePair {
        return (key: key, value: value)
    }

    func getKey() -> String {
        return key
    }
}

let defaultKeyPaths: [KPHackable] = [
    KPNamespace(keyPath: \NodeView.isMonocromatic, key: "Monochromatic", value: false),
    KPNamespace(keyPath: \NodeView.monocromaticColor, key: "Theme Color", value: .black),
    KPNamespace(keyPath: \NodeView.monocromaticSelectedColor, key: "Selected Color", value: .red),
    
    KPNamespace(keyPath: \NodeView.whiteBorderColor, key: "White Border Color", value: .black),
    KPNamespace(keyPath: \NodeView.whiteFillColor, key: "White Fill Color", value: .white),
    KPNamespace(keyPath: \NodeView.blackBorderColor, key: "Black Border Color", value: .black),
    KPNamespace(keyPath: \NodeView.blackFillColor, key: "Black Fill Color", value: .lightGray),
    
    KPNamespace(keyPath: \NodeView.selectedBorderColor, key: "Selected Border Color", value: .orange),
    KPNamespace(keyPath: \NodeView.selectedFillColor, key: "Selected Fill Color", value: UIColor.orange.withAlphaComponent(0.2)),
    KPNamespace(keyPath: \NodeView.selectedIdentityColor, key: "Selected Identity Color", value: .orange),
    
    KPNamespace(keyPath: \NodeView.dummyColor, key: "Dummy Color", value: .green),
    KPNamespace(keyPath: \NodeView.dummyColorAlpha, key: "Dummy Color Alpha", value: 0.2),
    
    KPNamespace(keyPath: \NodeView.borderWidthRatio, key: "Border Width Ratio", value: 0.01),
    KPNamespace(keyPath: \NodeView.overlapShrinkRatio, key: "Overlap Shrink Ratio", value: 0.92),
    KPNamespace(keyPath: \NodeView.selectedBorderWidthRatio, key: "Selected Border Width Ratio", value: 0.01),
    KPNamespace(keyPath: \NodeView.dummyBorderWidthRatio, key: "Dummy Border Width Ratio", value: 0.01),
    KPNamespace(keyPath: \NodeView.displayRadiusRatio, key: "Display Radius Ratio", value: 0.9375),
]
