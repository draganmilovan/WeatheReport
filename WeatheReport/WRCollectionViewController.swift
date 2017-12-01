//
//  WRCollectionViewController.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 11/28/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import UIKit

class WRCollectionViewController: UIViewController {

    
    @IBOutlet fileprivate weak var wrCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register Collection View Cell 
        let wrNib = UINib(nibName: "WRCell", bundle: nil)
        wrCollectionView.register(wrNib, forCellWithReuseIdentifier: "WRCell")
        
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

extension WRCollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let wrCell: WRCell = wrCollectionView.dequeueReusableCell(withReuseIdentifier: "WRCell", for: indexPath) as! WRCell
        // Configure cell!
        
        return wrCell
    }
    
}


extension WRCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Setting cell size to fill screen
        let bounds = collectionView.bounds
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        var size = flowLayout.itemSize
        
        size.height = bounds.height
        size.width = bounds.width
        
        return size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if let indexPath = wrCollectionView.indexPathsForVisibleItems.first {
            pageControl.currentPage = indexPath.row
        }
    }
    
}


























