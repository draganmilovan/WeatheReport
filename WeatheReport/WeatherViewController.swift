//
//  ViewController.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 10/19/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
//    let weatherURL = "http://api.openweathermap.org/data/2.5/weather"
//    let uvIndexURL = "http://api.openweathermap.org/data/2.5/uvi"
//    let forecastURL = "http://api.openweathermap.org/data/2.5/forecast"
    let appID = "ac5c2be22a93a78414edcf3ebfd4885e"
    var params : [String : String] = [:]
    
    let url = "http://api.openweathermap.org/data/2.5/"
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIconName: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var uvIndexLabel: UILabel!
    @IBOutlet weak var uviTextLabel: UILabel!
    
    
    let locationManager = CLLocationManager()
    let wData = WData()
    
    weak var timer: Timer?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        // Start looking for coordinates
        locationManager.startUpdatingLocation()
        
        // Start timer for auto refreshing data every minute
        startTimer()
        
//        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
//
    }
    
}

extension WeatherViewController {
    
    
    
    enum TypeOfData: String {
        case currentWeather = "weather"
        case forecast
        case uvIndex = "uvi"
    }
    
//    @objc func refresh(refreshControl: UIRefreshControl) {
//        print("Refreshing...")
//        locationManager.startUpdatingLocation()
//        refreshControl.endRefreshing()
//    }
    
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
                self.locationLabel.text = "Connection Issues"
            }
        }
    }
//
//    // Networking method
//    func getWeatherData(url: String, parametars: [String : String]) {
//        Alamofire.request(url, method: .get, parameters: parametars).responseJSON {
//            response in
//            if response.result.isSuccess {
//   //             print("Weather data ready!")
//
//                //Casting data in to JSON
//                let json: JSON = JSON(response.result.value!)
//               // print(json)
//                self.updateWeatherData(json: json)
//
//            } else {
//                print("Error \(String(describing: response.result.error))")
//                self.locationLabel.text = "Connection Issues"
//            }
//        }
//    }
//
//    func getUvIndexData(url: String, parametars: [String : String]) {
//        Alamofire.request(url, method: .get, parameters: parametars).responseJSON {
//            response in
//            if response.result.isSuccess {
//
//                //Casting data in to JSON
//                let json: JSON = JSON(response.result.value!)
//               // print(json)
//                self.updateUvIndexData(json: json)
//
//            } else {
//                print("Error \(String(describing: response.result.error))")
//                self.uvIndexLabel.text = "-"
//            }
//        }
//    }
//
//    func getForecastData(url: String, parametars: [String : String]) {
//        Alamofire.request(url, method: .get, parameters: parametars).responseJSON {
//            response in
//            if response.result.isSuccess {
//
//                //Casting data in to JSON
//                let json: JSON = JSON(response.result.value!)
//                //print(json)
//                self.updateForecastData(json: json)
//
//            } else {
//                print("Error \(String(describing: response.result.error))")
//
//            }
//        }
//    }
//
    
    // JSON parsing method
    func updateWeatherData(json: JSON) {
        
        if let sunRise = json["sys"]["sunrise"].int,
            let sunSet = json["sys"]["sunset"].int {
            
            wData.sunRise = sunRise
            wData.sunSet = sunSet
            
            wData.dayTime = wData.updateTimeOfDay()
            
        } else { wData.dayTime = true }
        
        if let temp = json["main"]["temp"].double {
            
            // Calling UV Index data after validating weather data,
            // and knowing time of day (API never return 0!
//            getUvIndexData(url: uvIndexURL, parametars: params)
            getData(for: .uvIndex, parametars: params)
            
            wData.temperature = Int(temp - 273.15)
            wData.locationName = json["name"].stringValue
            wData.condition = json["weather"][0]["id"].intValue
            wData.weatherIconName = wData.updateWeatherIcon(condition: wData.condition, at: wData.dayTime)
            wData.cityID = json["id"].stringValue
            wData.tempMax = json["main"]["temp_max"].intValue
            wData.tempMin = json["main"]["temp_min"].intValue
            wData.humidity = json["main"]["humidity"].intValue
            wData.pressure = json["main"]["pressure"].intValue
            wData.description = json["weather"][0]["description"].stringValue.capitalized
            wData.windSpeed = json["wind"]["speed"].stringValue
            let windDirection = json["wind"]["deg"].intValue
            wData.windDirection = wData.windDirectionCardinalPoint(degrees: windDirection)
            
            updateUIWithWeatherData()
            
        } else {
            // Updating UI information i case of unvalidated weather data
            locationLabel.text = "Weather Unavalable"
            weatherIconName.image = nil
            temperatureLabel.text = nil
            uvIndexLabel.text = nil
        }
        
    }
    
    
    // Updating UI information
    func updateUIWithWeatherData () {
        
        if wData.dayTime {
            
            backgroundImage.image = UIImage(named: "BackgroundDay")
            
        } else { backgroundImage.image = UIImage(named: "BackgroundNight") }
        
        if wData.locationName == "" {
            
            locationLabel.text = "Nameless Location"
            
        } else { locationLabel.text = wData.locationName }
        
        temperatureLabel.text = String(wData.temperature) + "°"
        
        weatherIconName.image = UIImage(named: wData.weatherIconName)
        
// Need to create storyboard for other data
        print(wData.convertUnixTimestampToTime(timeStamp: wData.sunRise!, format: .HoursAndMinutes))
        print(wData.convertUnixTimestampToTime(timeStamp: wData.sunSet!, format: .HoursAndMinutes))
        print(wData.windSpeed)
        print(wData.windDirection)
        print(wData.description)
        
        
        print("Updated UI!")

    }
    
    
    // Method for processing UV Index data
    func updateUvIndexData(json: JSON) {
        
        if let uvi = json["value"].double {
            if locationLabel.text != "Weather Unavalable" {
                wData.uvIndex = String(uvi)
                uvIndexLabel.text = wData.uvIndex
                print(wData.uvIndex!)
            }
            
            if wData.dayTime == false {
                uvIndexLabel.text = "0"
            }
            
        } else {
            wData.uvIndex = "N/A"
            uvIndexLabel.text = wData.uvIndex
        }
    }
    
    
    // Method for parsing forecast data
    func updateForecastData(json: JSON) {
        
        if let _ = json["list"][0]["dt"].int {

            // Populating array with times for forecast
            wData.times = json["list"].map {
                
                wData.convertUnixTimestampToTime(timeStamp: ($0.1["dt"].intValue),
                                                       format: .Hours)
                
            }
            
            // Populating array with temperatures for forecast
            wData.temperatures = json["list"].map {
                
                String( Int( $0.1["main"]["temp"].doubleValue - 273.15 ))  + "°"
                
            }
            
            // Populating array with names of weather icons
            wData.weatherIconsNames = json["list"].map {
                
                wData.updateWeatherIcon(condition: ($0.1["weather"][0]["id"].intValue),
                                              at: wData.timeOfDay(for: ($0.1["dt"].intValue),
                                                                        inFormat: .Hours))
                
            }
            
            print(wData.times)
            print(wData.temperatures)
            print(wData.weatherIconsNames)
            
        } else { locationManager.startUpdatingLocation() }
        
    }
    
    
    // Method for auto refreshing data every minute
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in

            self!.locationManager.startUpdatingLocation()
            print("timer started")
        }
    }
    
    
    // Location Manager Delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count-1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            //Stop multiplying received data
            //locationManager.delegate = nil
            
            let lat = String(location.coordinate.latitude)
            let lon = String(location.coordinate.longitude)
            print("lat = \(lat), lon = \(lon)")
            
            params = ["lat" : lat, "lon" : lon, "appid" : appID]
            
            getData(for: .currentWeather, parametars: params)
            getData(for: .forecast, parametars: params)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        locationLabel.text = "Location Unavailable"
    }

}



























