//
//  WRCell.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 11/28/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import UIKit

final class WRCell: UICollectionViewCell {
    
    @IBOutlet fileprivate var textOnlyLabels: [UILabel]!
    
    @IBOutlet weak fileprivate var locationLabel: UILabel!
    @IBOutlet weak fileprivate var weatherIcon: UIImageView!
    @IBOutlet weak fileprivate var temperatureLabel: UILabel!
    @IBOutlet weak fileprivate var weatherDescriptionLabel: UILabel!
    @IBOutlet weak fileprivate var sunriseLabel: UILabel!
    @IBOutlet weak fileprivate var sunsetLabel: UILabel!
    @IBOutlet weak fileprivate var humidityLabel: UILabel!
    @IBOutlet weak fileprivate var pressureLabel: UILabel!
    @IBOutlet weak fileprivate var windLabel: UILabel!
    @IBOutlet weak fileprivate var uvIndexLabel: UILabel!
    @IBOutlet weak fileprivate var latitudeLabel: UILabel!
    @IBOutlet weak fileprivate var longitudeLabel: UILabel!
    
    @IBOutlet weak fileprivate var forecastCollectionVew: UICollectionView!
    
    
    //  Data source
    var weatherData: WeatherData? {
        didSet {
            guard let weatherData = weatherData else {
                cleanCell()
                return
            }
            // Register Forecast Collection View Cell
            let fcNib = UINib(nibName: "ForecastCell", bundle: nil)
            forecastCollectionVew.register(fcNib, forCellWithReuseIdentifier: "ForecastCell")
            forecastCollectionVew.reloadData()
            
            populate(with: weatherData)
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
    // Method for cleaning datas for UI
    //
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
    
    
    
    //
    // Method for informing user about error
    //
    fileprivate func displayMessage() {
        
        weatherIcon.image = nil
        temperatureLabel.text = ""
        weatherDescriptionLabel.text = ""
        sunriseLabel.text = ""
        sunsetLabel.text = ""
        humidityLabel.text = ""
        pressureLabel.text = ""
        windLabel.text = ""
        uvIndexLabel.text = ""
        latitudeLabel.text = ""
        longitudeLabel.text = ""
        
    }
    
    
    //
    // Method for populating UI with datas
    //
    fileprivate func populate(with weatherData: WeatherData) {
        
        if let location = weatherData.locationName {
            if location == "" {
                locationLabel.text = "Nameless Location"
                
            } else if location == "Connection Issues" || location == "Weather Unavalable" {
                forecastCollectionVew.reloadData()
                locationLabel.text = location
                displayMessage()
                return
            }
            locationLabel.text = location
            
        } else {
            cleanCell()
            return
        }
        
        
        if let weatherIconName = weatherData.weatherIconName {
            weatherIcon.image = UIImage(named: weatherIconName)
        } else {
            cleanCell()
            return
        }
        
        
        if let temp = weatherData.temperature {
            temperatureLabel.text = "\(temp)°"
        } else {
            cleanCell()
            return
        }
        
        
        if let desc = weatherData.description {
            weatherDescriptionLabel.text = "Now: \(desc) Currently. It's \(weatherData.temperature!)°C."
        }
        
        
        if let sunRise = weatherData.sunRise {
            sunriseLabel.text = weatherData.convertUnixTimestampToTime(timeStamp: sunRise, format: .HoursAndMinutes)
        } else {
            sunriseLabel.text = "N/A"
        }
        
        
        if let sunSet = weatherData.sunSet {
            sunsetLabel.text = weatherData.convertUnixTimestampToTime(timeStamp: sunSet, format: .HoursAndMinutes)
        } else {
            sunsetLabel.text = "N/A"
        }
        
        
        if let hum = weatherData.humidity {
            humidityLabel.text = "\(hum)%"
        } else {
            humidityLabel.text = "N/A"
        }
        
        
        if let prs = weatherData.pressure {
            pressureLabel.text = "\(prs) hPa"
        } else {
            pressureLabel.text = "N/A"
        }
        
        
        if let windDir = weatherData.windDirection, let windSpd = weatherData.windSpeed {
            if windSpd != 0 {
                windLabel.text = "\(windDir) \(windSpd) m/s"
            }
            if windSpd == 0 {
                windLabel.text = "\(windSpd) m/s"
            }
        } else {
            windLabel.text = "N/A"
        }
        
        
        if let uvi = weatherData.uvIndex {
            uvIndexLabel.text = uvi
        } else {
            uvIndexLabel.text = "N/A"
        }
        
        
        if let lat = weatherData.latitude {
            latitudeLabel.text = "\(lat)"
        } else {
            latitudeLabel.text = "N/A"
        }
        
        
        if let lon = weatherData.longitude {
            longitudeLabel.text = "\(lon)"
        } else {
            locationLabel.text = "N/A"
        }
        
    }
    
}



extension WRCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherData?.forecastDatas.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let weatherData = weatherData else { fatalError("WRCell doesn't exist!") }
        
        let forecastCell: ForecastCell = forecastCollectionVew.dequeueReusableCell(withReuseIdentifier: "ForecastCell", for: indexPath) as! ForecastCell

        forecastCell.forecastData = weatherData.forecastDatas[indexPath.item]
        
        return forecastCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let bounds = collectionView.bounds
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        var size = flowLayout.itemSize
        let rows: CGFloat = 9
        
        let availableWidth = bounds.width - (rows - 9) * flowLayout.minimumInteritemSpacing - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        
        size.height = bounds.height
        size.width = availableWidth / rows
        
        return size
    }
    
}
