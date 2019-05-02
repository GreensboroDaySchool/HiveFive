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
        queen4Switch.isOn = useQueen4()
        immobilized4Switch.isOn = useImmobilized4()
    }
    
    @IBAction func queen4SwitchValueChanged(_ sender: UISwitch) {
        save(id: queen4Id, obj: sender.isOn)
        post(name: queen4UpdateNotification, object: nil)
    }
    
    @IBAction func immobilized4SwitchValueChanged(_ sender: UISwitch) {
        save(id: immobilized4Id, obj: sender.isOn)
        post(name: immobilized4UpdateNotification, object: nil)
    }

}
