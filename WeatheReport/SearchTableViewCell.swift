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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        searchLocationLabel.text = nil
    }

    
    func configure(with location: String?) {
        
        if let loc = location {
            searchLocationLabel.text = loc
        } else { return }
        
    }
    
}
