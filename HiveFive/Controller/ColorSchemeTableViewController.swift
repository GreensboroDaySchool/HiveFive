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

class ColorSchemeTableViewController: UITableViewController {

    var profile: Profile {
        get {return currentProfile()}
    }
    
    var categories = [[KPHackable]]()
    var categoryNames = ["Booleans", "Colors", "Numbers & Ratios"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // MARK: addtional setup
        updateCategories()
        
        // MARK: notification binding
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(kpHackableUpdateDidCancel(_:)),
            name: kpHackableUpdateCancelledNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(kpHackableDidUpdate(_:)),
            name: kpHackableUpdateNotification,
            object: nil
        )
    }
    
    @objc private func kpHackableDidUpdate(_ notification: Notification) {
        updateCategories()
        tableView.reloadRows(at: [notification.userInfo!["IndexPath"] as! IndexPath], with: .automatic) // Could be optimized with reload data at rows
        deselectAll()
    }
    
    @objc private func kpHackableUpdateDidCancel(_ notification: Notification) {
        deselectAll()
    }
    
    private func updateCategories() {
        categories = deconstruct(profile.categorize())
    }
    
    private func deselectAll() {
        tableView.indexPathsForSelectedRows?.forEach{tableView.deselectRow(at: $0, animated: true)}
    }
    
    private func deconstruct(_ category: Profile.Category) -> [[KPHackable]] {
        return [category.bools, category.colors, category.numbers]
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
        return categories[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        func makeCell(_ id: String) -> UITableViewCell {
            return tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        }
        
        var cell: UITableViewCell
        
        switch indexPath.section {
        case 0: cell = makeCell(boolCellId)
        case 1: cell = makeCell(colorCellId)
        case 2: cell = makeCell(numberCellId)
        default: fatalError("no such index")
        }
        
        let associate = (cell as! KPAssociate)
        associate.kpHackable = categories[indexPath.section][indexPath.row]
        associate.indexPath = indexPath
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categoryNames[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (tableView.cellForRow(at: indexPath) as! KPAssociate).didSelect()
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
