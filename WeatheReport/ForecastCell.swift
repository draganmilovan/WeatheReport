//
//  ForecastCell.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 12/16/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import UIKit

final class ForecastCell: UICollectionViewCell {
    
    @IBOutlet weak fileprivate var forecastTimeLabel: UILabel!
    @IBOutlet weak fileprivate var forecastWeatherIcon: UIImageView!
    @IBOutlet weak fileprivate var forecastTemperatureLabel: UILabel!
    
    
    //  Data source
    var forecastData: ForecastData? {
        didSet {
            guard let forecastData = forecastData else {
                cleanCell()
                return
            }
            
            populate(with: forecastData)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cleanCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cleanCell()
    }
    
    
    //
    // Method for cleaning cell UI
    //
    fileprivate func cleanCell() {
        
        forecastTimeLabel.text = nil
        forecastWeatherIcon.image = nil
        forecastTemperatureLabel.text = nil
        
    }
    
    
    //
    // Method for populating cell with datas
    //
    fileprivate func populate(with forecastData: ForecastData) {
        
        if let time = forecastData.time {
            forecastTimeLabel.text = time
            
        } else { forecastTimeLabel.text = "--" }
        
        if let iconName = forecastData.iconName {
            forecastWeatherIcon.image = UIImage(named: iconName)
            
        } else { forecastWeatherIcon.image = UIImage(named: "na") }
        
        if let temp = forecastData.temperature {
            forecastTemperatureLabel.text = temp
            
        } else { forecastTemperatureLabel.text = "--" }
        
    }
    
}
