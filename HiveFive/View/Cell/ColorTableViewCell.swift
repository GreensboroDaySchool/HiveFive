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
