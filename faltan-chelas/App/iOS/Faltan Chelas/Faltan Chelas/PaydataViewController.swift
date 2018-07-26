//
//  PaydataViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 24/05/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire

class PaydataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    var Paymethods:Array<PaymethodModel> = [];
    
    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var MainTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if revealViewController() != nil {
            MenuButton.target = revealViewController();
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:));
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer());
        }
        
        let nib = UINib(nibName: "PaydataTableViewCell", bundle: nil);
        self.MainTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        self.MainTableView.allowsSelection = false;
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.reloadData();
    }
    
    
    func reloadData(){
        SwiftSpinner.show("Cargando métodos de pago");
        
        let AuthUrl = ApiUrl + "/conekta/cards/" + self.UsuarioEnSesion._id;
        let status = Reach().connectionStatus();
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            Alamofire.request(AuthUrl,encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        self.Paymethods = [];
                        
                        for (_,card):(String,JSON) in data["cards"] {
                            
                            var tmp:PaymethodModel = PaymethodModel();
                            
                            tmp.tokenization = card["id"].stringValue;
                            tmp.termination = card["last4"].stringValue;
                            tmp.brand = card["brand"].stringValue;

                            self.Paymethods.append(tmp);
                        }
                        self.MainTableView.reloadData();
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddPaydataSegue" {
            if let destiny = segue.destination as? AddPaydataViewController {
                destiny.Paymethods = self.Paymethods;
            }
        }
    }
    
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Paymethods.count;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
            cell.separatorInset = UIEdgeInsets.zero;
        }
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)){
            cell.preservesSuperviewLayoutMargins = false;
        }
        
        if cell.responds(to: #selector(setter: UIView.layoutMargins)){
            cell.layoutMargins = UIEdgeInsets.zero;
        }
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:PaydataTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! PaydataTableViewCell;
        cell.IconImageView.image = UIImage(named: "\(self.Paymethods[(indexPath as NSIndexPath).row].brand).png");
        cell.TerminationLabel.text = "**** **** **** \(self.Paymethods[(indexPath as NSIndexPath).row].termination)";
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            
            let AuthUrl = ApiUrl + "/conekta/card/\(self.UsuarioEnSesion._id)/\(self.Paymethods[(indexPath as NSIndexPath).row].tokenization)";
            
            self.Paymethods.remove(at: (indexPath as NSIndexPath).row);
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic);

            let status = Reach().connectionStatus();
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            switch status {
            case .online(.wwan), .online(.wiFi):
                
                Alamofire.request(AuthUrl, method: .delete, encoding: JSONEncoding.default,headers: headers).responseJSON { response in
                    
                    if response.result.isSuccess {
                        let data = JSON(data: response.data!);
                        if(data["success"] == true){
                            self.alerta("Correcto", Mensaje: "Tarjeta eliminada correctamente");
                        }else{
                            self.alerta("Error de sesión", Mensaje: data["message"].stringValue );
                        }
                    }else{
                        SwiftSpinner.hide();
                        self.alerta("Error", Mensaje: (response.result.error?.localizedDescription)!);
                    }
                }
            case .unknown, .offline:
                //No internet connection:
                SwiftSpinner.hide();
                self.alerta("Error", Mensaje: "Favor de conectarse a internet");
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


}
