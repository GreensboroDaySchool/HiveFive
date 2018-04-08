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
            
//            let imgView = UIImageView(image: #imageLiteral(resourceName: "hashtag_img"))
//            imgView.tintColor
            
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

extension String {
    subscript(range: CountableClosedRange<Int>) -> String {
        return enumerated().filter{$0.offset >= range.first! && $0.offset < range.last!}
            .reduce(""){$0 + String($1.element)}
    }
}
