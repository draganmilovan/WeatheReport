//
//  Dependency.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 1/20/18.
//  Copyright © 2018 Dragan Milovanovic. All rights reserved.
//

import Foundation


struct Dependency {
    
    var dataManager: WeatherDataManager?
    var locationsManager: LocationsManager?
    
    init(dataManager: WeatherDataManager? = nil, locationsManager: LocationsManager? = nil) {
        self.dataManager = dataManager
        self.locationsManager = locationsManager
    }
    
    static var empty: Dependency {
        return Dependency()
    }
    
}


protocol NeedsDependency: class {
    var dependency: Dependency? { get set}
}














