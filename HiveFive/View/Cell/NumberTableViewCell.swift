//
//  NumberTableViewCell.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/7/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import UIKit
import Foundation

class NumberTableViewCell: UITableViewCell, KPAssociate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    var indexPath: IndexPath?
    var kpHackable: KPHackable? {
        didSet {
            let ratio = kpHackable?.getValue() as! CGFloat
            numberLabel.text = String(ratio.description)
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

}

extension String {
    subscript(range: CountableClosedRange<Int>) -> String {
        return enumerated().filter{$0.offset >= range.first! && $0.offset < range.last!}
            .reduce(""){$0 + String($1.element)}
    }
}
