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

//MARK: Data Source
struct NodeDescription {
    var identity: Identity
    var description: String
    var demonstration: HexNode // the node of concern, selected.
}

var nodeDescriptions: [NodeDescription] = [
    .init(
            identity: .grasshopper,
            description: "Grasshopper can jump across consecutive nodes oriented at the same direction." +
            "It can not jump over to the very end, however, if there exist a discontinuity between the starting point and the destination." +
            "There are three grasshoppers at each player's disposal by the default rule.",
            demonstration: Hive.defaultHive.root!

    ),
    .init(
            identity: .queenBee,
            description: "This is the most important piece in the game. " +
                    "It can only move by one step at a time and can not squeeze into tiny openings. " +
                    "The queen bee has to be out on the board within the first four moves.",
            demonstration: Hive.defaultHive.root!
    ),
    .init(
            identity: .spider,
            description: "Moves three steps at a time. Cannot move back to previous positions in these three steps. " +
                    "Cannot squeeze into tiny openings either.",
            demonstration: Hive.defaultHive.root!
    ),
    .init(
            identity: .soldierAnt,
            description: "This is probably the most useful insect in the game - " +
                    " it can go anywhere outside the hive structure in one move. ",
            demonstration: Hive.defaultHive.root!
    ),
    .init(
            identity: .beetle,
            description: "If used wisely, you can use the beetle to drive your opponent insane - " +
                    "the rule concerning the beetle is quite complicated though. " +
                    "First thing first - the beetle can go on top of another piece! (Including another beetle)." +
                    "It can also squeeze into tiny openings. This makes it extremely useful. " +
                    "When the beetle is on top of another piece, it suppress the other piece, overriding" +
                    "the color of the suppressed piece. In english, it replaces the suppressed node" +
                    "and locks it in place.",
            demonstration: Hive.defaultHive.root!
    ),
]
