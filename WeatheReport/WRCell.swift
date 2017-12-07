//
//  WRCell.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 11/28/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import UIKit

class WRCell: UICollectionViewCell {
    
    @IBOutlet var textOnlyLabels: [UILabel]!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var uvIndexLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    @IBOutlet weak var forecastCollectionVew: UICollectionView!
    
  
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cleanCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cleanCell()
    }
    
    
    // Method for cleaning datas form UI
    fileprivate func cleanCell() {
        
        locationLabel.text = nil
        weatherIcon.image = nil
        temperatureLabel.text = nil
        weatherDescriptionLabel.text = nil
        sunriseLabel.text = nil
        sunsetLabel.text = nil
        humidityLabel.text = nil
        pressureLabel.text = nil
        windLabel.text = nil
        uvIndexLabel.text = nil
        latitudeLabel.text = nil
        longitudeLabel.text = nil
        
    }
    
    
    
}
