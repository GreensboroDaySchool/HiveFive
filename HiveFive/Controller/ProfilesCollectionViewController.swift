//
//  ProfilesCollectionViewController.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/8/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell3"

class ProfilesCollectionViewController: UICollectionViewController {
    
    var profiles = [NodeViewProfile]()
    var cached = [IndexPath:UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Do any additional setup after loading the view.
        preloadRenderedProfiles()
    }
    
    /**
     Preloads rendered profiles into cached dictionary. This solved the issue of lagging.
     */
    private func preloadRenderedProfiles() {
        profiles = Profile.savedProfiles()
        profiles.enumerated().map{(IndexPath(row: $0.offset, section: 0), $0.element)}
            .forEach { (indexPath, profile) in
                let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThemesCollectionViewCell
                prepareCell(cell, profile: profile)
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
        return profiles.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThemesCollectionViewCell
        if let cachedImg = cached[indexPath] {
            cell.contentView.isHidden = true
            cell.backgroundView = UIImageView(image: cachedImg)
        } else {
            prepareCell(cell, profile: profiles[indexPath.row])
            if !shouldUseRectangularUI() {cell.layer.cornerRadius = uiCornerRadius}
            cached[indexPath] = cell.asImage()
        }
        return cell
    }
    
    private func prepareCell(_ cell: ThemesCollectionViewCell, profile: NodeViewProfile) {
        cell.boardView.isUserInteractionEnabled = false
        cell.boardView.nodeRadius = currentNodeSize() / 2
        cell.boardView.root = Hive.defaultHive.root
        cell.boardView.centerHiveStructure()
        cell.boardView.apply(profile: Profile.load(profile)) // This has to happen last
        cell.nameLabel.text = profile.name!
        if !shouldUseRectangularUI() {cell.layer.cornerRadius = uiCornerRadius}
    }
    
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ThemesCollectionViewCell {
            UIPasteboard.general.string = cell.nameLabel.text
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let profile = profiles[indexPath.row]
        save(id: currentProfileId, obj: profile.name!)
        post(name: profileUpdatedNotification, object: profile)
        post(name: displayMsgNotification, object: "Profile Updated")
        navigationController?.popToRootViewController(animated: true)
    }
    
}

