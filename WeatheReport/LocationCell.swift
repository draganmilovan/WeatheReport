//
//  LocationCell.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 12/18/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundImage.image = nil
        temperatureLabel.text = nil
        locationLabel.text = nil
        timeLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with weatherData: WeatherData) {
        if weatherData.dayTime {
            backgroundImage.image = UIImage(named: "BackgroundDay")
        } else {
            backgroundImage.image = UIImage(named: "BackgroundNight")
        }
        
        temperatureLabel.text = "\(weatherData.temperature!)°"
        locationLabel.text = weatherData.locationName!
        timeLabel.text = weatherData.time!
    }

}
