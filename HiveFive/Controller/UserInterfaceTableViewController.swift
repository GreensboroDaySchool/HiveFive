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
        tabBarVisibilitySwitch.isOn = toolBarShouldBeVisible()
        preferredNodeSizeSegmentedControl.selectedSegmentIndex = nodeSizeIndex()
        rectangularUiSwitch.isOn = shouldUseRectangularUI()
    }
    
    @IBAction func tabBarVisibilitySwitchToggled(_ sender: UISwitch) {
        let isOn = sender.isOn
        save(id: toolBarVisibilityId, obj: isOn)
        post(name: toolBarVisibilityNotification, object: isOn)
    }
    
    @IBAction func preferredNodeSizeSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        save(id: preferredNodeSizeId, obj: index)
        post(name: preferredNodeSizeNotification, object: index)
    }
    
    @IBAction func rectangularUiSwitchToggled(_ sender: UISwitch) {
        save(id: rectangularUiId, obj: sender.isOn)
    }
    
    @IBAction func showAlertsSwitchToggled(_ sender: UISwitch) {
        let isOn = sender.isOn
        post(name: displayMsgNotification, object: isOn ? "Alerts On" : "Alerts Off") // Minor bug
        save(id: showAlertsId, obj: isOn)
        post(name: shouldShowAlertsChangedNotification, object: isOn)
    }
}
