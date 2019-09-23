//
//  HFInterface.swift
//  Hive Five
//
//  Created by Marcus Zhou on 4/14/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import UIKit

/// HFInterface is a wrapper to provide clean & convenient access to multiple storyboards
enum HFInterface: String {
    //Container ViewController - Manages all three VCs
    case Entry = "Entry"
    
    //The three main ViewControllers in the container vc
    case History = "History"
    case Menu = "Menu"
    case Board = "Board"
    
    case ColorPicker = "Color Picker"
    case Help = "Help"
    case Appearance = "Appearance"
    
    var instance: UIStoryboard { return UIStoryboard(name: rawValue, bundle: Bundle.main) }
    var initialViewController: UIViewController? { return instance.instantiateInitialViewController() }
}
