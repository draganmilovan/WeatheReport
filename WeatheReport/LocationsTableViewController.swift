//
//  LocationsTableViewController.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 12/18/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import UIKit

class LocationsTableViewController: UIViewController {
    
    // Data source
    var dataManager: WeatherDataManager? {
        didSet {
            if !self.isViewLoaded { return }
            print("locationsList!")
            locationTableView.reloadData()
        }
    }

    @IBOutlet weak fileprivate var locationTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
























