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

class UserInterfaceViewController: UIViewController {

    @IBOutlet weak var tabBarVisibilitySwitch: UISwitch!
    @IBOutlet weak var preferredNodeSizeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var rectangularUiSwitch: UISwitch!
    
    @IBOutlet weak var cellHeightLabel: UILabel!
    @IBOutlet weak var cellHeightSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: additional setup
        tabBarVisibilitySwitch.isOn = toolBarShouldBeVisible()
        preferredNodeSizeSegmentedControl.selectedSegmentIndex = nodeSizeIndex()
        rectangularUiSwitch.isOn = shouldUseRectangularUI()
        
        let cellHeight = tableViewCellHeight()
        cellHeightLabel.text = String(Double(cellHeight))
        cellHeightSlider.value = Float(cellHeight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func cellHeightSliderValueChanged(_ sender: UISlider) {
        let value = Int(roundf(sender.value))
        cellHeightLabel.text = String("\(value) px")
        sender.value = Float(value) // Update the value of the slider as well.
    }
    
    @IBAction func cellHeightSliderEditingDidEnd(_ sender: UISlider) {
        let value = Int(roundf(sender.value))
        save(id: tableViewCellHeightId, obj: value)
        post(name: tableViewCellHeightUpdatedNotification, object: value)
        post(name: displayMsgNotification, object: "Cell Height: \(value) px")
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
