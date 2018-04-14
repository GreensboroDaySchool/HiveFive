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

class ToggleTableViewCell: UITableViewCell, KPAssociate {
    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    var indexPath: IndexPath?
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
        handleValueUpdate(sender.isOn)
    }
}
