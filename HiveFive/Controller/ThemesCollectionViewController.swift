//
//  PatternsCollectionViewController.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/5/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell3"

class ThemesCollectionViewController: UICollectionViewController {

    var cached = [IndexPath:UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        preloadRenderedThemes()
    }
    
    /**
     Preloads rendered themes into cached dictionary. This solved the issue of lagging.
     */
    private func preloadRenderedThemes() {
        themes.enumerated().map{(IndexPath(row: $0.offset, section: 0), $0.element)}
            .forEach { (indexPath, theme) in
                let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThemesCollectionViewCell
                prepareCell(cell, theme: theme)
                cached[indexPath] = cell.asImage()
                }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return themes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThemesCollectionViewCell
        if let cachedImg = cached[indexPath] {
            cell.contentView.isHidden = true
            cell.backgroundView = UIImageView(image: cachedImg)
        } else {
            prepareCell(cell, theme: themes[indexPath.row])
            if !shouldUseRectangularUI() {cell.layer.cornerRadius = uiCornerRadius}
            cached[indexPath] = cell.asImage()
        }
        return cell
    }
    
    private func prepareCell(_ cell: ThemesCollectionViewCell, theme: Theme) {
        cell.boardView.patterns = theme.patterns
        cell.boardView.isUserInteractionEnabled = false
        cell.boardView.nodeRadius = currentNodeSize() / 2
        cell.boardView.root = Hive.defaultHive.root
        cell.boardView.centerHiveStructure()
        cell.nameLabel.text = theme.name
        if !shouldUseRectangularUI() {cell.layer.cornerRadius = uiCornerRadius}
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let theme = themes[indexPath.row]
        NotificationCenter.default.post(
            name: themeUpdateNotification,
            object: theme.patterns
        )
        save(id: themeId, obj: theme.encode())
//        collectionView.visibleCells.forEach{($0 as! ThemesCollectionViewCell).bezel.backgroundColor = nil}
//        (collectionView.cellForItem(at: indexPath) as! ThemesCollectionViewCell).bezel.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
        navigationController?.popToRootViewController(animated: true)
    }

}

// MARK: Data Source
struct Theme {
    var name: String
    var patterns: [Identity:String]
    
    func encode() -> String {
        return name
    }
    
    static func decode(_ name: String) -> Theme {
        return themes.filter{$0.name == name}[0]
    }
}

/**
 Themes
 */
var themes: [Theme] = [
    .init(name: "Mathematics", patterns: [
        .grasshopper:"𝝣",
        .queenBee:"𝝠",
        .beetle:"𝝧",
        .spider:"𝝮",
        .soldierAnt:"𝝭",
        .dummy:"𝝬"
        ]),
    .init(name: "Chinese", patterns: [
        .grasshopper:"蜢",
        .queenBee:"皇",
        .beetle:"甲",
        .spider:"蛛",
        .soldierAnt:"蚁",
        .dummy:"笨"
        ]),
    .init(name: "Letters", patterns: [
        .grasshopper:"𝔾",
        .queenBee:"ℚ",
        .beetle:"𝔹",
        .spider:"𝕊",
        .soldierAnt:"𝔸",
        .dummy:"𝔻"
        ]),
    .init(name: "Chess Dark", patterns: [
        .grasshopper:"♞",
        .queenBee:"♛",
        .beetle:"♟",
        .spider:"♝",
        .soldierAnt:"♜",
        .dummy:"♚"
        ]),
    .init(name: "Chess Light", patterns: [
        .grasshopper:"♘",
        .queenBee:"♕",
        .beetle:"♙",
        .spider:"♗",
        .soldierAnt:"♖",
        .dummy:"♔"
        ]),
    .init(name: "Currency", patterns: [
        .grasshopper:"$",
        .queenBee:"€",
        .beetle:"¥",
        .spider:"¢",
        .soldierAnt:"£",
        .dummy:"₽"
        ]),
    .init(name: "Stars", patterns: [
        .grasshopper:"✡︎",
        .queenBee:"✪",
        .beetle:"✶",
        .spider:"★",
        .soldierAnt:"✩",
        .dummy:"▲"
        ]),
    .init(name: "Physics", patterns: [
        .grasshopper:"𝜞︎",
        .queenBee:"𝜟",
        .beetle:"𝜭",
        .spider:"𝜮",
        .soldierAnt:"𝜴",
        .dummy:"𝜩"
        ]),
    .init(name: "Skewed", patterns: [
        .grasshopper:"𝞝",
        .queenBee:"𝞡",
        .beetle:"𝞨",
        .spider:"𝞚",
        .soldierAnt:"𝞧",
        .dummy:"𝞦"
        ]),
]

