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
    var dayTime: Bool = true
    var cityID: String?
    var tempMin: Int?
    var tempMax: Int?
    var sunRise: Int?
    var sunSet: Int?
    var uvIndex: String?
    var windDirection: String?
    var windSpeed: String?
    var humidity: Int?
    var description: String?
    var pressure: Int?
    
    var times: [String] = []
    var temperatures: [String] = []
    var conditions: [Int] = []
    var weatherIconsNames: [String] = []
    var temperaturesMin: [Int] = []
    var temperaturesMax: [Int] = []
    var cityIDs: [Int] = []
    
    
    
    // Method returns true if is daytime at the time
    func updateTimeOfDay() -> Bool {
        
        let sunRise = Date(timeIntervalSince1970: Double(self.sunRise!))
        let sunSet = Date(timeIntervalSince1970: Double(self.sunSet!))
        let date = Date()
        
        if date >= sunRise && date <= sunSet {
            
            return true
            
        } else { return false }
        
    }
    
    
    // Method returns the name of the weather condition image from API condition code
    func updateWeatherIcon(condition: Int, dayTime: Bool) -> String {
        
        var iconName = ""
        let dayTime = self.dayTime
        
        
        switch (condition) {
            
        case 200...209, 771...780, 960, 961 :
            iconName = "showerAndThunder"
            
        case 210...229 :
            iconName = "cloudAndThunder"
            
        case 230...299 :
            iconName = "rainAndThunder"
            
        case 300...399, 500, 501 :
            iconName = "rainCloud"
            
        case 502...510, 520...599 :
            iconName = "shower"
            
        case 600...610, 620...699 :
            iconName = "snowCloud"
            
        case 611...619, 511 :
            iconName = "hailAndSnow"
            
        case 700...740, 750...770 :
            if dayTime {
                iconName = "sunAndFog"
            } else { iconName = "moonAndFog"}
            
        case 741 :
            iconName = "fog"
            
        case 781, 900 :
            iconName = "tornado"
            
        case 800, 904 :
            if dayTime {
                iconName = "sun"
            } else { iconName = "moon"}
            
        case 801 :
            if dayTime {
                iconName = "sunAndSmallCloud"
            } else { iconName = "moonAndSmallCloud"}
            
        case 802, 803 :
            if dayTime {
                iconName = "sunAndBigCloud"
            } else { iconName = "moonAndBigCloud"}
            
        case 804 :
            iconName = "cloud"
            
        case 901, 902, 962 :
            iconName = "thunder"
            
        case 903 :
            iconName = "snow"
            
        case 905 :
            iconName = "wind"
            
        case 906 :
            iconName = "hail"
            
        default :
            iconName = "na"
        }

        return iconName
    }
    
    
    // Method returns the cardinal point from the wind direction in degrees
    func windDirectionCardinalPoint(degrees: Int) -> String {
        
        switch (degrees) {
            
        case 0...22, 337...360 :
            return "N"
            
        case 23...67 :
            return "NE"
            
        case 68...111 :
            return "E"
            
        case 112...157 :
            return "SE"
            
        case 158...202 :
            return "S"
            
        case 203...247 :
            return "SW"
            
        case 248...292 :
            return "W"
            
        case 293...336 :
            return "NW"
            
        default:
            return "-"
        }
    }
    
    
    // Method returns time in hours and minutes from Unix Timestamp
    func convertUnixTimestampToTime(timeStamp: Int) -> String {
        
        let date = Date(timeIntervalSince1970: Double(timeStamp))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let time = formatter.string(from: date)
        
        return time
    }
    
    
    // Method returns time in hours from Unix Timestamp
    func convertUnixTimestampToHours(timeStamp: Int) -> String {
        
        let date = Date(timeIntervalSince1970: Double(timeStamp))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        
        let time = formatter.string(from: date)
        
        return time
    }
    
}


























