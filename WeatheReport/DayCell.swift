//
//  DayCell.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 2/1/19.
//  Copyright © 2019 Dragan Milovanovic. All rights reserved.
//

import UIKit

class DayCell: UICollectionViewCell {
    
    @IBOutlet fileprivate weak var firstLabel: UILabel!
    @IBOutlet fileprivate weak var middleLabel: UILabel!
    @IBOutlet fileprivate weak var lastLabel: UILabel!
    
    
    // Data source
    var day: String? {
        didSet {
            guard let day = day else {
                cleanCell()
                return
            }
            
            populate(with: day)
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
        
        firstLabel.text = nil
        middleLabel.text = nil
        lastLabel.text = nil

    }
    
    
    //
    // Method for populating cell with data
    //
    fileprivate func populate(with dayName: String) {
        
        var dn: [Character] = []
        
        for character in dayName {
            dn.append(character)
        }
        
        firstLabel.text = String(dn.first!)
        middleLabel.text = String(dn[1])
        lastLabel.text = String(dn.last!)
        
    }
    
}
