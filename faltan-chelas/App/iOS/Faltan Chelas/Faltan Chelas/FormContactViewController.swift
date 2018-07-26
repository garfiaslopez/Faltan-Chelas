//
//  FormContactViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 24/05/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import SwiftyJSON

class FormContactViewController: UIViewController {

    let TopScroll = 110;
    
    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PhoneTextField: UITextField!
    @IBOutlet weak var MessageTextView: UITextView!
    @IBOutlet weak var MainScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.NavigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Nexa Bold", size: 20)!, NSForegroundColorAttributeName:UIColor.black];
        self.NavigationBar.isTranslucent = false;
    
        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
    }

    @IBAction func SendAction(_ sender: AnyObject) {
        
        if(self.NameTextField.text != "" && self.EmailTextField.text != "" && self.PhoneTextField.text != "" && self.MessageTextView.text != ""){
            
            SwiftSpinner.show("Enviando");
            
            let Url = "https://api.mailgun.net/v3/sandboxc8bfca74f8654582b79205d3a5487403.mailgun.org/messages";
            let username = "api"
            let password = "key-f653875d04623700dd6733fca9b2bb32"
            let loginString = NSString(format: "%@:%@", username, password)
            let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
            let base64LoginString = loginData.base64EncodedString(options: [])
            let headers = [
                "Authorization": "Basic \(base64LoginString)",
                "Content-Type": "application/x-www-form-urlencoded"
            ];
            let parameters: Parameters = [
                "from": "\(self.NameTextField.text!)<\(self.EmailTextField.text!)>",
                "to": "Contacto FaltanChelas<contacto@faltanchelas.com>",
                "subject": "QUIERO REPARTIR",
                "text":"\(self.MessageTextView.text) ---- Teléfono: \(self.PhoneTextField.text!)"
            ];
            
            let status = Reach().connectionStatus();
        
            switch status {
            case .online(.wwan), .online(.wiFi):
                
                Alamofire.request(Url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON {
                    response in
                    if response.result.isSuccess {
                        self.doneEmail();
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
            self.alerta("Oops!", Mensaje: "Favor de llenar todos los campos.");
        }

    }
    func doneEmail(){
        SwiftSpinner.hide();
        self.NameTextField.text = "";
        self.PhoneTextField.text = "";
        self.MessageTextView.text = "";
        self.EmailTextField.text = "";
        self.alerta("Perfecto", Mensaje: "Muchas gracias por escribirnos, te contactaremos lo antes posible.");

    }
    func KeyboardDidShow(){
        
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.MainScrollView.setContentOffset(CGPoint(x: 0, y: TopScroll), animated: true);
        
        
    }
    func KeyboardDidHidden(){
        
        //quita los gestos para que no halla interferencia despues
        if let recognizers = self.view.gestureRecognizers {
            for recognizer in recognizers {
                self.view.removeGestureRecognizer(recognizer )
            }
        }
        
        self.MainScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true);
        
    }
    
    func DismissKeyboard(){
        self.EmailTextField.resignFirstResponder();
        self.NameTextField.resignFirstResponder();
        self.MessageTextView.resignFirstResponder();
        self.PhoneTextField.resignFirstResponder();
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            print("Ok PRessed");
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func CloseModal(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }

}
