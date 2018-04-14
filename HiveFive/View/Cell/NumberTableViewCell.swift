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
import Foundation

class NumberTableViewCell: UITableViewCell, KPAssociate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    var pendingText: String? = ""
    
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
        let alert = UIAlertController(style: .alert, title: nameLabel.text)
        let config: TextField.Config = { textField in
            textField.becomeFirstResponder()
            textField.textColor = .black
            textField.placeholder = "# between 0 & 1"
            textField.left(image: #imageLiteral(resourceName: "pencil_img"), color: .black)
            textField.leftViewPadding = 12
            textField.borderWidth = 1
            textField.cornerRadius = 8
            textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
            textField.backgroundColor = nil
            textField.keyboardAppearance = .default
            textField.keyboardType = .decimalPad
            textField.returnKeyType = .done
            textField.action {[unowned self] textField in
                self.pendingText = textField.text
            }
        }
        alert.addOneTextField(configuration: config)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel){[unowned self] _ in
            self.cancelUpdate()
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default){[unowned self] _ in
            if let number = Double(self.pendingText!) {
                if number <= 1 && number >= 0 {
                    self.handleValueUpdate(CGFloat(number))
                    return
                }
            }
            post(name: displayMsgNotification, object: "Invalid Input")
            self.cancelUpdate()
        })
        
        alert.show()
    }

}
