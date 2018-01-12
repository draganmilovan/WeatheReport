//
//  SearchController.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 1/11/18.
//  Copyright © 2018 Dragan Milovanovic. All rights reserved.
//

import UIKit

class SearchController: UIViewController {
    
    // Data source
    var dataManager: WeatherDataManager? {
        didSet {
            if !self.isViewLoaded { return }
        }
    }
    
    fileprivate var locations: [String] = ["Kraljevo", "Kragujevac", "Krusevac", "Kraljevcani", "Kranj", "Kranjska Gora", "Kravari", "Krestovac"]
    
    @IBOutlet weak fileprivate var addLocationTableView: UITableView!
    @IBOutlet weak fileprivate var searchTextField: UITextField!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


extension SearchController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = addLocationTableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
        
        let loc = locations[indexPath.row]
        cell.configure(with: loc)
        
        return cell
    }
    
}



extension SearchController {
    
}






















