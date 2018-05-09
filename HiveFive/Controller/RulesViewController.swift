//
//  RulesViewController.swift
//  Hive Five
//
//  Created by Jiachen Ren on 5/9/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import UIKit

class RulesViewController: UIViewController {

    @IBOutlet weak var queen4Switch: UISwitch!
    @IBOutlet weak var immobilized4Switch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up initial states
        queen4Switch.isOn = useQueen4()
        immobilized4Switch.isOn = useImmobilized4()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func queen4SwitchValueChanged(_ sender: UISwitch) {
        save(id: queen4Id, obj: sender.isOn)
        post(name: queen4UpdateNotification, object: nil)
    }
    
    @IBAction func immobilized4SwitchValueChanged(_ sender: UISwitch) {
        save(id: queen4Id, obj: sender.isOn)
        post(name: immobilized4UpdateNotification, object: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
