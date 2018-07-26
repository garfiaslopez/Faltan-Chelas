//
//  Navigation.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 22/05/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class Navigation: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Nexa Bold", size: 20)!, NSForegroundColorAttributeName:UIColor.black];
        
        self.navigationBar.isTranslucent = false;
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default;
    }
    


}
