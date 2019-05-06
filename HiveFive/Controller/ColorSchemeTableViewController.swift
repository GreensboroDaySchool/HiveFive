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
private let profileNameCellId = "profileNameCell"

class ColorSchemeTableViewController: UITableViewController {
    
    var profile: Profile {
        get {return UserDefaults.currentProfile()}
    }
    
    var categories = [[KPHackable]]()
    var categoryNames = ["Profile Info", "General", "Colors", "Numbers & Ratios"]
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
        let alert = UIAlertController(style: .alert, title: "Profile Name")
        alert.addOneTextField(configuration: config)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel){[unowned self] _ in
            self.deselectAll()
        })
        alert.addAction(UIAlertAction(title: "Create from default", style: .default){[unowned self] _ in
            self.saveNewProfile(name: self.pendingText, profile: Profile.defaultProfile)
        })
        alert.addAction(UIAlertAction(title: "Create from current", style: .default){[unowned self] _ in
            self.saveNewProfile(name: self.pendingText, profile: UserDefaults.currentProfile())
        })
        alert.show()
    }
    
    private func saveNewProfile(name: String?, profile: Profile) {
        guard let name = name else {
            post(key: .displayMessage, object: "Invalid Name")
            return
        }
        UserDefaults.set(name, forKey: .currentProfile)
        // Delete existing profile with the same name
        CoreData.delete(entity: "NodeViewProfile") {($0 as! NodeViewProfile).name == name}
        var newProfile = profile
        newProfile.name = name
        newProfile.save()
        post(key: .profileUpdated, object: profile)
        post(key: .displayMessage, object: "New Profile Created")
        refresh()
    }
    
    private func refresh() {
        updateCategories()
        tableView.reloadData()
        deselectAll()
    }
    
    private func updateCategories() {
        categories = deconstruct(profile.categorize())
    }
    
    private func deselectAll() {
        tableView.indexPathsForSelectedRows?.forEach{
            tableView.deselectRow(at: $0, animated: true)
        }
    }
    
    private func deconstruct(_ category: Profile.Category) -> [[KPHackable]] {
        return [[], sort(category.bools), sort(category.colors), sort(category.numbers)] // Note: hacked!
    }
    
    private func sort(_ arr: [KPHackable]) -> [KPHackable] {
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
        case 0: cell = makeCell(profileNameCellId)
        case 1: cell = makeCell(boolCellId)
        case 2: cell = makeCell(colorCellId)
        case 3: cell = makeCell(numberCellId)
        default: fatalError("no such index")
        }
        
        if let associate = (cell as? KPAssociate) {
            associate.kpHackable = categories[indexPath.section][indexPath.row]
            associate.indexPath = indexPath
        } else if let profileCell = (cell as? ProfileNameTableViewCell) {
            profileCell.profileNameLabel.text = UserDefaults.currentProfileName()
            profileCell.profileInfoDelegate = self
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

extension ColorSchemeTableViewController: ProfileInfoDelegate {
    func profileInfoRequested() {
        let _name = UserDefaults.currentProfileName()
        let alert = UIAlertController(style: .actionSheet, title: "Name: \(_name)")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive){[unowned self] _ in
            UserDefaults.set("#default", forKey: .currentProfile) // Revert back to default profile
            Profile.delete(name: _name)
            post(key: .profileUpdated, object: Profile.defaultProfile)
            self.refresh()
        })
        alert.addAction(UIAlertAction(title: "Rename", style: .default){[unowned self] _ in
            self.pendingText = nil
            let alert2 = UIAlertController(style: .alert, title: "New Profile Name")
            alert2.addOneTextField(configuration: self.config)
            alert2.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert2.addAction(UIAlertAction(title: "Confirm", style: .default){[unowned self] _ in
                if let newName = self.pendingText {
                    let oldName = UserDefaults.currentProfileName()
                    var profile = UserDefaults.currentProfile()
                    profile.name = newName
                    profile.save()
                    Profile.delete(name: oldName)
                    UserDefaults.set(newName, forKey: .currentProfile)
                    post(key: .profileUpdated, object: profile)
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
    var kpHackable: KPHackable? {get set}
    var indexPath: IndexPath? {get set}
    func didSelect()
    func postUpdate(_ kpHackable: KPHackable)
    func cancelUpdate()
    func handleValueUpdate(_ updatedValue: Any)
}

extension KPAssociate {
    
    func postUpdate(_ kpHackable: KPHackable) {
        post(key: .kpHackableUpdated, object: kpHackable, userInfo: ["IndexPath": indexPath! as Any])
    }
    
    func cancelUpdate() {
        post(key: .kpHackableUpdateCancelled, object: (kpHackable,indexPath), userInfo: ["IndexPath": indexPath! as Any])
    }
    
    func handleValueUpdate(_ updatedValue: Any) {
        // Generate updated profile based on existing profile
        let updated = UserDefaults.currentProfile()
            .updated(key: self.kpHackable!.key, val: updatedValue)
        
        // Delete existing profile
        CoreData.delete(entity: "NodeViewProfile") {
            ($0 as! NodeViewProfile).name == UserDefaults.currentProfileName()
        }
        
        // Save updated profile into Core Data
        updated.save()
        
        // Post update notification
        self.postUpdate(self.kpHackable!.setValue(updatedValue))
        post(key: .displayMessage, object: ("\(kpHackable!.key) : \(updatedValue)"))
    }
}

