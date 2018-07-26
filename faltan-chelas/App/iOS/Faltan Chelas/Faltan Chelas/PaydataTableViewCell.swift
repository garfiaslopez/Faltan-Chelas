//
//  PaydataTableViewCell.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 19/06/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class PaydataTableViewCell: UITableViewCell {

    @IBOutlet weak var TerminationLabel: UILabel!
    @IBOutlet weak var IconImageView: UIImageView!
    @IBOutlet weak var DetailView: UIView!
    @IBOutlet weak var CheckmarkImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
