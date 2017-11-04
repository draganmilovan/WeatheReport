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
    
    let weatherURL = "http://api.openweathermap.org/data/2.5/weather"
    let uvIndexURL = "http://api.openweathermap.org/data/2.5/uvi"
    let appID = "ac5c2be22a93a78414edcf3ebfd4885e"
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIconName: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    
    let locationManager = CLLocationManager()
    let weatherData = WeatherData()
    
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
    
    }
    
}

extension WeatherViewController {
    
    // Networking method
    func getWeatherData(url: String, parametars: [String : String]) {
        Alamofire.request(url, method: .get, parameters: parametars).responseJSON {
            response in
            if response.result.isSuccess {
   //             print("Weather data ready!")
                
                //Casting data in to JSON
                let json: JSON = JSON(response.result.value!)
                print(json)
                self.updateWeatherData(json: json)
                
            } else {
                print("Error \(String(describing: response.result.error))")
                self.locationLabel.text = "Connection Issues"
            }
        }
    }
    
    func getUvIndexData(url: String, parametars: [String : String]) {
        Alamofire.request(url, method: .get, parameters: parametars).responseJSON {
            response in
            if response.result.isSuccess {
                
                //Casting data in to JSON
                let json: JSON = JSON(response.result.value!)
                print(json)
                self.updateUvIndexData(json: json)
                
            } else {
                print("Error \(String(describing: response.result.error))")
               // self.uvIndexLabel.text = "-"
            }
        }
    }
    
    // JSON parsing method
    func updateWeatherData(json: JSON) {
        
        if let temp = json["main"]["temp"].double {
            weatherData.sunRise = json["sys"]["sunrise"].intValue
            weatherData.sunSet = json["sys"]["sunset"].intValue
            
            weatherData.dayTime = weatherData.updateTimeOfDay()
            
            weatherData.temperature = Int(temp - 273.15)
            weatherData.locationName = json["name"].stringValue
            weatherData.condition = json["weather"][0]["id"].intValue
            weatherData.weatherIconName = weatherData.updateWeatherIcon(condition: weatherData.condition, dayTime: weatherData.dayTime)
//            weatherData.cityID = json["id"].stringValue
//            weatherData.tempMax = json["main"]["temp_max"].intValue
//            weatherData.tempMin = json["main"]["temp_min"].intValue

            
            updateUIWithWeatherData()
            
        } else { locationLabel.text = "Weather Unavalable" }
        
    }
    
    
    // Updating UI information
    func updateUIWithWeatherData () {
        
        if weatherData.dayTime {
            
            backgroundImage.image = UIImage(named: "BackgroundDay")
            
        } else { backgroundImage.image = UIImage(named: "BackgroundNight") }
        
        if weatherData.locationName == "" {
            
            locationLabel.text = "Nameless Location"
            
        } else { locationLabel.text = weatherData.locationName }
        
        temperatureLabel.text = String(weatherData.temperature) + "°"
        
        weatherIconName.image = UIImage(named: weatherData.weatherIconName)
        
// Need to create storyboard for other data
        print(weatherData.convertUnixTimestampToTime(timeStamp: weatherData.sunRise!))
        print(weatherData.convertUnixTimestampToTime(timeStamp: weatherData.sunSet!))

    }
    
    // Method for processing UV Index data
    func updateUvIndexData(json:JSON) {
        
        if let uvi = json["value"].double {
            weatherData.uvIndex = String(uvi)
            //uvIndexLabel.text = weatherData.uvIndex
            print(weatherData.uvIndex!)
            
        } else { weatherData.uvIndex = "N/A" }
    }
    
    
    // Location Manager Delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count-1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            //Stop multiplying received data
            locationManager.delegate = nil
            
            let lat = String(location.coordinate.latitude)
            let lon = String(location.coordinate.longitude)
            print("lat = \(lat), lon = \(lon)")
            
            let params : [String : String] = ["lat" : lat, "lon" : lon, "appid" : appID]
            
            getWeatherData(url: weatherURL, parametars: params)
            getUvIndexData(url: uvIndexURL, parametars: params)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        locationLabel.text = "Location Unavailable"
    }

}



























