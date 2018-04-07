//
//  NodeViewProfile.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/7/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import UIKit

struct Profile {
    static let defaultProfile: Profile = {
        if savedProfiles().count == 0 {
            Profile(name: "#default", keyPaths: defaultKeyPaths).save()
        }
        return load(savedProfiles{$0.name == "#default"}[0])
    }()

    var name: String
    var keyPaths: [KPHackable]

    func apply(on nodeView: NodeView) {
        keyPaths.forEach{$0.apply(on: nodeView)}
    }
    
    func save() {
        var properties = [String:Any]()
        keyPaths.forEach {properties[$0.key] = $0.getValue()}
        let context = CoreData.context
        let profile = NodeViewProfile(context: context)
        profile.name = name
        profile.properties = properties as NSObject
        try? context.save()
    }
    
    static func savedProfiles(_ shouldInclude: (NodeViewProfile) -> Bool = {_ in return true}) -> [NodeViewProfile] {
        if let profiles = try? CoreData.context.fetch(NodeViewProfile.fetchRequest()) as! [NodeViewProfile] {
            return profiles.filter(shouldInclude)
        }
        return []
    }
    
    static func load(_ profile: NodeViewProfile) -> Profile {
        let properties = profile.properties as! [String:Any]
        let name = profile.name!
        
        var profile = Profile(name: name, keyPaths: [])
        profile.keyPaths.append(contentsOf:
            properties.map{
                KPHacker.make(from: $0.key, value: $0.value)
            }
        )
        return profile
    }
}

enum CustomValue {
    case bool(Bool)
    case number(CGFloat)
    case color(UIColor)
}

/*
 Destroy type safety.
 */
protocol KPHackable {
    func apply<T>(on obj: T)
    func setValue<T>(_ val: T) -> KPHackable
    func getValue() -> Any
    func valueType() -> CustomValue
    var key: String {get}
    typealias KeyValuePair = (key: String, value: Any)
}

class KPHacker {
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
        return set(val as! Value)
    }

    let keyPath: ReferenceWritableKeyPath<RootType,Value>
    let key: String
    var value: Value

    func apply(on rootType: RootType) {
        rootType[keyPath: keyPath] = value
    }
    
    func set(_ val: Value) -> KPNamespace<RootType, Value> {
        return KPNamespace(keyPath: keyPath, key: key, value: val)
    }
    
    func getValue() -> Any {
        return value as Any
    }

    func encode() -> KeyValuePair {
        return (key: key, value: getValue())
    }
    
    func valueType() -> CustomValue {
        if value is CGFloat {
            return .number(value as! CGFloat)
        }else if value is UIColor {
            return .color(value as! UIColor)
        }else if value is Bool {
            return .bool(value as! Bool)
        }
        fatalError("unsupported type \(value)")
    }
}

let defaultKeyPaths: [KPHackable] = [
    KPNamespace(keyPath: \NodeView.isMonochromatic, key: "Monochromatic", value: false),
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
