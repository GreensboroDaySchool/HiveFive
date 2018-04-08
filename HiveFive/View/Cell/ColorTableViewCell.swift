//
//  ColorTableViewCell.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/7/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import Foundation
import UIKit

class ColorSegueTableViewCell: UITableViewCell, KPAssociate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    var indexPath: IndexPath?
    var kpHackable: KPHackable? {
        didSet {
            colorView.backgroundColor = kpHackable?.getValue() as? UIColor
            nameLabel.text = kpHackable?.key
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = colorView?.backgroundColor // Preserves the color of the color view.
        super.setSelected(selected, animated: animated) // this changes the background color of all subviews
        colorView?.backgroundColor = color
        
        // Configure the view for the selected state
    }
    
    func didSelect() {
        let alert = UIAlertController(style: .alert)
        alert.addColorPicker(color: colorView.backgroundColor!) {[unowned self] color in
            self.handleValueUpdate(color)
        }
        alert.childViewControllers[0].preferredContentSize.height = 400
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive) {[unowned self] _ in
            self.cancelUpdate()
        })
        alert.show()
    }
    
}
