//
//  AcceptedOrderViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 26/06/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import MessageUI

class AcceptedOrderViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    var Order:OrderModel!;
    var UsuarioEnSesion:Session = Session();
    var clickedOrder = false;

    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var MarketnameLabel: UILabel!
    @IBOutlet weak var SmsView: UIView!
    @IBOutlet weak var CallView: UIView!
    @IBOutlet weak var RankLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.NameLabel.text = self.Order.vendor_id.name;
        self.MarketnameLabel.text = self.Order.vendor_id.marketname;
        self.RankLabel.text = String(format: "%.1f", self.Order.user_id.rate);
        
        self.SmsView.layer.borderColor = UIColor.white.cgColor;
        self.SmsView.layer.borderWidth = 1.0;
        self.CallView.layer.borderColor = UIColor.white.cgColor;
        self.CallView.layer.borderWidth = 1.0;
        
        // Do any additional setup after loading the view.
    }

    @IBAction func CallAction(_ sender: AnyObject) {
        let phoneNumber: String = "telprompt://" + self.Order.vendor_id.phone;
        UIApplication.shared.openURL(URL(string:phoneNumber)!);
    }

    @IBAction func SmsAction(_ sender: AnyObject) {
        let messageVC = MFMessageComposeViewController();
        messageVC.body = "Hola \(self.Order.vendor_id.name), estoy a la espera de mi pedido.";
        messageVC.recipients = [self.Order.vendor_id.phone];
        messageVC.messageComposeDelegate = self;
        self.present(messageVC, animated: false, completion: nil);
    }
    @IBAction func CancelOrder(_ sender: Any) {
        if(self.clickedOrder == false){
            self.clickedOrder = true;
            SocketIOManager.sharedInstance.SendState(self.Order._id, user_id: self.UsuarioEnSesion._id, state: "CancelOrder");
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case MessageComposeResult.cancelled:
            print("Message was cancelled");
            self.dismiss(animated: true, completion: nil);
        case MessageComposeResult.failed:
            print("Message failed");
            self.dismiss(animated: true, completion: nil);
        case MessageComposeResult.sent:
            print("Message was sent");
            self.dismiss(animated: true, completion: nil);
        }
    }
    
}
