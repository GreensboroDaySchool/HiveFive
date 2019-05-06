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
 Core Data + Key Path linking data structure
 */
struct Preset {
    static let defaultPreset: Preset = {
        if !savedPresets().contains(where: {$0.name == "Default"}) {
            Preset(name: "Default", properties: defaultProperties).save()
        }
        return load(savedPresets{$0.name == "Default"}[0])
    }()

    var name: String
    var properties: [Property]

    func apply(on nodeView: NodeView) {
        properties.forEach{$0.apply(on: nodeView)}
    }
    
    typealias Category = (colors: [Property], bools: [Property], numbers: [Property])
    
    func categorize() -> Category {
        let colors = properties.filter {$0.getValue() is UIColor}
        let numbers = properties.filter {$0.getValue() is CGFloat}
        let bools = properties.filter {$0.getValue() is Bool}
        return (colors: colors, numbers: numbers, bools: bools)
    }
    
    func updated(key: String, val: Any) -> Preset {
        var preserved = properties.filter{$0.key != key}
        let property: Property = PropertyFactory.make(from: key, value: val)
        preserved.append(property)
        return Preset(name: name, properties: preserved)
    }
    
    func save() {
        var properties = [String: Any]()
        self.properties.forEach {properties[$0.key] = $0.getValue()}
        let context = CoreData.context
        let preset = NodeViewPreset(context: context)
        preset.name = name
        preset.properties = properties as NSObject
        try? context.save()
    }
    
    static func delete(name presetName: String) {
        CoreData.delete(entity: "NodeViewPreset") {($0 as! NodeViewPreset).name == presetName}
    }
    
    static func savedPresets(_ shouldInclude: (NodeViewPreset) -> Bool = {_ in return true}) -> [NodeViewPreset] {
        if let presets = try? CoreData.context.fetch(NodeViewPreset.fetchRequest()) as? [NodeViewPreset] {
            return presets.filter(shouldInclude)
        }
        return []
    }
    
    static func load(_ preset: NodeViewPreset) -> Preset {
        let properties = preset.properties as! [String:Any]
        let name = preset.name!
        
        var preset = Preset(name: name, properties: [])
        preset.properties.append(contentsOf:
            properties.map{
                PropertyFactory.make(from: $0.key, value: $0.value)
            }
        )
        return preset
    }
    
    static func load(_ presetName: String) -> Preset {
        let savedPresets = self.savedPresets{$0.name == presetName}
        if savedPresets.count == 0 {
            print("No presets with name \(presetName) were found, default preset loaded")
            return defaultPreset
        }
        return load(savedPresets[0])
    }
}

protocol Property {
    func apply<T>(on obj: T)
    func setValue<T>(_ val: T) -> Property
    func getValue() -> Any
    var key: String {get}
    typealias KeyValuePair = (key: String, value: Any)
}

class PropertyFactory {
    static func make<V>(from key: String, value: V) -> Property {
        let new = defaultProperties.filter{$0.key == key}[0]
        return new.setValue(value)
    }
}


struct KPProperty<RootType, Value>: Property {
    
    func apply<T>(on obj: T) {
        apply(on: obj as! RootType)
    }

    func setValue<T>(_ val: T) -> Property {
        return set(val as! Value)
    }

    let keyPath: ReferenceWritableKeyPath<RootType,Value>
    let key: String
    var value: Value

    func apply(on rootType: RootType) {
        rootType[keyPath: keyPath] = value
    }
    
    func set(_ val: Value) -> KPProperty<RootType, Value> {
        return KPProperty(keyPath: keyPath, key: key, value: val)
    }
    
    func getValue() -> Any {
        return value as Any
    }

    func encode() -> KeyValuePair {
        return (key: key, value: getValue())
    }
}

fileprivate let defaultProperties: [Property] = [
    KPProperty(keyPath: \NodeView.isMonochromatic, key: "Monochromatic", value: true),
    KPProperty(keyPath: \NodeView.monocromaticColor, key: "Theme", value: .black),
    KPProperty(keyPath: \NodeView.monocromaticSelectedColor, key: "Selected", value: .red),
    
    KPProperty(keyPath: \NodeView.whiteBorderColor, key: "White Border", value: .black),
    KPProperty(keyPath: \NodeView.whiteFillColor, key: "White Fill", value: .white),
    KPProperty(keyPath: \NodeView.blackBorderColor, key: "Black Border", value: .black),
    KPProperty(keyPath: \NodeView.blackFillColor, key: "Black Fill", value: .darkGray),
    
    KPProperty(keyPath: \NodeView.selectedBorderColor, key: "Selected Border", value: .orange),
    KPProperty(keyPath: \NodeView.selectedFillColor, key: "Selected Fill", value: UIColor.orange.withAlphaComponent(0.2)),
    KPProperty(keyPath: \NodeView.selectedIdentityColor, key: "Selected Identity", value: .orange),
    
    KPProperty(keyPath: \NodeView.dummyColor, key: "Dummy", value: .orange),
    KPProperty(keyPath: \NodeView.dummyColorAlpha, key: "Dummy Color Alpha", value: 0.2),
    
    KPProperty(keyPath: \NodeView.borderWidthRatio, key: "Border Width", value: 0.01),
    KPProperty(keyPath: \NodeView.overlapShrinkRatio, key: "Overlap Shrink", value: 0.92),
    KPProperty(keyPath: \NodeView.selectedBorderWidthRatio, key: "Selected Border Width", value: 0.01),
    KPProperty(keyPath: \NodeView.dummyBorderWidthRatio, key: "Dummy Border Width", value: 0.01),
    KPProperty(keyPath: \NodeView.displayRadiusRatio, key: "Display Radius", value: 0.9375),
]
