//
//  ForacastDataModel.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 12/16/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import Foundation

class ForecastData {
    
    var time: String?
    var iconName: String?
    var temperature: String?
    
    init(time: String?, iconName: String?, temperature: String?) {
        self.time = time
        self.iconName = iconName
        self.temperature = temperature
    }
    
}
