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
    private var locations: [Location] = []

    private let url = "http://api.openweathermap.org/data/2.5/"
    private let appID = "ac5c2be22a93a78414edcf3ebfd4885e"
    
    private let coreDataStack: RTCoreDataStack
    private let locationManager = CLLocationManager()

    private weak var timer: Timer?
    private var mocMain: NSManagedObjectContext? {
        return coreDataStack.mainContext
    }
    

    init(coreDataStack: RTCoreDataStack) {
        self.coreDataStack = coreDataStack
        super.init()
        
        fetchLocatios()
        configureLocationManager()
        startTimer()
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
                
                updateAll()
            }
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
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
    private func fetchLocatios() {
        
        guard let moc = mocMain else { fatalError("Missing Context") }
        
        let fr: NSFetchRequest<Location> = Location.fetchRequest()
        let sort = NSSortDescriptor(key: Location.Attributes.displayOrderNumber, ascending: true)
        
        fr.sortDescriptors = [sort]
        
        let locs = try? moc.fetch(fr)
    
        for loc in locs! {
            locations.append(loc)
            
            let wd = WeatherData()
            
            wd.cityID = Int(loc.locationID)
            
            guard let lat = loc.latitude else { return }
            guard let lon = loc.longitude else { return }
            wd.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(truncating: lat),
                                                   longitude: CLLocationDegrees(truncating: lon))
            
            weatherDatas.append(wd)
            
        }
        
        weatherDatas.insert(WeatherData(), at: 0)
    }
    
    
    //
    // Method for adding new location to list for weather datas and saving to Core Data
    //
    func addNewLocation(location: City) {
        guard let moc = mocMain else { fatalError("Missing Context") }
        guard let mo = Location(managedObjectContext: moc) else { return }
        
        let n = location.name
        let predicate = NSPredicate(format: "SELF matches %@", n)

        let l = locations.filter {
                predicate.evaluate(with: $0.name)
        }

        if l.count == 0 {
            mo.selected = true

            mo.displayOrderNumber = Int64(self.weatherDatas.count)

            mo.name = location.name

            if let id = location.id {
                mo.locationID = Int64(id)
            }

            if let lat = location.coordinate?.latitude {
                mo.latitude = lat as NSNumber
            }

            if let lon = location.coordinate?.longitude {
                mo.longitude = lon as NSNumber
            }

            let wd = WeatherData()

            wd.locationName = location.name

            if let id = location.id {
                wd.cityID = id
            }

            if let crd = location.coordinate {
                wd.coordinate = crd
            }


            do {
                try moc.save()
                locations.append(mo)

            } catch {
                moc.delete(mo)
                print("Error saving context \(error)")
            }
            weatherDatas.append(wd)
            update(weatherData: wd)

        } else {
            moc.delete(mo)
            return
        }
        
    }
    
    
    //
    // Method for deleting location
    //
    func deleteLocation(at indexPath: IndexPath) {
        guard let moc = mocMain else { fatalError("Missing Context") }
        let location = locations[indexPath.row - 1]
        
        moc.delete(location)
        
        do {
            try moc.save()
            
        } catch {
            print("Error deleting context \(error)")
        }
        
        locations.remove(at: indexPath.row - 1)
        weatherDatas.remove(at: indexPath.row)
    }

}



fileprivate extension WeatherDataManager {
    
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
    func update(weatherData: WeatherData) {
        let params = createParams(weatherData: weatherData)
        getData(weatherData: weatherData, for: .currentWeather, parametars: params)
    }
    
}


fileprivate extension WeatherDataManager {
    
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



fileprivate extension WeatherDataManager {
    
    //
    // JSON parsing method for current weather data
    //
    func updateWeatherData(weatherData: WeatherData, json: JSON) {

        if let sunRise = json["sys"]["sunrise"].int,
            let sunSet = json["sys"]["sunset"].int {

            weatherData.sunRise = weatherData.convertUnixTimestampToTime(timeStamp: sunRise, format: .HoursAndMinutes)
            weatherData.sunSet = weatherData.convertUnixTimestampToTime(timeStamp: sunSet, format: .HoursAndMinutes)
            
            weatherData.dayTime = weatherData.timeOfDay(for: .now, time: nil, inFormat: .HoursAndMinutes)

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
        
        
        if let desc = json["weather"][0]["description"].string {
            weatherData.description = desc
        }
        
        
        if let wnd = json["wind"]["speed"].double {
            weatherData.windSpeed = Int(wnd)
        }
        
        
        if let windDirection = json["wind"]["deg"].int {
            weatherData.windDirection = weatherData.windDirectionCardinalPoint(degrees: windDirection)
        }
        
        
        if let lat = weatherData.coordinate?.latitude {
            weatherData.latitude = lat
        } else {
            if let lat = json["coord"]["lat"].double {
                weatherData.latitude = lat
            }
        }
        
        
        if let lon = weatherData.coordinate?.longitude {
            weatherData.longitude = lon
        } else {
            if let lon = json["coord"]["lon"].double {
                weatherData.longitude = lon
            }
        }
        
        
        let t = Int(Date().timeIntervalSince1970)
        weatherData.time = weatherData.convertUnixTimestampToTime(timeStamp: t, format: .HoursAndMinutes)
        
        
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
            weatherData.uvIndex = String(Int(uvi))
            
            if weatherData.dayTime == false {
                weatherData.uvIndex = "0"
            }
            
        } else {
            weatherData.uvIndex = "N/A"
        }
        
        postNotification()
        print("UVI = \(weatherData.uvIndex!)")
    }


    //
    // Method for parsing forecast data
    //
    func updateForecastData(weatherData: WeatherData, json: JSON) {

        if let _ = json["list"][0]["dt"].int {
            
            var forecastDatas: [ForecastData] = []
            
            forecastDatas = json["list"].map {
                
                // Populating forecastDatas array
                ForecastData(day: weatherData.whatDayIs(this: $0.1["dt"].intValue), time: weatherData.convertUnixTimestampToTime(timeStamp: ($0.1["dt"].intValue),
                                                                                                                                 format: .Hours),
                             
                             iconName: weatherData.updateWeatherIcon(condition: ($0.1["weather"][0]["id"].intValue),
                                                                     at: weatherData.timeOfDay(for: .time, time: ($0.1["dt"].intValue), inFormat: .Hours)),
                             
                             temperature: (String( Int( $0.1["main"]["temp"].doubleValue - 273.15 ))  + "°"))
            }
            
            let _ = forecastDatas.map {
                if let day = $0.day {
                    let dayData = ForecastData(day: day, time: nil, iconName: nil, temperature: nil)
                    if !weatherData.forecastDatas.contains(dayData) {
                        weatherData.forecastDatas.append(contentsOf: [dayData, $0])
                    } else {
                        weatherData.forecastDatas.append($0)
                    }
                }
            }
            
            weatherData.forecastDatas.removeFirst()
            
            postNotification()
            
        } else { return }
        
    }

}


fileprivate extension WeatherDataManager {
    
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
