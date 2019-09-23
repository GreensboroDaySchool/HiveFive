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

private let colorCellId = "colorCell"
private let numberCellId = "numberCell"
private let boolCellId = "boolCell"
private let presetNameCellId = "presetNameCell"

class ColorSchemeTableViewController: UITableViewController {
    
    var preset: Preset {
        get {return UserDefaults.currentPreset()}
    }
    
    var categories = [[Property]]()
    var categoryNames = ["Preset Info", "General", "Colors", "Numbers & Ratios"]
    var pendingText: String?
    var config: TextField.Config!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: addtional setup
        updateCategories()
        config = { textField in
            textField.becomeFirstResponder()
            textField.textColor = .black
            textField.placeholder = "Enter new name here"
            textField.left(image: #imageLiteral(resourceName: "pencil_img"), color: .black)
            textField.leftViewPadding = 12
            textField.borderWidth = 1
            textField.cornerRadius = 8
            textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
            textField.backgroundColor = nil
            textField.keyboardAppearance = .default
            textField.keyboardType = .default
            textField.returnKeyType = .done
            textField.action {[unowned self] textField in
                self.pendingText = textField.text
            }
        }
        
        // MARK: notification binding
        observe(.kpHackableUpdateCancelled, #selector(kpHackableUpdateDidCancel(_:)))
        observe(.kpHackableUpdated, #selector(kpHackableDidUpdate(_:)))
    }
    
    @objc private func kpHackableDidUpdate(_ notification: Notification) {
        updateCategories()
        tableView.reloadData()
        deselectAll()
    }
    
    @objc private func kpHackableUpdateDidCancel(_ notification: Notification) {
        deselectAll()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        pendingText = nil
        let alert = UIAlertController(style: .alert, title: "Preset Name")
        alert.addOneTextField(configuration: config)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel){[unowned self] _ in
            self.deselectAll()
        })
        alert.addAction(UIAlertAction(title: "Create from default", style: .default){[unowned self] _ in
            self.saveNewPreset(name: self.pendingText, preset: Preset.defaultPreset)
        })
        alert.addAction(UIAlertAction(title: "Create from current", style: .default){[unowned self] _ in
            self.saveNewPreset(name: self.pendingText, preset: UserDefaults.currentPreset())
        })
        alert.show()
    }
    
    private func saveNewPreset(name: String?, preset: Preset) {
        guard let name = name else {
            post(key: .displayMessage, object: "Invalid Name")
            return
        }
        UserDefaults.set(name, forKey: .currentPreset)
        // Delete existing preset with the same name
        CoreData.delete(entity: "NodeViewPreset") {($0 as! NodeViewPreset).name == name}
        var newPreset = preset
        newPreset.name = name
        newPreset.save()
        post(key: .presetUpdated, object: preset)
        post(key: .displayMessage, object: "New Preset Created")
        refresh()
    }
    
    private func refresh() {
        updateCategories()
        tableView.reloadData()
        deselectAll()
    }
    
    private func updateCategories() {
        categories = deconstruct(preset.categorize())
    }
    
    private func deselectAll() {
        tableView.indexPathsForSelectedRows?.forEach{
            tableView.deselectRow(at: $0, animated: true)
        }
    }
    
    private func deconstruct(_ category: Preset.Category) -> [[Property]] {
        return [[], sort(category.bools), sort(category.colors), sort(category.numbers)] // Note: hacked!
    }
    
    private func sort(_ arr: [Property]) -> [Property] {
        return arr.sorted {
            $0.key < $1.key
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : categories[section].count // Note: hacked
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        func makeCell(_ id: String) -> UITableViewCell {
            return tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        }
        
        var cell: UITableViewCell
        
        switch indexPath.section {
        case 0: cell = makeCell(presetNameCellId)
        case 1: cell = makeCell(boolCellId)
        case 2: cell = makeCell(colorCellId)
        case 3: cell = makeCell(numberCellId)
        default: fatalError("no such index")
        }
        
        if let associate = (cell as? KPAssociate) {
            associate.kpHackable = categories[indexPath.section][indexPath.row]
            associate.indexPath = indexPath
        } else if let presetCell = (cell as? PresetNameTableViewCell) {
            presetCell.presetNameLabel.text = UserDefaults.currentPresetName()
            presetCell.presetInfoDelegate = self
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categoryNames[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (tableView.cellForRow(at: indexPath) as? KPAssociate)?.didSelect()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50 // TODO: figure out the best height
    }
}

extension ColorSchemeTableViewController: PresetInfoDelegate {
    func presetInfoRequested() {
        let _name = UserDefaults.currentPresetName()
        let alert = UIAlertController(style: .actionSheet, title: "Name: \(_name)")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive){[unowned self] _ in
            UserDefaults.set("Default", forKey: .currentPreset) // Revert back to default preset
            Preset.delete(name: _name)
            post(key: .presetUpdated, object: Preset.defaultPreset)
            self.refresh()
        })
        alert.addAction(UIAlertAction(title: "Rename", style: .default){[unowned self] _ in
            self.pendingText = nil
            let alert2 = UIAlertController(style: .alert, title: "New Preset Name")
            alert2.addOneTextField(configuration: self.config)
            alert2.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert2.addAction(UIAlertAction(title: "Confirm", style: .default){[unowned self] _ in
                if let newName = self.pendingText {
                    let oldName = UserDefaults.currentPresetName()
                    var preset = UserDefaults.currentPreset()
                    preset.name = newName
                    preset.save()
                    Preset.delete(name: oldName)
                    UserDefaults.set(newName, forKey: .currentPreset)
                    post(key: .presetUpdated, object: preset)
                    self.refresh()
                    return
                }
                post(key: .displayMessage, object: "Invalid Name")
            })
            alert2.show()
        })
        alert.show()
    }
}

protocol KPAssociate: class {
    var kpHackable: Property? {get set}
    var indexPath: IndexPath? {get set}
    func didSelect()
    func postUpdate(_ kpHackable: Property)
    func cancelUpdate()
    func handleValueUpdate(_ updatedValue: Any)
}

extension KPAssociate {
    
    func postUpdate(_ kpHackable: Property) {
        post(key: .kpHackableUpdated, object: kpHackable, userInfo: ["IndexPath": indexPath! as Any])
    }
    
    func cancelUpdate() {
        post(key: .kpHackableUpdateCancelled, object: (kpHackable,indexPath), userInfo: ["IndexPath": indexPath! as Any])
    }
    
    func handleValueUpdate(_ updatedValue: Any) {
        // Generate updated preset based on existing preset
        let updated = UserDefaults.currentPreset()
            .updated(key: self.kpHackable!.key, val: updatedValue)
        
        // Delete existing preset
        CoreData.delete(entity: "NodeViewPreset") {
            ($0 as! NodeViewPreset).name == UserDefaults.currentPresetName()
        }
        
        // Save updated preset into Core Data
        updated.save()
        
        // Post update notification
        self.postUpdate(self.kpHackable!.setValue(updatedValue))
        post(key: .displayMessage, object: ("\(kpHackable!.key) : \(updatedValue)"))
    }
}

