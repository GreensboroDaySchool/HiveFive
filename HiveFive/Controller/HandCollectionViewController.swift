//
//  HandCollectionViewController.swift
//  Hive Five
//
//  Created by Jiachen Ren on 4/5/18.
//  Copyright © 2018 Greensboro Day School. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell4"

class HandCollectionViewController: UICollectionViewController {
    
    var hive: Hive {
        return Hive.sharedInstance
    }
    
    var hand = Hive.defaultHand
    var color: Color = .black
    var patterns = designatedTheme().patterns

    var nodeSize = preferredNodeSizes[nodeSizeIndex()] {
        didSet {
            updateBoundsAccordingToNodeSize()
            updateFlowLayout()
            
            //OMG!!! What a solution, I encountered the exact same bug!
            //https://stackoverflow.com/questions/45391651/cell-size-not-updating-after-changing-flow-layouts-itemsize
            //I am getting so good at search stack overflow...
            collectionViewLayout.invalidateLayout()
            collectionView?.layoutIfNeeded()
            collectionView?.reloadData()
        }
    }
    
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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view
        
        //MARK: Notification Binding
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handDidUpdate(_:)),
            name: handUpdateNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidUpdate(_:)),
            name: themeUpdateNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didCancelSelection(_:)),
            name: didCancelNewPiece,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didPlaceSelection(_:)),
            name: didPlaceNewPiece,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(preferredNodeSizeDidChange(_:)),
            name: preferredNodeSizeNotification,
            object: nil
        )
        
        //detect orientation change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceOrientationDidChange(_:)),
            name: NSNotification.Name.UIDeviceOrientationDidChange,
            object: nil
        )
        
    }
    
    private var orientationIsLandscape = UIDevice.current.orientation.isLandscape
    
    private func updateBoundsAccordingToNodeSize() {
        if let collectionView = collectionView {
            let current = collectionView.bounds.size
            switch UIDevice.current.orientation {
            case .landscapeLeft: fallthrough
            case .landscapeRight: orientationIsLandscape = true
            case .portraitUpsideDown: fallthrough
            case .portrait: orientationIsLandscape = false
            default: break
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
        nodeSize = preferredNodeSizes[nodeSizeIndex()]
        updateFlowLayout()
        
    }
    
    @objc func deviceOrientationDidChange(_ notification: Notification) {
        if let orientation = (notification.object as? UIDevice)?.orientation {
            let flowLayout = (collectionViewLayout as! UICollectionViewFlowLayout)
            switch orientation {
            case .landscapeLeft: fallthrough
            case .landscapeRight:
                flowLayout.scrollDirection = .vertical
            case .portraitUpsideDown: fallthrough
            case .portrait:
                flowLayout.scrollDirection = .horizontal
            default: break
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
            boardView.root = node.identity.new(color: node.color) // the old node has been used, instantiate a new one.
        }
        selectedIndex = nil
    }
    
    @objc func themeDidUpdate(_ notification: Notification) {
        patterns = notification.object as! [Identity:String]
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return hand.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HandCollectionViewCell
        let pair = hand.keyValuePairs[indexPath.row]
        let node = pair.key.new(color: color)
        
        //configure board
        let board = cell.boardView!
        board.isUserInteractionEnabled = false
        board.patterns = patterns
        board.root = node
        
        //configure node radius
        let nodeRadius = cell.bounds.midX < cell.bounds.midY ? cell.bounds.midX : cell.bounds.midY
        board.nodeRadius = nodeRadius
        
        //center node view
        let nodeView = board.nodeViews[0]
        nodeView.isSelected = indexPath == selectedIndex
        let cellCtr = CGPoint(x: cell.bounds.midX, y: cell.bounds.midY)
        let translation = CGPoint(x: nodeView.bounds.width / 2, y: nodeView.bounds.height / 2)
        board.rootCoordinate = cellCtr - translation
        
        //configure cell
        cell.indexPath = indexPath
        cell.numLabel.text = String(pair.value)
        cell.numLabel.font = cell.numLabel.font.withSize([12,14,17][nodeSizeIndex()])
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
        NotificationCenter.default.post(
            name: didSelectNewNodeNotification,
            object: hand.keyValuePairs[indexPath.row].key.new(color: color))
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

}

extension HandCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        updateFlowLayout()
        return (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    }
}
