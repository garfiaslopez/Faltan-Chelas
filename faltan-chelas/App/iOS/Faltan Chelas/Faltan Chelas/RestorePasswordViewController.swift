//
//  RestorePasswordViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 11/07/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import SwiftyJSON

class RestorePasswordViewController: UIViewController {

    
    let ApiUrl = VARS().getApiUrl();
    let Save = UserDefaults.standard;
    let DELEGATE = UIApplication.shared.delegate as! AppDelegate;
    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var RestoreButton: UIButton!
    @IBOutlet weak var NavigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.NavigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Nexa Bold", size: 20)!, NSForegroundColorAttributeName:UIColor.black];
        self.NavigationBar.isTranslucent = false;
        
        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func CloseModal(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }
    @IBAction func RestoreAction(_ sender: AnyObject) {
        if(self.EmailTextField.text != ""){
            SwiftSpinner.show("Restaurando");
            
            let AuthUrl = ApiUrl + "/forgotpassword";
            let status = Reach().connectionStatus();
            
            switch status {
            case .online(.wwan), .online(.wiFi):
                
                let DatatoSend: Parameters = ["email": self.EmailTextField.text as AnyObject!];
                Alamofire.request(AuthUrl, method: . post, parameters: DatatoSend, encoding: JSONEncoding.default).responseJSON { response in
                    if response.result.isSuccess {
                        let data = JSON(data: response.data!);
                        if(data["success"] == true){
                            SwiftSpinner.hide();
                            self.alerta("Correcto", Mensaje: data["message"].stringValue );
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
            alerta("Oops!", Mensaje: "Favor de introducir tu correo");
        }
    }
  
    func KeyboardDidShow(){
        
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.DismissKeyboard))
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
    func DismissKeyboard(){
        self.EmailTextField.resignFirstResponder();
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
    
    
    
}
