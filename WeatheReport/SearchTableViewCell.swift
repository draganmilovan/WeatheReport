//
//  SearchTableViewCell.swift
//  WeatheReport
//
//  Created by Dragan Milovanovic on 1/12/18.
//  Copyright © 2018 Dragan Milovanovic. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak fileprivate var searchLocationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        searchLocationLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(with location: String) {
        searchLocationLabel.text = location
    }
    
}
