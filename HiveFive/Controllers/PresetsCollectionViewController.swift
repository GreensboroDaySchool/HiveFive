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

private let reuseIdentifier = "cell3"

class PresetsCollectionViewController: UICollectionViewController {
    
    var presets = [NodeViewPreset]()
    var cached = [IndexPath:UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRenderedPresets()
    }
    
    /// Preloads rendered presets into cached dictionary. This solved the issue of lagging.
    private func loadRenderedPresets() {
        presets = Preset.savedPresets()
        presets.enumerated().map{(IndexPath(row: $0.offset, section: 0), $0.element)}
            .forEach { (indexPath, preset) in
                let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThemesCollectionViewCell
                prepareCell(cell, preset: preset)
                cached[indexPath] = cell.asImage()
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThemesCollectionViewCell
        if let cachedImg = cached[indexPath] {
            cell.contentView.isHidden = true
            cell.backgroundView = UIImageView(image: cachedImg)
        } else {
            prepareCell(cell, preset: presets[indexPath.row])
            if !UserDefaults.useRectangularUI() {cell.layer.cornerRadius = 10}
            cached[indexPath] = cell.asImage()
        }
        return cell
    }
    
    private func prepareCell(_ cell: ThemesCollectionViewCell, preset: NodeViewPreset) {
        cell.boardView.isUserInteractionEnabled = false
        cell.boardView.nodeRadius = CGFloat(UserDefaults.nodeSize()) / 2
        cell.boardView.root = Hive.defaultHive.root
        cell.boardView.centerHiveStructure()
        cell.boardView.apply(Preset.load(preset)) // This has to happen last
        cell.nameLabel.text = preset.name!
        if !UserDefaults.useRectangularUI() {
            cell.layer.cornerRadius = 10
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ThemesCollectionViewCell {
            UIPasteboard.general.string = cell.nameLabel.text
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let preset = presets[indexPath.row]
        UserDefaults.set(preset.name!, forKey: .currentPreset)
        post(key: .presetUpdated, object: preset)
        post(key: .displayMessage, object: "Preset Updated")
        navigationController?.popToRootViewController(animated: true)
    }
}
