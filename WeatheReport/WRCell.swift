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
    // Method for populating UI with datas
    //
    func populate(with weatherData: WeatherData) {
        
        if let weatherIconName = weatherData.weatherIconName {
            
            locationLabel.text = weatherData.locationName
            weatherIcon.image = UIImage(named: weatherIconName)
            temperatureLabel.text = "\(weatherData.temperature!)°"
            weatherDescriptionLabel.text = "Now: \(weatherData.description!) currently. It's \(weatherData.temperature!)°C."
            sunriseLabel.text = weatherData.convertUnixTimestampToTime(timeStamp: weatherData.sunRise!, format: .HoursAndMinutes)
            sunsetLabel.text = weatherData.convertUnixTimestampToTime(timeStamp: weatherData.sunSet!, format: .HoursAndMinutes)
            humidityLabel.text = "\(weatherData.humidity!)%"
            pressureLabel.text = "\(weatherData.pressure!) hPa"
            windLabel.text = "\(weatherData.windDirection!) \(weatherData.windSpeed!) m/s"
            uvIndexLabel.text = weatherData.uvIndex
            latitudeLabel.text = "\(weatherData.latitude!)"
            longitudeLabel.text = "\(weatherData.longitude!)"

        } else { return }
        
    }
    
}



extension WRCell: UICollectionViewDataSource {
    
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
    
    
}






















