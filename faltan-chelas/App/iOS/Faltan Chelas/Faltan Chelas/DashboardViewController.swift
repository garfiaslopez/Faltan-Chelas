//
//  DashboardViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 24/05/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class DashboardViewController: UIViewController {

    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    let Save = UserDefaults.standard;

    @IBOutlet weak var OrdersLabel: UILabel!
    @IBOutlet weak var TotalOrdersLabel: UILabel!
    @IBOutlet weak var AvailableSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let connectionState = self.Save.value(forKey: "connectionState") as? Bool{
            self.AvailableSwitch.setOn(Bool(connectionState), animated: true);
        }
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        self.reloadDashboard();
    }
    func reloadDashboard(){
        SwiftSpinner.show("Cargando Historial.");
        
        let AuthUrl = ApiUrl + "/orders/byFilters";
        let status = Reach().connectionStatus();
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        var idToSend = "user_id";
        if self.UsuarioEnSesion.typeuser == "vendor" {
            idToSend = "vendor_id";
        }
        let DataToSend: Parameters = [
            "isTotals": true as AnyObject!,
            idToSend: self.UsuarioEnSesion._id  as AnyObject!,
            "dateFilter": "today" as AnyObject!,
        ];
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            Alamofire.request(AuthUrl, method: .post, parameters: DataToSend, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        self.TotalOrdersLabel.text = "$\(data["total"].doubleValue)";
                        self.OrdersLabel.text = "#\(data["count"].intValue)";
                        SwiftSpinner.hide();
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
            SwiftSpinner.hide();
            self.alerta("Error", Mensaje: "Favor de conectarse a internet");
        }
    }

    @IBAction func onChangeAvailable(_ sender: AnyObject) {
        
        let state = self.AvailableSwitch.isOn;
        
        self.Save.set(state, forKey: "connectionState");
        self.Save.synchronize();
        
        var label = "";
        if(state){
            label = "Activando";
        }else{
            label = "Desactivando";
        }
        
        SwiftSpinner.show(label);
        let AuthUrl = ApiUrl + "/user/" + self.UsuarioEnSesion._id;
        
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ];
        var DataToSend: Parameters =  [String: AnyObject]();
        DataToSend["available"] = state as AnyObject?;
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            Alamofire.request(AuthUrl, method: .put, parameters: DataToSend, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        SwiftSpinner.hide();
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
            SwiftSpinner.hide();
            self.alerta("Sin conexión a internet", Mensaje: "Favor de conectarse a internet para acceder.");
            break;
        }
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            print("Ok Pressed");
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
    

}
