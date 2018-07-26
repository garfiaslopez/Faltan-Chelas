//
//  TermsViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 24/05/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var WebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.NavigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Nexa Bold", size: 20)!, NSForegroundColorAttributeName:UIColor.black];
        self.NavigationBar.isTranslucent = false;
        
        let url = URL (string: "http://faltanchelas.com/terminos-y-condiciones.html");
        let requestObj = URLRequest(url: url!);
        self.WebView.loadRequest(requestObj);
    }

    @IBAction func CloseModal(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }

}
