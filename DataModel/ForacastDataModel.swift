//
//  ForacastDataModel.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 12/16/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import Foundation

final class ForecastData {
    
    var day: String?
    var time: String?
    var iconName: String?
    var temperature: String?
    
    init(day: String?, time: String?, iconName: String?, temperature: String?) {
        self.day = day?.uppercased()
        self.time = time
        self.iconName = iconName
        self.temperature = temperature
    }
    
}


extension ForecastData: Hashable {
    
    var hashValue: Int {
        return day.hashValue ^ time.hashValue ^ iconName.hashValue ^ temperature.hashValue
    }
    
    static func ==(lhs: ForecastData, rhs: ForecastData) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    
}
