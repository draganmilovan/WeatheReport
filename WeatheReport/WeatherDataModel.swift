//
//  WeatherDataModel.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 10/19/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import Foundation

class WeatherData {
    
    var temperature: Int = 0
    var condition: Int = 0
    var locationName: String = ""
    var weatherIconName: String = ""
    var cityID: Int?
    var tempMin: Int?
    var tempMax: Int?
    var sunRise: Int?
    var sunSet: Int?
    
    // Method returns the name of the weather condition image from API condition code
    func updateWeatherIcon(condition: Int) -> String {
        
        switch (condition) {
            
        case 200...209, 771...780, 960, 961 :
            return "showerAndThunder"
            
        case 210...229 :
            return "cloudAndThunder"
            
        case 230...299 :
            return "rainAndThunder"
            
        case 300...399, 500, 501 :
            return "rainCloud"
            
        case 502...510, 520...599 :
            return "shower"
            
        case 600...610, 620...699 :
            return "snowCloud"
            
        case 611...619, 511 :
            return "hailAndSnow"
            
        case 700...740, 750...770 :
            return "sunAndFog"
            
        case 741 :
            return "fog"
            
        case 781, 900 :
            return "tornado"
            
        case 800, 904 :
            return "sun"
            
        case 801 :
            return "sunAndSmallCloud"
            
        case 802, 803 :
            return "sunAndBigCloud"
            
        case 804 :
            return "cloud"
            
        case 901, 902, 962 :
            return "thunder"
            
        case 903 :
            return "snow"
            
        case 905 :
            return "wind"
            
        case 906 :
            return "hail"
            
        default :
            return "N/A"
        }
        
    }
    
}




























