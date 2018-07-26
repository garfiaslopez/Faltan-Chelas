//
//  RateViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 28/06/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class RateViewController: UIViewController {
    
    var Order:OrderModel!;
    var UsuarioEnSesion:Session = Session();
    let ApiUrl = VARS().getApiUrl();
    var Buttons:Array<UIImageView> = [];
    let DELEGATE = UIApplication.shared.delegate as! AppDelegate;

    @IBOutlet weak var DetailLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
    
    @IBOutlet weak var OneBeerImageView: UIImageView!
    @IBOutlet weak var TwoBeerImageView: UIImageView!
    @IBOutlet weak var ThreeBeerImageView: UIImageView!
    @IBOutlet weak var FourBeerImageView: UIImageView!
    @IBOutlet weak var FiveBeerImageView: UIImageView!
    
    @IBOutlet weak var FirstLabel: UILabel!
    @IBOutlet weak var SecondLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        Buttons.append(OneBeerImageView);
        Buttons.append(TwoBeerImageView);
        Buttons.append(ThreeBeerImageView);
        Buttons.append(FourBeerImageView);
        Buttons.append(FiveBeerImageView);
        
        if(self.Order.isPaid){
            self.alerta("Pago procesado", Mensaje: "Se ha realizado el pago de tu pedido, muchas gracias.");
        }else{
            self.alerta("Pago no procesado", Mensaje: "El pago no pudo ser procesado correctamente.");
        }
        
        if(self.UsuarioEnSesion.typeuser == "vendor"){
            self.DetailLabel.text = "CALIFICA AL USUARIO";
            self.NameLabel.text = self.Order.user_id.name;
            
            self.FirstLabel.text = "¡LAS CHELAS HAN";
            self.SecondLabel.text = "SIDO ENTREGADAS!";

        }else{
            self.DetailLabel.text = "CALIFICA A TU REPARTIDOR";
            self.NameLabel.text = self.Order.vendor_id.name;
        }
        
    }
    
    func drawBeers(_ beers:Int){
        
        for beer in 0...beers {
            print(beer);
            self.Buttons[beer].image = UIImage(named: "FullBeerCalf.png");
        }
        
        if(beers < 4){
            for beer in (beers + 1)...(4){
                self.Buttons[beer].image = UIImage(named: "EmptyBeerCalf.png");
            }
        }

    }
    func rateUser(_ rate:Int){

        SwiftSpinner.show("Calificando");
        let AuthUrl = ApiUrl + "/rateuser";
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        var id = "";
        if(self.UsuarioEnSesion.typeuser == "user"){
            id = self.Order.vendor_id._id;
        }else{
            id = self.Order.user_id._id;
        }
        
        let DataToSend: Parameters = [
            "user_id": id as AnyObject!,
            "rate": rate as AnyObject!,
        ];
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            Alamofire.request(AuthUrl, method: .post, parameters: DataToSend, encoding: JSONEncoding.default,  headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        
                        SwiftSpinner.hide();
                        
                        if let parent = self.parent as? StatusViewController {
                            SocketIOManager.sharedInstance.SendState(self.Order._id, user_id: self.UsuarioEnSesion._id, state: "RatedUser");
                            if (self.UsuarioEnSesion.typeuser == "vendor") {
                                parent.performSegue(withIdentifier: "DashboardSegue", sender: parent);

                            }else{
                                parent.performSegue(withIdentifier: "MapSegue", sender: parent);
                            }
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
            SwiftSpinner.hide();
            self.alerta("Sin conexión a internet", Mensaje: "Favor de conectarse a internet para acceder.");
            break;
        }
    }
    
    @IBAction func OneBeerAction(_ sender: AnyObject) {
        self.drawBeers(0);
        self.rateUser(1);
    }

    @IBAction func TwoBeerAction(_ sender: AnyObject) {
        self.drawBeers(1);
        self.rateUser(2);
    }

    @IBAction func ThreeBeerAction(_ sender: AnyObject) {
        self.drawBeers(2);
        self.rateUser(3);
    }
    @IBAction func FourBeerAction(_ sender: AnyObject) {
        self.drawBeers(3);
        self.rateUser(4);
    }
    @IBAction func FiveBeerAction(_ sender: AnyObject) {
        self.drawBeers(4);
        self.rateUser(5);
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

    
    
    
}
