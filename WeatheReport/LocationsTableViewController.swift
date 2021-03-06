//
//  LocationsTableViewController.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 12/18/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import UIKit

protocol DisplayDelegate {
    func displayLocation()
}

class LocationsTableViewController: UIViewController, NeedsDependency, LocationDelegate {
    
    var dependency: Dependency? {
        didSet {
            if !self.isViewLoaded { return }
            print("locationsList!")
            locationTableView.reloadData()
        }
    }
    
    // Data source
    fileprivate var dataManager: WeatherDataManager? {
        return dependency?.dataManager
    }

    @IBOutlet weak fileprivate var locationTableView: UITableView!
    
    var displayDelegate: DisplayDelegate?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationsInnerSettings()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceived(notification:)),
                                               name: Notification.Name("DataUpdated"),
                                               object: nil)
    }

}


extension LocationsTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager?.weatherDatas.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataManager = dataManager else { fatalError("Missing Data Manager!") }
        
        let cell = locationTableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        let wd = dataManager.weatherDatas[indexPath.row]
        cell.configure(with: wd)

        return cell
    }
    
}




extension LocationsTableViewController {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // Guarding first row from editing
        if indexPath.row == 0 {
            return false
        } else {
            return true
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if indexPath.row == 0 { return }
            
            dataManager?.deleteLocation(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let dataManager = dataManager else { return }
        
        for wd in dataManager.weatherDatas {
            if wd === dataManager.weatherDatas[indexPath.item] {
                wd.selected = true
            } else {
                wd.selected = false
            }
        }

        displayDelegate?.displayLocation()
        
    }
    
}



extension LocationsTableViewController {
    
    //
    // Method for handling received Notification
    //
    @objc func notificationReceived(notification: NSNotification){
        
        locationTableView.reloadData()
    }
    
    
    fileprivate func locationsInnerSettings() {
        
        if let dm = dataManager {
            for wd in dm.weatherDatas {
                wd.selected = true
            }
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "search" {
            
            let destinationVC = segue.destination as! SearchController
            destinationVC.dependency = dependency
            destinationVC.locationDelegate = self
        }
    }
    
    
    @IBAction func unwindSearch(unwindSegue: UIStoryboardSegue) {
        locationTableView.reloadData()
    }
    
    
    func newLocation(data: City) {
        dataManager?.addNewLocation(location: data)
    }
    
}
