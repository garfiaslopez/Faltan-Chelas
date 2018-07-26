//
//  StatusViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 24/05/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftSpinner
import AudioToolbox
import AirshipKit
import Alamofire
import SwiftyJSON


class StatusViewController: UIViewController {
    
    var CurrentViewController: UIViewController!;
    var CurrentSegueIdentifier: String!;
    var ActualLocation = Loc();
    var ActualOrder:OrderModel!;
    var UsuarioEnSesion:Session = Session();
    let ApiUrl = VARS().getApiUrl();
    let Save = UserDefaults.standard;
    let DELEGATE = UIApplication.shared.delegate as! AppDelegate;
    
    @IBOutlet weak var MainContainer: UIView!
    @IBOutlet weak var MenuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad();
        SocketIOManager.sharedInstance.delegate = self;
        if revealViewController() != nil {
            MenuButton.target = revealViewController();
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:));
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer());
        }
        if let controller = self.childViewControllers.first! as UIViewController? {
            self.CurrentViewController = controller;
        }
        //Check if is user or vendor:
        self.loadCorrectSubView();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.UsuarioEnSesion = Session();
        if(self.UsuarioEnSesion.token == "" && self.UsuarioEnSesion.name == ""){
            self.performSegue(withIdentifier: "LoginRegisterSegue", sender: self);
        }else{
        }
    }
    
    func loadCorrectSubView(){
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            SocketIOManager.sharedInstance.GetLastOrder(self.UsuarioEnSesion.typeuser, user_id: self.UsuarioEnSesion._id, state: "GetLastOrder");
        case .unknown, .offline:
            self.normalLoad();
            break;
        }
    }
    func normalLoad(){
        if self.UsuarioEnSesion.typeuser == "user" {
            self.performSegue(withIdentifier: "MapSegue", sender: self);
        }else{
            self.performSegue(withIdentifier: "DashboardSegue", sender: self);
        }
    }

    func reloadWithOrder(_ data: OrderModel) {
        
        print("reloadWithOrder");
        
        self.SoundAndVibrate();
        self.ActualOrder = data;
        
        if (self.UsuarioEnSesion.typeuser == "vendor") {
            if(self.ActualOrder != nil) {
                switch self.ActualOrder.status {
                case "Searching":
                    print("SEARCHING - OPERATOR");
                    self.performSegue(withIdentifier: "NewOrderSegue", sender: self);
                    
                case "Accepted":
                    print("Orden Accepted");
                    self.performSegue(withIdentifier: "MapOnWaySegue", sender: self);
                    
                case "Delivered":
                    SwiftSpinner.hide();
                    print("Orden Arrived");
                    self.performSegue(withIdentifier: "RateViewSegue", sender: self);
                    
                default:
                    print("NORMAL STATE");
                    SwiftSpinner.hide();
                    performSegue(withIdentifier: "DashboardSegue", sender: self);
                    
                }
            }else{
                SwiftSpinner.hide();
                performSegue(withIdentifier: "DashboardSegue", sender: self);
            }
            
            
        }else {
            
            if(self.ActualOrder != nil) {
                switch self.ActualOrder.status {
                    
                case "Searching":
                    print("SEARCHING - USER");
                    self.performSegue(withIdentifier: "SearchingVendorSegue", sender: self);
                    
                case "Accepted":
                    print("Orden Accepted");
                    self.performSegue(withIdentifier: "AcceptedOrderSegue", sender: self);
                    
                case "Delivered":
                    print("Orden Arrived");
                    self.performSegue(withIdentifier: "RateViewSegue", sender: self);
                    
                case "NotAccepted":
                    print("Orden Not Accepted");
                    SwiftSpinner.hide();
                    print(self.Save.bool(forKey: "NotifiedNotAccepted"));
                    if (!self.Save.bool(forKey: "NotifiedNotAccepted")){
                        self.alerta("En la m...", Mensaje: "Por el momento ningún repartidor puede tomar tu orden.");
                        self.Save.set(true, forKey: "NotifiedNotAccepted");
                        self.Save.synchronize();
                    }
                    self.performSegue(withIdentifier: "MapSegue", sender: self);
                    
                default:
                    print("NORMAL STATE");
                    SwiftSpinner.hide();
                    self.performSegue(withIdentifier: "MapSegue", sender: self);
                    
                }
            }else{
                SwiftSpinner.hide();
                self.performSegue(withIdentifier: "MapSegue", sender: self);
            }
        }
    }
    

    func CheckStatusOnServer(){
        
        print("CheckStatusOnServer");
        print(DELEGATE.hasPushOrder);
        
        if(DELEGATE.hasPushOrder){
            let GetUrl = self.ApiUrl + "/order/" + DELEGATE.Order;
            let status = Reach().connectionStatus();
            let headers: HTTPHeaders = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            switch status {
            case .online(.wwan), .online(.wiFi):
                Alamofire.request(GetUrl, encoding: JSONEncoding.default,headers: headers).responseJSON { response in
                    if response.result.isSuccess {
                        let data = JSON(data: response.data!);
                        if(data["success"] == true){
                            let newOrder = data["order"];
                            if(newOrder["status"].stringValue == "Searching") {
                                let Model = OrderModel(data: newOrder);
                                
                                print("OpenOrder");
                                SocketIOManager.sharedInstance.SendState(Model._id, user_id: self.UsuarioEnSesion._id, state: "OpenOrder");
                                
                                self.DELEGATE.hasPushOrder = false;
                                print("self.DELEGATE.hasPushOrder = false;");

                                self.ActualOrder = Model;
                                self.performSegue(withIdentifier: "NewOrderSegue", sender: self);
                            }
                        }else{
                            SwiftSpinner.hide();
                            self.alerta("Error de sesión", Mensaje: data["message"].stringValue );
                        }
                    }else{
                        SwiftSpinner.hide();
                        self.alerta("Error", Mensaje: (response.result.error?.localizedDescription)!);
                    }
                }
            case .unknown, .offline:
                //No internet connection:
                self.alerta("Error", Mensaje: "Favor de conectarse a internet");
            }
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MenuChelasSegue" {
            if let destiny = segue.destination as? MenuChelasViewController {
                destiny.ActualLocation = self.ActualLocation;
            }
        }
        
        if segue.identifier == "SearchingVendorSegue" {
            if let destiny = segue.destination as? SearchingVendorViewController {
                destiny.Order = self.ActualOrder;
            }
        }
        if segue.identifier == "NewOrderSegue" {
            if let destiny = segue.destination as? NewOrderViewController {
                destiny.Order = self.ActualOrder;
            }
        }
        
        if segue.identifier == "MapOnWaySegue" {
            if let destiny = segue.destination as? MapOnWayViewController {
                destiny.Order = self.ActualOrder;
            }
        }
        
        if segue.identifier == "RateViewSegue" {
            if let destiny = segue.destination as? RateViewController {
                destiny.Order = self.ActualOrder;
            }
        }
        
        if segue.identifier == "AcceptedOrderSegue" {
            if let destiny = segue.destination as? AcceptedOrderViewController {
                destiny.Order = self.ActualOrder;
            }
        }
        
    }

    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
    
    func SoundAndVibrate(){
        if(self.UsuarioEnSesion.typeuser == "vendor"){
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate));
            AudioServicesPlaySystemSound(1016);
        }
    }

}
