//
//  WRCollectionViewController.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 11/28/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import UIKit

class WRCollectionViewController: UIViewController {

    var dataManager: WeatherDataManager? {
        didSet {
            if !self.isViewLoaded { return }
            
            wrCollectionView.reloadData()
        }
    }
    
    @IBOutlet weak var backgroundImage: UIImageView!
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
        
        dataManager?.updateAll()

        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)),
                                               name: Notification.Name("NotificationIdentifier"),
                                               object: nil)
        
        
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
        return dataManager?.weatherDatas.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataManager = dataManager else { fatalError("Missing Data Manager!") }
        
        let wrCell: WRCell = wrCollectionView.dequeueReusableCell(withReuseIdentifier: "WRCell", for: indexPath) as! WRCell
        
        wrCell.weatherData = dataManager.weatherDatas[indexPath.item]
        
        return wrCell
    }
    
}


extension WRCollectionViewController {
    
    @objc func methodOfReceivedNotification(notification: NSNotification){
        
        updateUI()
    }
    
    func updateUI() {
        wrCollectionView.reloadData()
        pageControl.numberOfPages = dataManager?.weatherDatas.count ?? 0

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


























