//
//  ProfileNameTableViewCell.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/8/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import UIKit

class ProfileNameTableViewCell: UITableViewCell {
    @IBOutlet weak var profileNameLabel: UILabel!
    var profileInfoDelegate: ProfileInfoDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        profileInfoDelegate?.profileInfoRequested()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol ProfileInfoDelegate {
    func profileInfoRequested()
}
