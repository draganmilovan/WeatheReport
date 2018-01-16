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
    var locationsManager = LocationsManager()

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
        startTimer()
        configureLocationsManager()
    }

}



extension WeatherDataManager {
    
    //
    // Method for initiating GPS
    //
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
                //update(weatherData: wd)
                updateAll()
            }
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        //configureLocationManager()
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
///////////////////////////////////////////////////////////////////
//                     FOR TESTING!                              //
///////////////////////////////////////////////////////////////////
        weatherDatas.insert(WeatherData(), at: 1)
        weatherDatas.last?.cityID = 3467431
        weatherDatas.insert(WeatherData(), at: 2)
        weatherDatas.last?.cityID = 1283240
        weatherDatas.insert(WeatherData(), at: 3)
        weatherDatas.last?.cityID = 4161624
        weatherDatas.insert(WeatherData(), at: 4)
        weatherDatas.last?.cityID = 2160931
    }

}


extension WeatherDataManager {
    
    //
    // Method for creating list of available locations with weather datas
    //
    func configureLocationsManager() {
        locationsManager.populateLocationlist()
    }
    
}


extension WeatherDataManager {
    
    //
    // Method for updating datas for all locations
    //
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
            
        }
        
        if let lat = weatherData.latitude, let lon = weatherData.longitude {
            params = ["lat" : "\(lat)", "lon" : "\(lon)", "appid" : appID]
            
        }
        
        if let cityID = weatherData.cityID {
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

                switch (data) {

                case .currentWeather:
                    self.updateWeatherData(weatherData: weatherData, json: json)
                    //print(json)

                case .uvIndex:
                    self.updateUvIndexData(weatherData: weatherData, json: json)

                case .forecast:
                    self.updateForecastData(weatherData: weatherData, json: json)

                }

            } else {
                print("Error \(String(describing: response.result.error))")
                
                switch (data) {
                    
                case .currentWeather:
                    weatherData.locationName = "Connection Issues"
                    //self.getData(weatherData: weatherData, for: .currentWeather, parametars: parametars)
                    
                case .uvIndex :
                    weatherData.uvIndex = "N/A"
                    
                default :
                    return
                }
                
                self.postNotification()
                
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
            weatherData.temperature = Int(temp - 273.15)
        } else {
            weatherData.locationName = "Weather Unavalable"
            postNotification()
            return
        }
        
        
        if let loc = json["name"].string {
            weatherData.locationName = loc
        } else {
            weatherData.locationName = "Weather Unavalable"
            postNotification()
            return
        }
        
        
        if let con = json["weather"][0]["id"].int {
            weatherData.weatherIconName = weatherData.updateWeatherIcon(condition: con,
                                                                        at: weatherData.dayTime)
        } else {
            weatherData.locationName = "Weather Unavalable"
            postNotification()
            return
        }
        
        
        if let hum =  json["main"]["humidity"].int {
            weatherData.humidity = "\(hum)"
        }
        
        
        if let pres = json["main"]["pressure"].int {
            weatherData.pressure = "\(pres)"
        }
        
        
        if let desc = json["weather"][0]["description"].string?.capitalized {
            weatherData.description = desc
        }
        
        
        if let wnd = json["wind"]["speed"].double {
            weatherData.windSpeed = Int(wnd)
        }
        
        
        if let windDirection = json["wind"]["deg"].int {
            weatherData.windDirection = weatherData.windDirectionCardinalPoint(degrees: windDirection)
        }
        
        
        if let lat = json["coord"]["lat"].double {
            weatherData.latitude = lat
        }
        
        
        if let lon = json["coord"]["lon"].double {
            weatherData.longitude = lon
        }
        
        
        if let t = json["dt"].int {
            weatherData.time = weatherData.convertUnixTimestampToTime(timeStamp: t, format: .HoursAndMinutes)
        }
        
        
        // Erasing cityID for calling UV Index Data
        // API handling only latitude and longitude as params
        if let _ = weatherData.longitude, let _ = weatherData.latitude {
            weatherData.cityID = nil
        }
        
        
        postNotification()
        
        
        //
        // Calling UV Index data after validating weather data
        // and knowing time of day (API never return 0)
        //
        // Plus Forecast data (forecast data can return before current weather data)
        //
        let params = createParams(weatherData: weatherData)
        
        getData(weatherData: weatherData, for: .forecast, parametars: params)
        getData(weatherData: weatherData, for: .uvIndex, parametars: params)
        
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
            
            weatherData.forecastDatas = json["list"].map {
                
                // Populating forecastDatas array
                ForecastData(time: weatherData.convertUnixTimestampToTime(timeStamp: ($0.1["dt"].intValue),
                                                                          format: .Hours),
                             
                             iconName: weatherData.updateWeatherIcon(condition: ($0.1["weather"][0]["id"].intValue),
                                                                     at: weatherData.timeOfDay(for: ($0.1["dt"].intValue),
                                                                                               inFormat: .Hours)),
                             
                             temperature: (String( Int( $0.1["main"]["temp"].doubleValue - 273.15 ))  + "°"))
            }

//            // Populating array with times for forecast
//            weatherData.forecastTimes = json["list"].map {
//
//                weatherData.convertUnixTimestampToTime(timeStamp: ($0.1["dt"].intValue),
//                                                       format: .Hours)
//
//            }
//
//            // Populating array with temperatures for forecast
//            weatherData.forecastTemperatures = json["list"].map {
//
//                String( Int( $0.1["main"]["temp"].doubleValue - 273.15 ))  + "°"
//
//            }
//
//            // Populating array with names of weather icons
//            weatherData.forecastIconsNames = json["list"].map {
//
//                weatherData.updateWeatherIcon(condition: ($0.1["weather"][0]["id"].intValue),
//                                              at: weatherData.timeOfDay(for: ($0.1["dt"].intValue),
//                                                                        inFormat: .Hours))
//
//            }
            
            postNotification()

        } else {
            
//            locationManager.startUpdatingLocation()
            
        }

        print(weatherData.forecastDatas.count)
//        print(weatherData.forecastTimes)
//        print(weatherData.forecastTemperatures)
//        print(weatherData.forecastIconsNames)
    }

}


private extension WeatherDataManager {
    
    //
    // Method for posting Notification after updating datas
    //
    func postNotification() {
        NotificationCenter.default.post(name: Notification.Name("DataUpdated"),
                                        object: nil)
    }
    
    //
    // Method for auto refreshing data every minute
    //
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) {
            [weak self] _ in
            
            for wd in (self?.weatherDatas)! {
                if (wd.coordinate != nil) {
                    self?.configureLocationManager()
                    
                } else {
                    self?.update(weatherData: wd)
                }
            }
            print("timer started")
        }
    }
    
    
}












