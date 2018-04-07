//
//  ContainerViewController.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/5/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import UIKit

class ContainerViewController: SlideMenuController {

    @IBOutlet weak var notificationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Notification binding
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidUpdate(_:)),
            name: themeUpdateNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedNotificationRequest(_:)),
            name: displayMsgNotification,
            object: nil
        )
        
        // Do any additional setup after loading the view.
        notificationLabel.isHidden = true
        notificationLabel.clipsToBounds = true
        notificationLabel.layer.cornerRadius = uiCornerRadius
    }
    
    @objc func receivedNotificationRequest(_ notification: Notification) {
        displayNotification(msg: notification.object as! String)
    }
    
    /**
     Flashes a notification in the center of the screen
     */
    private func displayNotification(msg: String) {
        if !shouldShowAlerts() {return}
        notificationLabel.isHidden = false
        notificationLabel.text = msg
        UIView.animate(withDuration: 1.5, animations: {[unowned self] in
            self.notificationLabel.alpha = 0
            }, completion: {_ in
                self.notificationLabel.alpha = 1.0
                self.notificationLabel.isHidden = true
        })
        
        let alert = UIAlertController(style: .alert)
        alert.addColorPicker(color: .blue) { color in
            // action with selected color
        }
        alert.childViewControllers[0].preferredContentSize.height = 400
        alert.addAction(title: "Done", style: .cancel)
        alert.show()
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
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Main") {
            self.mainViewController = controller
            self.delegate = mainViewController as? SlideMenuControllerDelegate
        }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Left") {
            self.leftViewController = controller
        }
        super.awakeFromNib()
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
