//
//  LocationsList.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 1/15/18.
//  Copyright © 2018 Dragan Milovanovic. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation


typealias City = (name: String, id: Int?, coordinate: CLLocationCoordinate2D?)

class LocationsManager {
    
    lazy var locationsList: [City] = {
        let path = Bundle.main.path(forResource: "cityList", ofType: "json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path!))
        let json = try? JSON(data: data!)
        
        var lcns: [City] = []
        
        for l in json! {
            lcns.insert(City(name: "\(l.1["name"].stringValue), \(l.1["country"].stringValue)",
                id: (l.1["id"].intValue),
                coordinate: CLLocationCoordinate2D(latitude: l.1["coord"]["lat"].doubleValue, longitude: l.1["coord"]["lon"].doubleValue)),
                                 
                                 at: (lcns.count))
        }
        return lcns
    }()
    
//    fileprivate func parseJSON(completion: @escaping ([City]) -> Void) {
//        guard let path = Bundle.main.path(forResource: "cityList", ofType: "json") else { return }
//        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return }
//        guard let json = try? JSON(data: data) else { return }
//        var locations: [City] = []
//
//        for l in json {
//            locations.insert(City(name: "\(l.1["name"].stringValue), \(l.1["country"].stringValue)",
//                id: (l.1["id"].intValue),
//                coordinate: CLLocationCoordinate2D(latitude: l.1["coord"]["lat"].doubleValue, longitude: l.1["coord"]["lon"].doubleValue)),
//
//                                 at: (locations.count))
//        }
//        print(locations.count)
//        completion(locations)
//    }
//
//    fileprivate func populate(locations: [City]) {
//        locationsList.append(contentsOf: locations)
//    }
    
    
    
//    init() {
//        parseJSON { locations in
//            self.populate(locations: locations)
//        }
//
//        //populateLocationlist()
//    }


    //
    // Parsing JSON for all available locations API accepts
    //
//    fileprivate func populateLocationlist() {
//
//        guard let path = Bundle.main.path(forResource: "cityList", ofType: "json") else { return }
//        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return }
//        guard let json = try? JSON(data: data) else { return }
//
//        for l in json {
//            locationsList.insert(City(name: "\(l.1["name"].stringValue), \(l.1["country"].stringValue)",
//                id: (l.1["id"].intValue),
//                coordinate: CLLocationCoordinate2D(latitude: l.1["coord"]["lat"].doubleValue, longitude: l.1["coord"]["lon"].doubleValue)),
//
//                                 at: (locationsList.count))
//        }
//
//        print(locationsList.count)
//    }
}
