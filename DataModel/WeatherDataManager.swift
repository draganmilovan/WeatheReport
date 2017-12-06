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
import CoreData
import CoreLocation

final class WeatherDataManager: NSObject, CLLocationManagerDelegate {
    
    let coreDataStack: RTCoreDataStack

    private var locationsIDs: [Int] = []
    var locationsNames: [String] = []
    var weatherDatas: [WeatherData] = []
    private var weatherData = WeatherData()

    private let url = "http://api.openweathermap.org/data/2.5/"
    private let appID = "ac5c2be22a93a78414edcf3ebfd4885e"
    var params : [String : String] = [:]
    
    private let locationManager = CLLocationManager()

    private weak var timer: Timer?


    init(coreDataStack: RTCoreDataStack) {
        self.coreDataStack = coreDataStack
    }

}



extension WeatherDataManager {
    
    func configureLocationManager() {
        
        // Set up the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        // Start looking for coordinates
        locationManager.startUpdatingLocation()
        
    }
    
    
    //
    // Two Location Manager Delegate methods
    //
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count-1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            //Stop multiplying received data
            locationManager.delegate = nil
            
            let lat = String(location.coordinate.latitude)
            let lon = String(location.coordinate.longitude)
            print("lat = \(lat), lon = \(lon)")
            
            params = ["lat" : lat, "lon" : lon, "appid" : appID]
            
            getData(for: .currentWeather, parametars: params)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
//        locationLabel.text = "Location Unavailable"///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
//        getData(for: .forecast, parametars: parametars)
//        getData(for: .uvIndex, parametars: parametars)

    }
    
    
    //
    // Method for Data fetching
    //
    func fetchLocatios() -> [Location] {
        
        guard let moc = coreDataStack.mainContext else { fatalError("Missing Context") }
        
        let fr: NSFetchRequest<Location> = Location.fetchRequest()
        let sort = NSSortDescriptor(key: Location.Attributes.viewID, ascending: true)
        
        fr.sortDescriptors = [sort]
        
        let locations = try? moc.fetch(fr)
        
        return locations ?? []
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

            //
            // Calling UV Index data after validating weather data
            // and knowing time of day (API never return 0)
            //
            // Plus Forecast data (forecast data can return before current weather data)
            //
            getData(for: .forecast, parametars: params)
            getData(for: .uvIndex, parametars: params)

            weatherData.temperature = Int(temp - 273.15)
            weatherData.locationName = json["name"].stringValue
            weatherData.condition = json["weather"][0]["id"].intValue
            weatherData.weatherIconName = weatherData.updateWeatherIcon(condition: weatherData.condition!,
                                                                        at: weatherData.dayTime)
            weatherData.cityID = json["id"].intValue
            weatherData.tempMax = json["main"]["temp_max"].intValue
            weatherData.tempMin = json["main"]["temp_min"].intValue
            weatherData.humidity = json["main"]["humidity"].stringValue
            weatherData.pressure = json["main"]["pressure"].stringValue
            weatherData.description = json["weather"][0]["description"].stringValue.capitalized
            weatherData.windSpeed = json["wind"]["speed"].intValue
            let windDirection = json["wind"]["deg"].intValue
            weatherData.windDirection = weatherData.windDirectionCardinalPoint(degrees: windDirection)

//            updateUIWithWeatherData()
            print(weatherData.convertUnixTimestampToTime(timeStamp: weatherData.sunRise!, format: .HoursAndMinutes))
            print(weatherData.convertUnixTimestampToTime(timeStamp: weatherData.sunSet!, format: .HoursAndMinutes))
            print(weatherData.temperature)
            print(weatherData.weatherIconName)
            
            
            
            locationsNames.insert(weatherData.locationName!, at: 0)
            
            
            
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
                weatherData.uvIndex = String(Int(uvi))
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
            weatherData.forecastTimes = json["list"].map {

                weatherData.convertUnixTimestampToTime(timeStamp: ($0.1["dt"].intValue),
                                                       format: .Hours)

            }

            // Populating array with temperatures for forecast
            weatherData.forecastTemperatures = json["list"].map {

                String( Int( $0.1["main"]["temp"].doubleValue - 273.15 ))  + "°"

            }

            // Populating array with names of weather icons
            weatherData.forecastIconsNames = json["list"].map {

                weatherData.updateWeatherIcon(condition: ($0.1["weather"][0]["id"].intValue),
                                              at: weatherData.timeOfDay(for: ($0.1["dt"].intValue),
                                                                        inFormat: .Hours))

            }

        } else { locationManager.startUpdatingLocation() }

        print(weatherData.forecastTimes)
        print(weatherData.forecastTemperatures)
        print(weatherData.forecastIconsNames)
    }

}















