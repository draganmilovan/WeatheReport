//
//  WeatherDataManager.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 11/15/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import Foundation

class WeatherDataManager {
    
    var locationsIDs: [Int] = []
    var locations: [String] = []
    var weatherDatas: [WeatherData] = []
    
    let weatherURL = "http://api.openweathermap.org/data/2.5/weather"
    let uvIndexURL = "http://api.openweathermap.org/data/2.5/uvi"
    let forecastURL = "http://api.openweathermap.org/data/2.5/forecast"
    let appID = "ac5c2be22a93a78414edcf3ebfd4885e"
    var paramsUVI : [String : String] = [:]
    
    weak var timer: Timer?
    
}





















