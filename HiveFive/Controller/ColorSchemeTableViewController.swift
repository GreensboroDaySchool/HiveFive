//
//  ColorSchemeTableViewController.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/6/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import UIKit

private let colorCellId = "colorCell"
private let numberCellId = "numberCell"
private let boolCellId = "boolCell"
private let profileNameCellId = "profileNameCell"

class ColorSchemeTableViewController: UITableViewController {

    var profile: Profile {
        get {return currentProfile()}
    }
    
    var categories = [[KPHackable]]()
    var categoryNames = ["Profile Info", "", "Colors", "Numbers & Ratios"]
    var pendingText: String?
    
    var config: TextField.Config!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
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
        observe(kpHackableUpdateCancelledNotification, #selector(kpHackableUpdateDidCancel(_:)))
        observe(kpHackableUpdateNotification, #selector(kpHackableDidUpdate(_:)))
    }
    
    @objc private func kpHackableDidUpdate(_ notification: Notification) {
        updateCategories()
        if let indexPath = notification.userInfo?["IndexPath"] as? IndexPath {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
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
            self.saveNewProfile(name: self.pendingText, profile: currentProfile())
        })
        
        alert.show()
    }
    
    private func saveNewProfile(name: String?, profile: Profile) {
        guard let name = name else {
            post(name: displayMsgNotification, object: "Invalid Name")
            return
        }
        save(id: currentProfileId, obj: name)
        CoreData.delete(entity: "NodeViewProfile") {($0 as! NodeViewProfile).name == name} // Delete existing profile with the same name
        var newProfile = profile // TODO: should be overriden?
        newProfile.name = name
        newProfile.save()
        post(name: profileUpdatedNotification, object: profile)
        post(name: displayMsgNotification, object: "New Profile Created")
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
        tableView.indexPathsForSelectedRows?.forEach{tableView.deselectRow(at: $0, animated: true)}
    }
    
    private func deconstruct(_ category: Profile.Category) -> [[KPHackable]] {
        return [[], category.bools, category.colors, category.numbers] // Note: hacked!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            profileCell.profileNameLabel.text = currentProfileName()
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ColorSchemeTableViewController: ProfileInfoDelegate {
    func profileInfoRequested() {
        let _name = currentProfileName()
        let alert = UIAlertController(style: .actionSheet, title: "Name: \(_name)")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive){[unowned self] _ in
            save(id: currentProfileId, obj: "#default") // Revert back to default profile
            Profile.delete(name: _name)
            post(name: profileUpdatedNotification, object: Profile.defaultProfile)
            self.refresh()
        })
        alert.addAction(UIAlertAction(title: "Rename", style: .default){[unowned self] _ in
            self.pendingText = nil
            let alert2 = UIAlertController(style: .alert, title: "New Profile Name")
            alert2.addOneTextField(configuration: self.config)
            alert2.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert2.addAction(UIAlertAction(title: "Confirm", style: .default){[unowned self] _ in
                if let newName = self.pendingText {
                    Profile.delete(name: currentProfileName())
                    save(id: currentProfileId, obj: newName)
                    var profile = currentProfile()
                    profile.name = newName
                    profile.save()
                    post(name: profileUpdatedNotification, object: profile)
                    self.refresh()
                    return
                }
                post(name: displayMsgNotification, object: "Invalid Name")
            })
            alert2.show()
//            self.saveNewProfile(name: self.pendingText, profile: currentProfile())
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
        post(name: kpHackableUpdateNotification, object: kpHackable, userInfo: ["IndexPath":indexPath! as Any])
    }
    
    func cancelUpdate() {
        post(name: kpHackableUpdateCancelledNotification, object: (kpHackable,indexPath), userInfo: ["IndexPath":indexPath! as Any])
    }
    
    func handleValueUpdate(_ updatedValue: Any) {
        let updated = currentProfile().updated(key: self.kpHackable!.key, val: updatedValue) // Generate updated profile based on existing profile
        CoreData.delete(entity: "NodeViewProfile") {($0 as! NodeViewProfile).name == currentProfileName()} // Delete existing profile
        updated.save() // Save updated profile into Core Data
        self.postUpdate(self.kpHackable!.setValue(updatedValue)) // Post update notification
        post(name: displayMsgNotification, object: ("\(kpHackable!.key) : \(updatedValue)"))
    }
}
