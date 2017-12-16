//
//  ForecastCell.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 12/16/17.
//  Copyright © 2017 Dragan Milovanovic. All rights reserved.
//

import UIKit

class ForecastCell: UICollectionViewCell {
    
    
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
    
    
    
    func cleanCell() {
        
    }
    
    
    func populate(with forecastData: ForecastData) {
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
