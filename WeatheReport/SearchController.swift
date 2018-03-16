//
//  SearchController.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 1/11/18.
//  Copyright © 2018 Dragan Milovanovic. All rights reserved.
//

import UIKit

protocol LocationDelegate {
    func newLocation(data: City)
}

class SearchController: UIViewController, NeedsDependency {
    
    var dependency: Dependency? {
        didSet {
            if !self.isViewLoaded { return }
        }
    }
    
    // Data source
    fileprivate var locationsManager: LocationsManager? {
        return dependency?.locationsManager
    }
    
    fileprivate var searchTerm: String? {
        didSet {
            searchingLocation()
        }
    }
    
    fileprivate var locations: [City] = []
    
    @IBOutlet weak fileprivate var addLocationTableView: UITableView!
    @IBOutlet weak fileprivate var searchTextField: UITextField!
    
    
    var locationDelegate: LocationDelegate?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
        cell.configure(with: loc.name)
        
        return cell
    }
    
}


extension SearchController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        locationDelegate?.newLocation(data: locations[indexPath.row])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchTextField.resignFirstResponder()
    }
    
    fileprivate func scrollToFirstRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        addLocationTableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
}



fileprivate extension SearchController {
    
    //
    // Method for using Text Field
    //
    @IBAction func didChangeTextField(_ sender: UITextField) {
        
        guard let st = sender.text else {
            searchTerm = nil
            return
        }
        
        if st.count == 0 {
            searchTerm = nil
            locations.removeAll()
            addLocationTableView.reloadData()
            return
        }
        
        searchTerm = st
    }
    
    
    //
    // Method for finding location from searching term
    //
    func searchingLocation() {
        
        guard let locationsManager = locationsManager else { return }
        guard let st = searchTerm else { return }
        
        DispatchQueue.global(qos: .background).async {
            [unowned self] in
            let predicate = NSPredicate(format: "SELF contains[cd] %@", st)
            
            self.locations = locationsManager.locationsList.filter {
                predicate.evaluate(with: $0.name)
            }
            
            DispatchQueue.main.async {
                self.addLocationTableView.reloadData()
                
                if self.locations.count != 0 {
                    self.scrollToFirstRow()
                    
                } else { return }
                
            }
        }
        
    }
    
}
