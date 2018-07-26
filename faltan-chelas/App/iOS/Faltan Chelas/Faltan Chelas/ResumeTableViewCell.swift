//
//  ResumeTableViewCell.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 19/06/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class ResumeTableViewCell: UITableViewCell {

    @IBOutlet weak var DenominationLabel: UILabel!
    @IBOutlet weak var QuantityLabel: UILabel!
    @IBOutlet weak var PriceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
