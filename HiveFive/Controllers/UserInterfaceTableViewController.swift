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

import UIKit

class UserInterfaceTableViewController: UITableViewController {

    @IBOutlet weak var tabBarVisibilitySwitch: UISwitch!
    @IBOutlet weak var preferredNodeSizeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var rectangularUiSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: additional setup
        tabBarVisibilitySwitch.isOn = UserDefaults.toolBarVisible()
        preferredNodeSizeSegmentedControl.selectedSegmentIndex = UserDefaults.nodeSizeIndex()
        rectangularUiSwitch.isOn = UserDefaults.useRectangularUI()
    }
    
    @IBAction func tabBarVisibilitySwitchToggled(_ sender: UISwitch) {
        let isOn = sender.isOn
        UserDefaults.set(isOn, forKey: .toolBarVisible)
        post(key: .toolBarVisibleUpdated, object: isOn)
    }
    
    @IBAction func preferredNodeSizeSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        UserDefaults.set(index, forKey: .nodeSize)
        post(key: .nodeSizeUpdated, object: index)
    }
    
    @IBAction func rectangularUiSwitchToggled(_ sender: UISwitch) {
        UserDefaults.set(sender.isOn, forKey: .rectangularUI)
    }
    
    @IBAction func showAlertsSwitchToggled(_ sender: UISwitch) {
        let isOn = sender.isOn
        post(key: .displayMessage, object: isOn ? "Alerts On" : "Alerts Off")
        UserDefaults.set(isOn, forKey: .showAlerts)
        post(key: .showAlertsUpdated, object: isOn)
    }
}
