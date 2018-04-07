//
//  PageViewController.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/6/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import UIKit

class HelpPageViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var padding: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * 12, height: scrollView.frame.size.height)
        scrollView.isPagingEnabled = true
        
        // Generate content for our scroll view using the frame height and width as the reference point
        for i in 0..<12 {
            
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(containerView)
            containerView.backgroundColor = .white
            containerView.tag = i
            
            let currentX = scrollView.frame.size.width * CGFloat(i) + padding
            
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(
                    equalTo: scrollView.leadingAnchor,
                    constant: currentX
                ),
                containerView.widthAnchor.constraint(
                    equalToConstant: scrollView.frame.size.width - padding * 2
                ),
                containerView.centerYAnchor.constraint(
                    equalTo: scrollView.centerYAnchor
                ),
                containerView.heightAnchor.constraint(
                    equalToConstant: scrollView.frame.size.height - padding
                )
            ])
            
            if !shouldUseRectangularUI() {
                containerView.clipsToBounds = true
                containerView.layer.cornerRadius = uiCornerRadius
            }
            
            // add child view controller view to container view
            let controller = storyboard!.instantiateViewController(withIdentifier: "HelpItem")
            addChildViewController(controller)
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(controller.view)

            NSLayoutConstraint.activate([
                controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                controller.view.widthAnchor.constraint(equalTo: containerView.widthAnchor),
                controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                controller.view.heightAnchor.constraint(equalTo: containerView.heightAnchor)
                ])

            controller.didMove(toParentViewController: self)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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
