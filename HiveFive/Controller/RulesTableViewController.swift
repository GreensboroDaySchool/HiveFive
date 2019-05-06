//
//  RulesTableViewController.swift
//  Hive Five
//
//  Created by Jiachen Ren on 5/9/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import UIKit

class RulesTableViewController: UITableViewController {

    @IBOutlet weak var queen4Switch: UISwitch!
    @IBOutlet weak var immobilized4Switch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up initial states
        queen4Switch.isOn = UserDefaults.useQueen4()
        immobilized4Switch.isOn = UserDefaults.useImmobilized4()
    }
    
    @IBAction func queen4SwitchValueChanged(_ sender: UISwitch) {
        UserDefaults.set(sender.isOn, forKey: .queen4)
        post(key: .queen4Updated)
    }
    
    @IBAction func immobilized4SwitchValueChanged(_ sender: UISwitch) {
        UserDefaults.set(sender.isOn, forKey: .immobilized4)
        post(key: .immobilized4Updated)
    }

}
