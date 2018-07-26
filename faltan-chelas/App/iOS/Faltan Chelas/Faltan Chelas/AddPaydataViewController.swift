//
//  AddPaydataViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 19/06/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import SwiftyJSON

class AddPaydataViewController: UIViewController {

    
    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    var Paymethods:Array<PaymethodModel> = [];

    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var NumberTextField: UITextField!
    @IBOutlet weak var MonthTextField: UITextField!
    @IBOutlet weak var YearTextField: UITextField!
    @IBOutlet weak var SecureNumberTextField: UITextField!
    @IBOutlet weak var SaveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
    
    }

    @IBAction func SaveAction(_ sender: AnyObject) {
        
        if (self.NumberTextField.text != "" && self.NameTextField.text != "" && self.SecureNumberTextField.text != "" &&
            self.MonthTextField.text != "" && self.YearTextField.text != ""){
            
            self.DismissKeyboard();
            SwiftSpinner.show("Guardando método de pago.");

            let conekta = Conekta();
            conekta.delegate = self;
            conekta.publicKey = VARS().getConektaPublicKey();
            conekta.collectDevice();
            let card = conekta.card();
            card?.setNumber(self.NumberTextField.text, name: self.NameTextField.text, cvc: self.SecureNumberTextField.text, expMonth: self.MonthTextField.text, expYear: self.YearTextField.text);
            
            let token = conekta.token();
            token?.card = card;
            token?.create(success: { (data) -> Void in
                if (data?["object"] as! String != "error"){
                    let AuthUrl = self.ApiUrl + "/conekta/card";
                    let headers = [
                        "Authorization": self.UsuarioEnSesion.token
                    ]
                    let status = Reach().connectionStatus();
                    switch status {
                    case .online(.wwan), .online(.wiFi):
                        
                        let DataToSend: Parameters = [
                            "user_id": self.UsuarioEnSesion._id as AnyObject!,
                            "card_token": data?["id"] as AnyObject!,
                        ];
                        
                        Alamofire.request(AuthUrl, method: .post, parameters: DataToSend, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                            
                            if response.result.isSuccess {
                            
                                let data = JSON(data: response.data!);
                                
                                if(data["success"] == true){
                                    SwiftSpinner.hide();
                                    self.cleanTextFields();
                                    self.alertaAndDissmiss("Correcto", Mensaje: data["message"].stringValue );
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
                }else{
                    SwiftSpinner.hide();
                    self.alerta("Oops!", Mensaje: data?["message_to_purchaser"] as! String);
                }
                
                }, andError: { (error) -> Void in
                    print(error ?? "");
            })
        }else{
            SwiftSpinner.hide();

            self.alerta("Oops!", Mensaje: "Favor de llenar todos los campos");
        }

    }
    
    @IBAction func CloseModal(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }
    
    func cleanTextFields() {
        self.NameTextField.text = "";
        self.NumberTextField.text = "";
        self.MonthTextField.text = "";
        self.YearTextField.text = "";
        self.SecureNumberTextField.text = "";
    }
    func KeyboardDidShow(){
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddPaydataViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func KeyboardDidHidden(){
        //quita los gestos para que no halla interferencia despues
        if let recognizers = self.view.gestureRecognizers {
            for recognizer in recognizers {
                self.view.removeGestureRecognizer(recognizer )
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
    func alertaAndDissmiss(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.dismiss(animated: true, completion: nil);
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func DismissKeyboard(){
        self.NameTextField.resignFirstResponder();
        self.NumberTextField.resignFirstResponder();
        self.YearTextField.resignFirstResponder();
        self.SecureNumberTextField.resignFirstResponder();
    }

}
