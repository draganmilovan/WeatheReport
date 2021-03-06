//
//  WeatherDataModel.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 11/18/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import Foundation
import CoreLocation
import LatLongToTimezone

final class WeatherData {
    
    var coordinate: CLLocationCoordinate2D?
    var cityID: Int?
    
    var locationName: String?
    var dayTime: Bool = true
    var sunRise: String?
    var sunSet: String?
    var time: String?

    var temperature: Int?
    var condition: Int?
    var weatherIconName: String?
    var windDirection: String?
    var windSpeed: Int?
    var humidity: String?
    var pressure: String?
    var description: String?
    var latitude: Double?
    var longitude: Double?
    
    var uvIndex: String?
    
    var forecastDatas: [ForecastData] = []
    
    var selected: Bool = false
    
}



extension WeatherData {
 
    enum TimeFormat: String {
        case Hours = "HH"
        case HoursAndMinutes = "HH:mm"
        case Day = "EEE"
    }
    
    enum Time {
        case now
        case time
    }
    
    
    //
    // Method returns day from timestamp
    //
    func whatDayIs(this timestamp: Int) -> String {
        
        return convertUnixTimestampToTime(timeStamp: timestamp, format: .Day)
    }
    
    
    //
    // Method returns true if is daytime for certain time
    //
    func timeOfDay(for moment: Time, time: Int?, inFormat: TimeFormat) -> Bool {
        
        var t: String!
        
        switch moment {
        case .now:
            let date = Int(Date().timeIntervalSince1970)
            t = convertUnixTimestampToTime(timeStamp: date, format: inFormat)
            
        case .time:
            t = convertUnixTimestampToTime(timeStamp: time!, format: inFormat)
        }
        
        
        if t >= sunRise! && t <= sunSet! {
            return true
            
        } else { return false }
        
    }
    
    
    //
    // Method returns the name of the weather condition image from API condition code
    //
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
    
    
    //
    // Method returns the cardinal point from the wind direction in degrees
    //
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
    
    
    //
    // Method returns time from Unix Timestamp
    //
    func convertUnixTimestampToTime(timeStamp: Int, format: TimeFormat) -> String {
        
        let date = Date(timeIntervalSince1970: Double(timeStamp))
        let timeZone = TimezoneMapper.latLngToTimezone(coordinate!)

        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.timeZone = timeZone
        
        return (formatter.string(from: date))
        
    }
    
}
