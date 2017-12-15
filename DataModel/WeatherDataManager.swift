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

    var weatherDatas: [WeatherData] = []

    private let url = "http://api.openweathermap.org/data/2.5/"
    private let appID = "ac5c2be22a93a78414edcf3ebfd4885e"
    
    private let coreDataStack: RTCoreDataStack
    private let locationManager = CLLocationManager()

    private weak var timer: Timer?


    init(coreDataStack: RTCoreDataStack) {
        self.coreDataStack = coreDataStack
        super.init()
        
        fetchLocatios()
        configureLocationManager()
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
            
            if let wd = weatherDatas.first {
                wd.coordinate = location.coordinate
                update(weatherData: wd)
            }
            
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
    // Method for Data fetching
    //
    func fetchLocatios() {
        
        guard let moc = coreDataStack.mainContext else { fatalError("Missing Context") }
        
        let fr: NSFetchRequest<Location> = Location.fetchRequest()
        let sort = NSSortDescriptor(key: Location.Attributes.viewID, ascending: true)
        
        fr.sortDescriptors = [sort]
        
        let locations = try? moc.fetch(fr)
    
        for location in locations! {
            let wd = WeatherData()
            wd.cityID = Int(location.locationID)
            
            weatherDatas.append(wd)
            
        }
        
        weatherDatas.insert(WeatherData(), at: 0)
        
    }

}


extension WeatherDataManager {
    
    func updateAll() {
        for wd in weatherDatas {
            update(weatherData: wd)
        }
        
    }
    
    //
    // Method for updating weather data
    //
    func update(weatherData: WeatherData) { // , completion: @escaping () -> Void = {}
        let params = createParams(weatherData: weatherData)
        getData(weatherData: weatherData, for: .currentWeather, parametars: params)
    }
    
}


private extension WeatherDataManager {
    
    //
    // Method for creating params for networking
    //
    func createParams(weatherData: WeatherData) -> [String : String] {
        
        var params: [String : String] = [:]
        
        if let coordinate = weatherData.coordinate {
            let lat = String(coordinate.latitude)
            let lon = String(coordinate.longitude)
            
            params = ["lat" : lat, "lon" : lon, "appid" : appID]
            
        } else if let cityID = weatherData.cityID {
            params = ["id" : String(cityID), "appid" : appID]
            
        }
        
        return params
    }

    
    //
    // Networking method
    //
    func getData(weatherData: WeatherData, for data: TypeOfData, parametars: [String : String]) {

        let urlString = url + data.rawValue

        Alamofire.request(urlString, method: .get, parameters: parametars).responseJSON {
            [weak weatherData] response in
            guard let weatherData = weatherData else { return }
            
            if response.result.isSuccess {

                //Casting data in to JSON
                let json: JSON = JSON(response.result.value!)
                // print(json)

                switch (data) {

                case .currentWeather:
                    self.updateWeatherData(weatherData: weatherData, json: json)

                case .uvIndex:
                    self.updateUvIndexData(weatherData: weatherData, json: json)

                case .forecast:
                    self.updateForecastData(weatherData: weatherData, json: json)

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
    func updateWeatherData(weatherData: WeatherData, json: JSON) {

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
            let params = createParams(weatherData: weatherData)
            
            getData(weatherData: weatherData, for: .forecast, parametars: params)
            getData(weatherData: weatherData, for: .uvIndex, parametars: params)

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
 
            postNotification()
          
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
    func updateUvIndexData(weatherData: WeatherData, json: JSON) {

        if let uvi = json["value"].double {
//            if locationLabel.text != "Weather Unavalable" {
                weatherData.uvIndex = String(Int(uvi))
//                uvIndexLabel.text = weatherData.uvIndex
//            }

            if weatherData.dayTime == false {
                weatherData.uvIndex = "0"
            }

        } else {
            weatherData.uvIndex = "N/A"
//            uvIndexLabel.text = weatherData.uvIndex
        }
        
        postNotification()
        print("UVI = \(weatherData.uvIndex!)")
    }


    //
    // Method for parsing forecast data
    //
    func updateForecastData(weatherData: WeatherData, json: JSON) {

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
            
            postNotification()

        } else {
            
//            locationManager.startUpdatingLocation()
            
        }

        print(weatherData.forecastTimes)
        print(weatherData.forecastTemperatures)
        print(weatherData.forecastIconsNames)
    }

}


private extension WeatherDataManager {
    
    func postNotification() {
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"),
                                        object: nil)
    }
    
    //
    // Method for auto refreshing data every minute
    //
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) {
            [weak self] _ in
            
            self?.configureLocationManager()
            print("timer started")
        }
    }
}












