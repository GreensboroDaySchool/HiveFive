/**
 *
 *  This file is part of Hive Five.
 *
 *  Hive Five is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Hive Five is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Hive Five.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import Foundation
import UIKit

/**
 Original Core Data + Key Path Hacker by Jiachen Ren
 TODO: rename to ProfileManager
 */
struct Profile {
    static let defaultProfile: Profile = {
        if !savedProfiles().contains(where: {$0.name == "#default"}) {
            Profile(name: "#default", keyPaths: defaultKeyPaths).save()
        }
        return load(savedProfiles{$0.name == "#default"}[0])
    }()

    var name: String
    var keyPaths: [KPHackable]

    func apply(on nodeView: NodeView) {
        keyPaths.forEach{$0.apply(on: nodeView)}
    }
    
    typealias Category = (colors: [KPHackable], bools: [KPHackable], numbers: [KPHackable])
    
    func categorize() -> Category {
        let colors = keyPaths.filter{$0.getValue() is UIColor}
        let numbers = keyPaths.filter{$0.getValue() is CGFloat}
        let bools = keyPaths.filter{$0.getValue() is Bool}
        return (colors: colors, numbers: numbers, bools: bools)
    }
    
    func updated(key: String, val: Any) -> Profile {
        var preserved = keyPaths.filter{$0.key != key}
        preserved.append(KPHacker.make(from: key, value: val))
        return Profile(name: name, keyPaths: preserved)
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
    
    static func delete(name profileName: String) {
        CoreData.delete(entity: "NodeViewProfile") {($0 as! NodeViewProfile).name == profileName}
    }
    
    static func savedProfiles(_ shouldInclude: (NodeViewProfile) -> Bool = {_ in return true}) -> [NodeViewProfile] {
        if let profiles = try? CoreData.context.fetch(NodeViewProfile.fetchRequest()) as? [NodeViewProfile] {
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
    
    static func load(_ profileName: String) -> Profile {
        let savedProfiles = self.savedProfiles{$0.name == profileName}
        if savedProfiles.count == 0 {
            print("No profiles with name \(profileName) were found, default profile loaded")
            return defaultProfile
        }
        return load(savedProfiles[0])
    }
}

/*
 Destroy type safety, container for KPNamespace
 */
protocol KPHackable {
    func apply<T>(on obj: T)
    func setValue<T>(_ val: T) -> KPHackable
    func getValue() -> Any
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
}

let defaultKeyPaths: [KPHackable] = [
    KPNamespace(keyPath: \NodeView.isMonochromatic, key: "Monochromatic", value: true),
    KPNamespace(keyPath: \NodeView.monocromaticColor, key: "Theme", value: .black),
    KPNamespace(keyPath: \NodeView.monocromaticSelectedColor, key: "Selected", value: .red),
    
    KPNamespace(keyPath: \NodeView.whiteBorderColor, key: "White Border", value: .black),
    KPNamespace(keyPath: \NodeView.whiteFillColor, key: "White Fill", value: .white),
    KPNamespace(keyPath: \NodeView.blackBorderColor, key: "Black Border", value: .black),
    KPNamespace(keyPath: \NodeView.blackFillColor, key: "Black Fill", value: .lightGray),
    
    KPNamespace(keyPath: \NodeView.selectedBorderColor, key: "Selected Border", value: .orange),
    KPNamespace(keyPath: \NodeView.selectedFillColor, key: "Selected Fill", value: UIColor.orange.withAlphaComponent(0.2)),
    KPNamespace(keyPath: \NodeView.selectedIdentityColor, key: "Selected Identity", value: .orange),
    
    KPNamespace(keyPath: \NodeView.dummyColor, key: "Dummy", value: .green),
    KPNamespace(keyPath: \NodeView.dummyColorAlpha, key: "Dummy Color Alpha", value: 0.2),
    
    KPNamespace(keyPath: \NodeView.borderWidthRatio, key: "Border Width", value: 0.01),
    KPNamespace(keyPath: \NodeView.overlapShrinkRatio, key: "Overlap Shrink", value: 0.92),
    KPNamespace(keyPath: \NodeView.selectedBorderWidthRatio, key: "Selected Border Width", value: 0.01),
    KPNamespace(keyPath: \NodeView.dummyBorderWidthRatio, key: "Dummy Border Width", value: 0.01),
    KPNamespace(keyPath: \NodeView.displayRadiusRatio, key: "Display Radius", value: 0.9375),
]
