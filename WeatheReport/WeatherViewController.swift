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
    let appID = "ac5c2be22a93a78414edcf3ebfd4885e"
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
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
                //print("Weather data ready!")
                
                //Casting data in to JSON
                let weatherJSON: JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
                
            } else {
                print("Error \(String(describing: response.result.error))")
                self.locationLabel.text = "Connection Issues!"
            }
        }
    }
    
    //JSON parsing method
    func updateWeatherData(json: JSON) {
        
        let temp = json["main"]["temp"]
        print(temp)
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
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        locationLabel.text = "Location Unavailable!"
    }

}



























