//
//  SearchingVendorViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 21/06/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SearchingVendorViewController: UIViewController {
    
    var Order:OrderModel!;
    var UsuarioEnSesion:Session = Session();
    var clickedOrder = false;

    @IBOutlet weak var LoadingView: UIView!
    
    override func viewDidLoad() {
        print(self.LoadingView.frame);
        super.viewDidLoad()
        let frame = CGRect(x: 0, y: 0, width: 90, height: 90);
        let animationView =  NVActivityIndicatorView(frame: frame, type: .ballClipRotateMultiple, color: UIColor(hexString: "3E3D38"), padding: 0.0);
        self.LoadingView.addSubview(animationView);
        animationView.startAnimating();
    }
    
    @IBAction func CancelOrder(_ sender: AnyObject) {
        print("CancerlOrder");
        if(self.clickedOrder == false){
            self.clickedOrder = true;
            SocketIOManager.sharedInstance.SendState(self.Order._id, user_id: self.UsuarioEnSesion._id, state: "CancelOrder");
        }
    }
    
    
}
