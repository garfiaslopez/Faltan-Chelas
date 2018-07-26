//
//  ChelaTableViewCell.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 25/05/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class ChelaTableViewCell: UITableViewCell {
    
    var Index = -1;
    var Parent:MenuChelasViewController!;
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var DescriptionLabel: UILabel!
    @IBOutlet weak var CountLabel: UILabel!
    
    @IBOutlet weak var PlusButton: UIButton!
    @IBOutlet weak var MinusButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func PlusAction(_ sender: AnyObject) {
        self.Parent.updateCounterAndPrices(self.Index, isPlus: true);
    }
    
    @IBAction func MinusAction(_ sender: AnyObject) {
        self.Parent.updateCounterAndPrices(self.Index, isPlus: false);
    }
    
    


}
