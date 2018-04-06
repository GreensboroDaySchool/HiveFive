//
//  HandCollectionViewCell.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/5/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import UIKit

class HandCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var boardView: BoardView!
    @IBOutlet weak var numLabel: UILabel!
    var indexPath: IndexPath?
}
