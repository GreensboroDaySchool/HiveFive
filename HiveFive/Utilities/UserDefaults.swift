//
//  UserDefaults.swift
//  Hive Five
//
//  Created by Jiachen Ren on 5/5/19.
//  Copyright © 2019 Greensboro Day School. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum Key: String {
        case currentPreset
        case queen4
        case immobilized4
        case expansionPack
        case theme
        case toolBarVisible
        case nodeSize
        case rectangularUI
        case showAlerts
        case hiveStructure
    }
    
    static var nodeSizes = [90, 100, 120]
    
    static func set(_ obj: Any, forKey key: Key) {
        standard.set(obj, forKey: key.rawValue)
        print("saved: \(obj) with key: \(key)")
    }
    
    static func object(forKey key: Key) -> Any? {
        let obj = standard.object(forKey: key.rawValue)
        print("retrieved \(String(describing: obj)) for key: \(key)")
        return obj
    }
    
    static func useQueen4() -> Bool {
        return object(forKey: .queen4) as? Bool ?? true
    }
    
    static func useImmobilized4() -> Bool {
        return object(forKey: .immobilized4) as? Bool ?? true
    }
    
    static func useExpansionPack() -> Bool {
        return object(forKey: .expansionPack) as? Bool ?? true
    }
    
    static func currentPresetName() -> String {
        return object(forKey: .currentPreset) as? String ?? "Default"
    }
    
    static func currentPreset() -> Preset {
        return Preset.load(currentPresetName())
    }
    
    static func showsAlerts() -> Bool  {
        return object(forKey: .showAlerts) as? Bool ?? true
    }
    
    static func useRectangularUI() -> Bool  {
        return object(forKey: .rectangularUI) as? Bool ?? false
    }
    
    static func nodeSizeIndex() -> Int {
        return object(forKey: .nodeSize) as? Int ?? 1
    }
    
    static func nodeSize() -> Int  {
        return nodeSizes[nodeSizeIndex()]
    }
    
    static func toolBarVisible() -> Bool {
        return object(forKey: .toolBarVisible) as? Bool ?? true
    }
    
    static func currentTheme() -> Theme {
        return Theme.decode(object(forKey: .theme) as? String ?? Theme.glossary[0].name)
    }
    
}
