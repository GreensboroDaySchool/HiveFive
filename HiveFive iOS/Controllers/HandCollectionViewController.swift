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

private let reuseIdentifier = "cell4"

class HandCollectionViewController: UICollectionViewController {
    
    var hive: Hive {
        return Hive.sharedInstance
    }
    
    var hand = UserDefaults.useExpansionPack() ? Hive.expandedHand : Hive.standardHand
    var color: Color = .black
    var patterns = UserDefaults.currentTheme().patterns
    var isIpad: Bool {
        return traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular
    }

    var nodeSize = CGFloat(UserDefaults.nodeSize()) {
        didSet {
            updateBoundsAccordingToNodeSize()
            updateFlowLayout()
        
            // OMG!!! What a solution, I encountered the exact same bug!
            // https://stackoverflow.com/questions/45391651/cell-size-not-updating-after-changing-flow-layouts-itemsize
            // I am getting so good at search stack overflow...
            collectionViewLayout.invalidateLayout()
            collectionView?.layoutIfNeeded()
            collectionView?.reloadData()
        }
    }
    
    private var orientationIsLandscape = UIDevice.current.orientation.isLandscape
    
    /**
     The index of the cell that is currently selected
     */
    var selectedIndex: IndexPath? {
        willSet {
            collectionView?.subviews.forEach{
                ($0 as? HandCollectionViewCell)?.boardView.nodeViews[0].isSelected = false
            }
            if let val = newValue {
                getNodeView(at: val)?.isSelected = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Notification Binding
        observe(.handUpdated, #selector(handDidUpdate(_:)))
        observe(.themeUpdated, #selector(themeDidUpdate(_:)))
        observe(.didCancelSelection, #selector(didCancelSelection(_:)))
        observe(.didPlaceSelection, #selector(didPlaceSelection(_:)))
        observe(.nodeSizeUpdated, #selector(preferredNodeSizeDidChange(_:)))
        
        // Detect orientation change
        observe(UIDevice.orientationDidChangeNotification, #selector(deviceOrientationDidChange(_:)))
    }
    
    private func updateBoundsAccordingToNodeSize() {
        if isIpad { return } // If size class is regular, then we leave the bounds as-is
        if let collectionView = collectionView {
            let current = collectionView.bounds.size
            switch UIDevice.current.orientation {
            case .landscapeLeft, .landscapeRight: orientationIsLandscape = true
            case .portrait: orientationIsLandscape = false
            default: return
            }
            
            if orientationIsLandscape {
                collectionView.bounds.size = CGSize(width: nodeSize, height: current.height)
            } else {
                collectionView.bounds.size = CGSize(width: current.width, height: nodeSize)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        updateBoundsAccordingToNodeSize()
        updateFlowLayout()
    }
    
    private func updateFlowLayout() {
        if let collectionView = collectionView {
            let flowLayout = (collectionViewLayout as! UICollectionViewFlowLayout)
            let w = collectionView.bounds.width, h = collectionView.bounds.height
            let length = (w < h ? w : h) - 10
            flowLayout.itemSize = CGSize(width: length, height: length)
        }
    }
    
    @objc func preferredNodeSizeDidChange(_ notification: Notification) {
        nodeSize = CGFloat(UserDefaults.nodeSize())
        updateFlowLayout()
    }
    
    @objc func deviceOrientationDidChange(_ notification: Notification) {
        if isIpad { return } // If size class is regular, then we leave the bounds as-is
        if let orientation = (notification.object as? UIDevice)?.orientation {
            let flowLayout = (collectionViewLayout as! UICollectionViewFlowLayout)
            switch orientation {
            case .landscapeLeft, .landscapeRight: flowLayout.scrollDirection = .vertical
            case .portrait: flowLayout.scrollDirection = .horizontal
            default: return
            }
            collectionView?.reloadData()
        }
    }
    
    @objc func didCancelSelection(_ notification: Notification) {
        selectedIndex = nil
    }
    
    @objc func didPlaceSelection(_ notification: Notification) {
        if let boardView = getCell(at: selectedIndex!)?.boardView! {
            let node = boardView.root!
            boardView.root = node.identity.new(color: node.color) // The old node has been used, instantiate a new one.
        }
        selectedIndex = nil
    }
    
    @objc func themeDidUpdate(_ notification: Notification) {
        patterns = notification.object as! [Identity: String]
        collectionView?.reloadData()
    }
    
    @objc func handDidUpdate(_ notification: Notification) {
        if let (hand, color) = notification.object as? (Hand, Color) {
            self.hand = hand
            self.color = color
            collectionView?.reloadData()
        }
    }
    
    private func getCell(at indexPath: IndexPath) -> HandCollectionViewCell? {
        return collectionView?.cellForItem(at: indexPath) as? HandCollectionViewCell
    }
    
    private func getNodeView(at indexPath: IndexPath) -> NodeView? {
        return getCell(at: indexPath)?.boardView.nodeViews[0]
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hand.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HandCollectionViewCell
        let pair = Array(hand)[indexPath.row]
        let node = pair.key.new(color: color)
        
        // Configure board
        let board = cell.boardView!
        board.isUserInteractionEnabled = false
        board.patterns = patterns
        board.root = node
        
        // Configure node radius
        let nodeRadius = cell.bounds.midX < cell.bounds.midY ? cell.bounds.midX : cell.bounds.midY
        board.nodeRadius = nodeRadius
        
        // Center node view
        let nodeView = board.nodeViews[0]
        nodeView.isSelected = indexPath == selectedIndex
        let cellCtr = CGPoint(x: cell.bounds.midX, y: cell.bounds.midY)
        let translation = CGPoint(x: nodeView.bounds.width / 2, y: nodeView.bounds.height / 2)
        board.rootCoordinate = cellCtr - translation
        
        // Configure cell
        cell.indexPath = indexPath
        cell.numLabel.text = String(pair.value)
        cell.numLabel.font = cell.numLabel.font.withSize([12,14,17][UserDefaults.nodeSizeIndex()])
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
        post(key: .didSelectNewNode, object: Array(hand)[indexPath.row].key.new(color: color))
    }
}

extension HandCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        updateFlowLayout()
        return (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    }
}
