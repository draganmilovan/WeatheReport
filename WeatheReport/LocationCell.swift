//
//  LocationCell.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 12/18/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet private weak var backgroundImage: UIImageView!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var weatherIconImage: UIImageView!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundImage.image = nil
        temperatureLabel.text = nil
        weatherIconImage.image = nil
        locationLabel.text = nil
        timeLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func displayMessage(for weatherData: WeatherData) {
        temperatureLabel.text = nil
        weatherIconImage.image = nil
        locationLabel.text = weatherData.locationName
        timeLabel.text = nil
        backgroundImage.image = UIImage(named: "BackgroundDay")
    }
    
    
    func configure(with weatherData: WeatherData) {
        
        if weatherData.locationName == "Connection Issues" ||
            weatherData.locationName == "Weather Unavalable" {
            
            displayMessage(for: weatherData)
        } else {
            
            if weatherData.dayTime {
                backgroundImage.image = UIImage(named: "BackgroundDay")
            } else {
                backgroundImage.image = UIImage(named: "BackgroundNight")
            }
            
            
            if let temp = weatherData.temperature {
                temperatureLabel.text = "\(temp)°C"
            } else {
                temperatureLabel.text = " "
                backgroundImage.image = UIImage(named: "BackgroundDay")
            }
            
            
            if let wthrIcon = weatherData.weatherIconName {
                weatherIconImage.image = UIImage(named: wthrIcon)
            } else {
                weatherIconImage.image = UIImage(named: "na")
            }
            
            
            if let loc = weatherData.locationName {
                locationLabel.text = loc
            } else {
                locationLabel.text = " "
                backgroundImage.image = UIImage(named: "BackgroundDay")
            }
            
            
            if let t = weatherData.time {
                timeLabel.text = t
            } else {
                timeLabel.text = " "
                backgroundImage.image = UIImage(named: "BackgroundDay")
            }
        }
    }

}
