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

struct LocationsManager {
    
    var locationsList: [City] = []
    
    
    //
    // Parsing JSON for all available locations API accepts
    //
    mutating func populateLocationlist() {
        
        guard let path = Bundle.main.path(forResource: "cityList", ofType: "json") else { return }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return }
        guard let json = try? JSON(data: data) else { return }

        for l in json {
            locationsList.insert(City(name: "\(l.1["name"].stringValue), \(l.1["country"].stringValue)",
                id: (l.1["id"].intValue),
                coordinate: CLLocationCoordinate2D(latitude: l.1["coord"]["lat"].doubleValue, longitude: l.1["coord"]["lon"].doubleValue)),
                                 
                                 at: (locationsList.count))
        }
        
        print(locationsList.count)
    }
}




















