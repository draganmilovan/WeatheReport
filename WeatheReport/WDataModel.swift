//
//  WeatherDataModel.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 10/19/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import Foundation

class WData {
    
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
    var weatherIconsNames: [String] = []
    var temperaturesMin: [Int] = []
    var temperaturesMax: [Int] = []
    var cityIDs: [Int] = []
    
    
    
    enum TimeFormat: String {
        case Hours = "HH"
        case HoursAndMinutes = "HH:mm"
        case Minutes = "mm"
    }
    
    
    
    // Method returns true if is daytime at the time
    func updateTimeOfDay() -> Bool {
        
        let sunRise = Date(timeIntervalSince1970: Double(self.sunRise!))
        let sunSet = Date(timeIntervalSince1970: Double(self.sunSet!))
        let date = Date()
        
        if date >= sunRise && date <= sunSet {
            
            return true
            
        } else { return false }
        
    }
    
    
    // Method returns true if is daytime for certain time
    func timeOfDay(for time: Int, inFormat: TimeFormat) -> Bool {
        
        let t = Int(self.convertUnixTimestampToTime(timeStamp: time, format: inFormat))
        let sunRise = Int(self.convertUnixTimestampToTime(timeStamp: self.sunRise!, format: inFormat))
        let sunSet = Int(self.convertUnixTimestampToTime(timeStamp: self.sunSet!, format: inFormat))
        
        if t! >= sunRise! && t! <= sunSet! {
            
            return true
            
        } else { return false }
        
    }
    
    enum Time {
        case now
        case time
    }
    
    
    func tod(for moment: Time, time: Int?, inFormat: TimeFormat) -> Bool {
        
        var t: Double
        var sunRise: Double
        var sunSet: Double
        
        switch moment {
        case .now:
            if inFormat == .HoursAndMinutes {
                let sunRiseHour = Double(self.convertUnixTimestampToTime(timeStamp: self.sunRise!, format: .Hours))
                let sunRiseMinutes = Double(self.convertUnixTimestampToTime(timeStamp: self.sunRise!, format: .Minutes))
                sunRise = sunRiseHour! + (sunRiseMinutes! / 60.0)
                
                let sunSetHour = Double(self.convertUnixTimestampToTime(timeStamp: self.sunSet!, format: .Hours))
                let sunSetMinutes = Double(self.convertUnixTimestampToTime(timeStamp: self.sunSet!, format: .Minutes))
                sunSet = sunSetHour! + (sunSetMinutes! / 60.0)
                
                let tHour = Double(self.convertUnixTimestampToTime(timeStamp: Int(Date().timeIntervalSince1970), format: .Hours))
                let tMinutes = Double(self.convertUnixTimestampToTime(timeStamp: Int(Date().timeIntervalSince1970), format: .Minutes))
                t = tHour! + (tMinutes! / 60.0)
                
            } else {
                sunRise = Double(self.convertUnixTimestampToTime(timeStamp: self.sunRise!, format: inFormat))!
                sunSet = Double(self.convertUnixTimestampToTime(timeStamp: self.sunSet!, format: inFormat))!
                t = Double(self.convertUnixTimestampToTime(timeStamp: Int(Date().timeIntervalSince1970), format: inFormat))!
                
            }
            
        case .time:
            if inFormat == .HoursAndMinutes {
                let sunRiseHour = Double(self.convertUnixTimestampToTime(timeStamp: self.sunRise!, format: .Hours))
                let sunRiseMinutes = Double(self.convertUnixTimestampToTime(timeStamp: self.sunRise!, format: .Minutes))
                sunRise = sunRiseHour! + (sunRiseMinutes! / 60.0)
                
                let sunSetHour = Double(self.convertUnixTimestampToTime(timeStamp: self.sunSet!, format: .Hours))
                let sunSetMinutes = Double(self.convertUnixTimestampToTime(timeStamp: self.sunSet!, format: .Minutes))
                sunSet = sunSetHour! + (sunSetMinutes! / 60.0)
                
                let tHour = Double(self.convertUnixTimestampToTime(timeStamp: time!, format: .Hours))
                let tMinutes = Double(self.convertUnixTimestampToTime(timeStamp: time!, format: .Minutes))
                t = tHour! + (tMinutes! / 60.0)
                
            } else {
                sunRise = Double(self.convertUnixTimestampToTime(timeStamp: self.sunRise!, format: inFormat))!
                sunSet = Double(self.convertUnixTimestampToTime(timeStamp: self.sunSet!, format: inFormat))!
                t = Double(self.convertUnixTimestampToTime(timeStamp: time!, format: inFormat))!
                
            }
        }
        
        if t >= sunRise && t <= sunSet {
            
            return true
            
        } else { return false }
        
    }
    
    
    
    // Method returns the name of the weather condition image from API condition code
    func updateWeatherIcon(condition: Int, at dayTime: Bool) -> String {
        
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
            if dayTime {
                return "sunAndFog"
            } else { return "moonAndFog"}
            
        case 741 :
            return "fog"
            
        case 781, 900 :
            return "tornado"
            
        case 800, 904 :
            if dayTime {
                return "sun"
            } else { return "moon"}
            
        case 801 :
            if dayTime {
                return "sunAndSmallCloud"
            } else { return "moonAndSmallCloud"}
            
        case 802, 803 :
            if dayTime {
                return "sunAndBigCloud"
            } else { return "moonAndBigCloud"}
            
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
            return "na"
        }

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
    
    
    // Method returns time from Unix Timestamp
    func convertUnixTimestampToTime(timeStamp: Int, format: TimeFormat) -> String {
        
        let date = Date(timeIntervalSince1970: Double(timeStamp))
        
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        
        return (formatter.string(from: date))
        
    }
    
}


























