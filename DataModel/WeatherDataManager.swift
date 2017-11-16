//
//  WeatherDataManager.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 11/15/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RTCoreDataStack

class WeatherDataManager {
    
    let coreDataStack: RTCoreDataStack
    
    private var locationsIDs: [Int] = []
    var locationsNames: [String] = []
    var weatherDatas: [WeatherData] = []
    private var weatherData = WeatherData()
    
    private let url = "http://api.openweathermap.org/data/2.5/"
    private let appID = "ac5c2be22a93a78414edcf3ebfd4885e"
    var params : [String : String] = [:]
    
    private weak var timer: Timer?
    
    
    init(coreDataStack: RTCoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
}



extension WeatherDataManager {
    
    enum TypeOfData: String {
        case currentWeather = "weather"
        case forecast
        case uvIndex = "uvi"
    }
    
    
    //
    // Method for calling all weather data
    //
    func createWeatherData(parametars: [String : String]) {
        
        getData(for: .currentWeather, parametars: parametars)
        getData(for: .forecast, parametars: parametars)
        getData(for: .uvIndex, parametars: parametars)
        
    }
    
}



private extension WeatherDataManager {
    
    //
    // Networking method
    //
    func getData(for data: TypeOfData, parametars: [String : String]) {
        
        let urlString = url + data.rawValue
        
        Alamofire.request(urlString, method: .get, parameters: parametars).responseJSON {
            response in
            if response.result.isSuccess {
                
                //Casting data in to JSON
                let json: JSON = JSON(response.result.value!)
                // print(json)
                
                switch (data) {
                    
                case .currentWeather:
                    self.updateWeatherData(json: json)
                    
                case .uvIndex:
                    self.updateUvIndexData(json: json)
                    
                case .forecast:
                    self.updateForecastData(json: json)

                }
                
            } else {
                print("Error \(String(describing: response.result.error))")
                //                self.locationLabel.text = "Connection Issues"
            }
        }
    }

}



private extension WeatherDataManager {
    
    //
    // JSON parsing method for current weather data
    //
    func updateWeatherData(json: JSON) {
        
        if let sunRise = json["sys"]["sunrise"].int,
            let sunSet = json["sys"]["sunset"].int {
            
            weatherData.sunRise = sunRise
            weatherData.sunSet = sunSet
            
            //            let date = Int(Date().timeIntervalSince1970)
            //            weatherData.dayTime = weatherData.timeOfDay(for: date, inFormat: "HH:mm")
            
            weatherData.dayTime = weatherData.updateTimeOfDay()
            
        } else { weatherData.dayTime = true }
        
        if let temp = json["main"]["temp"].double {
            
// Calling UV Index data after validating weather data
// and knowing time of day (API never return 0!
            
            weatherData.temperature = Int(temp - 273.15)
            weatherData.locationName = json["name"].stringValue
            weatherData.condition = json["weather"][0]["id"].intValue
            weatherData.weatherIconName = weatherData.updateWeatherIcon(condition: weatherData.condition, at: weatherData.dayTime)
            weatherData.cityID = json["id"].stringValue
            weatherData.tempMax = json["main"]["temp_max"].intValue
            weatherData.tempMin = json["main"]["temp_min"].intValue
            weatherData.humidity = json["main"]["humidity"].intValue
            weatherData.pressure = json["main"]["pressure"].intValue
            weatherData.description = json["weather"][0]["description"].stringValue.capitalized
            weatherData.windSpeed = json["wind"]["speed"].stringValue
            let windDirection = json["wind"]["deg"].intValue
            weatherData.windDirection = weatherData.windDirectionCardinalPoint(degrees: windDirection)
            
//            updateUIWithWeatherData()
            
        } else {
            // Updating UI information i case of unvalidated weather data
//            locationLabel.text = "Weather Unavalable"
//            weatherIconName.image = nil
//            temperatureLabel.text = nil
//            uvIndexLabel.text = nil
        }
        
    }
    

    
    //
    // Method for processing UV Index data
    //
    func updateUvIndexData(json: JSON) {
        
        if let uvi = json["value"].double {
//            if locationLabel.text != "Weather Unavalable" {
                weatherData.uvIndex = String(uvi)
//                uvIndexLabel.text = weatherData.uvIndex
//            }
//
//            if weatherData.dayTime == false {
//                uvIndexLabel.text = "0"
//            }
            
        } else {
            weatherData.uvIndex = "N/A"
//            uvIndexLabel.text = weatherData.uvIndex
        }
    }
    
    
    //
    // Method for parsing forecast data
    //
    func updateForecastData(json: JSON) {
        
        if let _ = json["list"][0]["dt"].int {
            
            // Populating array with times for forecast
            weatherData.times = json["list"].map {
                
                weatherData.convertUnixTimestampToTime(timeStamp: ($0.1["dt"].intValue),
                                                       format: "HH")
                
            }
            
            // Populating array with temperatures for forecast
            weatherData.temperatures = json["list"].map {
                
                String( Int( $0.1["main"]["temp"].doubleValue - 273.15 ))  + "°"
                
            }
            
            // Populating array with names of weather icons
            weatherData.weatherIconsNames = json["list"].map {
                
                weatherData.updateWeatherIcon(condition: ($0.1["weather"][0]["id"].intValue),
                                              at: weatherData.timeOfDay(for: ($0.1["dt"].intValue),
                                                                        inFormat: "HH"))
                
            }
            
        }// else { locationManager.startUpdatingLocation() }
        
    }

}















