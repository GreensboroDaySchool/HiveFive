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
import Hive5Common

class HelpPageViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = scrollView.frame.size.width
        let height = scrollView.frame.size.height
        let padding: CGFloat = 20
        
        scrollView.contentSize = CGSize(width: padding + (width + padding) * CGFloat(nodeDescriptions.count), height: height)
        
        // Generate content for scroll view using the frame height and width as the reference point
        nodeDescriptions.enumerated().forEach { (i, element) in
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(containerView)
            containerView.backgroundColor = .white
            containerView.tag = i
            
            let currentX = padding + (width + padding) * CGFloat(i)
            
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(
                    equalTo: scrollView.leadingAnchor,
                    constant: currentX
                ),
                containerView.trailingAnchor.constraint(
                    equalTo: scrollView.leadingAnchor,
                    constant: currentX + width
                ),
                containerView.centerYAnchor.constraint(
                    equalTo: scrollView.centerYAnchor
                ),
                containerView.heightAnchor.constraint(
                    equalToConstant: height
                )
            ])
            
            containerView.clipsToBounds = true
            if !UserDefaults.useRectangularUI() {
                containerView.layer.cornerRadius = 10
            }
            
            // Add child view controller view to container view
            let controller = storyboard!.instantiateViewController(withIdentifier: "HelpItem") as! HelpItemViewController
            controller.nodeDescription = element
            addChild(controller)
            
            
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(controller.view)
            
            NSLayoutConstraint.activate([
                controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                controller.view.widthAnchor.constraint(equalTo: containerView.widthAnchor),
                controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                controller.view.heightAnchor.constraint(equalTo: containerView.heightAnchor)
                ])

            controller.didMove(toParent: self)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: Data Source

struct NodeDescription {
    var identity: Identity
    var description: String
    var demonstration: HexNode // the node of concern, selected.
}

fileprivate var nodeDescriptions: [NodeDescription] = [
    .init(
            identity: .grasshopper,
            description: "Grasshopper can jump across consecutive nodes in the same direction." +
            "It can not jump over to the very end, however, if there exist a discontinuity between the starting point and the destination.",
            demonstration: Hive.makeNewDefaultHive().root!
    ),
    .init(
            identity: .queenBee,
            description: "This is the most important piece in the game. " +
                    "It can only move by one step at a time and can not squeeze into tiny openings. " +
                    "The queen bee has to be out on the board within the first four moves.",
            demonstration: Hive.makeNewDefaultHive().root!
    ),
    .init(
            identity: .spider,
            description: "Moves three steps at a time. Cannot move back to previous positions in these three steps. " +
                    "Cannot squeeze into tiny openings either.",
            demonstration: Hive.makeNewDefaultHive().root!
    ),
    .init(
            identity: .soldierAnt,
            description: "This is probably the most useful insect in the game - " +
                    " it can go anywhere outside the hive structure in one move. ",
            demonstration: Hive.makeNewDefaultHive().root!
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
            demonstration: Hive.makeNewDefaultHive().root!
    ),
    .init(
        identity: .mosquito,
        description: "When the mosquito is connected on the first level of the hive, it can mimic any of the pieces that it touches. A mosquito cannot mimic another mosquito, however. For example, when a mosquito is only touching another mosquito, it cannot move. When a mosquito mimics a beetle and gets on top of the hive structure, it stays as a beetle until it gets down.",
        demonstration: Hive.makeNewDefaultHive().root!
    ),
    .init(
        identity: .ladyBug,
        description: "The lady bug moves 2 steps on top of the hive, then moves down in the final step.",
        demonstration: Hive.makeNewDefaultHive().root!
    )
]
