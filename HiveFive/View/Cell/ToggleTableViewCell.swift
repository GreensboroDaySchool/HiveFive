//
//  ToggleTableViewCell.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/7/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import UIKit

class ToggleTableViewCell: UITableViewCell, KPAssociate {
    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    var indexPath: IndexPath?
    var switchToggled: ((Bool) -> ())?
    var kpHackable: KPHackable? {
        didSet {
            `switch`.isOn = kpHackable?.getValue() as! Bool
            nameLabel.text = kpHackable?.key
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func didSelect() {
        
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        self.switchToggled?(sender.isOn)
    }
}
