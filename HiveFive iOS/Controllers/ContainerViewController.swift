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
import HiveFiveCore

@IBDesignable
class ContainerViewController: SlideMenuController {

    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Notification binding
        observe(.themeUpdated, #selector(themeDidUpdate(_:)))
        observe(.displayMessage, #selector(receivedNotificationRequest(_:)))
       
        
        // Do any additional setup after loading the view.
        visualEffectView.isHidden = true
        visualEffectView.clipsToBounds = true
        visualEffectView.layer.cornerRadius = 10
    }
    
    @objc func receivedNotificationRequest(_ notification: Notification) {
        displayNotification(msg: notification.object as! String)
    }
    
    /**
     Flashes a notification in the center of the screen
     */
    private func displayNotification(msg: String) {
        if !UserDefaults.showsAlerts() {return}
        visualEffectView.isHidden = false
        notificationLabel.text = msg
        

        visualEffectView.transform = CGAffineTransform(scaleX: 0, y: 0)
//        self.view!.addSubview(notificationLabel)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseOut, animations: {() -> Void in
            self.visualEffectView.transform = CGAffineTransform.identity
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 1, animations: {[unowned self] in
                self.visualEffectView.alpha = 0
                }, completion: {_ in
                    self.visualEffectView.alpha = 1
                    self.visualEffectView.isHidden = true
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func themeDidUpdate(_ notification: Notification) {
        let patterns = notification.object as! [Identity:String]
        print("received \(patterns)")
        displayNotification(msg: "Theme Updated")
        closeLeft()
    }
    
    override func awakeFromNib() {
        if let main = HFInterface.Board.initialViewController {
            self.mainViewController = main
            self.delegate = mainViewController as? SlideMenuControllerDelegate
        }
        if let left = HFInterface.Menu.initialViewController {
            self.leftViewController = left
        }
        //Place the History view in the right sliding view
        if let right = HFInterface.History.initialViewController {
            self.rightViewController = right
            right.preferredContentSize = view.bounds.size
        }
        super.awakeFromNib()
    }
}
