//
//  RegisterViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 24/05/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import AirshipKit

class RegisterViewController: UIViewController {
    let channelID = UAirship.push().channelID
    let ApiUrl = VARS().getApiUrl();
    let Save = UserDefaults.standard;
    let TopScroll = 110;
    
    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var PhoneTextfield: UITextField!
    @IBOutlet weak var EmailTextfield: UITextField!
    @IBOutlet weak var PasswordTextfield: UITextField!
    @IBOutlet weak var RegisterButton: UIButton!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var MainScrollView: UIScrollView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.NavigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Nexa Bold", size: 20)!, NSForegroundColorAttributeName:UIColor.black];
        self.NavigationBar.isTranslucent = false;
        
        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
    }

    @IBAction func RegisterAction(_ sender: AnyObject) {
        
        if (self.NameTextField.text != "" && self.EmailTextfield.text != "" && self.PhoneTextfield.text != "" && self.PasswordTextfield.text != "") {
            if (isValidEmail(self.EmailTextfield.text!)){
                DismissKeyboard();
                SwiftSpinner.show("Registrando...");
                let AuthUrl = ApiUrl + "/user";
                let status = Reach().connectionStatus();
                switch status {
                case .online(.wwan), .online(.wiFi):
                    let DatatoSend: Parameters = [
                        "email": self.EmailTextfield.text!,
                        "password": self.PasswordTextfield.text!,
                        "phone": self.PhoneTextfield.text!,
                        "name": self.NameTextField.text!
                        
                    ];
                    Alamofire.request(AuthUrl, method: .post, parameters: DatatoSend, encoding: JSONEncoding.default).responseJSON { response in
                        if response.result.isSuccess {
                            let data = JSON(data: response.data!);
                            if(data["success"] == true){
                                
                                SwiftSpinner.show("Iniciando Sesion...");
                                
                                let LoginURl = self.ApiUrl + "/authenticate";
                                let LoginDataToSend: Parameters = [
                                    "email": self.EmailTextfield.text!,
                                    "password": self.PasswordTextfield.text!,
                                ];
                                Alamofire.request(LoginURl, method: .post, parameters: LoginDataToSend, encoding: JSONEncoding.default).responseJSON { response in
                                    if response.result.isSuccess {
                                        let data = JSON(data: response.data!);
                                        if(data["success"] == true){
                                            
                                            //save the user and dissmiss the view
                                            var SaveObj = [String : String]();
                                            
                                            SaveObj["token"] = data["token"].stringValue;
                                            SaveObj["_id"] = data["user"]["_id"].stringValue;
                                            SaveObj["email"] = data["user"]["email"]["address"].stringValue;
                                            SaveObj["password"] = data["user"]["password"].stringValue;
                                            SaveObj["phone"] = data["user"]["phone"].stringValue;
                                            SaveObj["name"] = data["user"]["name"].stringValue;
                                            SaveObj["typeuser"] = data["user"]["typeuser"].stringValue;
                                            
                                            self.Save.set(SaveObj, forKey: "UsuarioEnSesion")
                                            self.Save.synchronize();
                                            
                                            SwiftSpinner.hide();
                                            
                                            UAirship.push().tags = [data["user"]["typeuser"].stringValue, "iOS"];
                                            UAirship.push().updateRegistration();
                                            
                                            if((UAirship.push().channelID) != nil){
                                                let PutUrl = self.ApiUrl + "/user/" + data["user"]["_id"].stringValue;
                                                let headers: HTTPHeaders = [
                                                    "Authorization": data["token"].stringValue
                                                ];
                                                let UserData: Parameters = [
                                                    "push_id": UAirship.push().channelID!
                                                ];
                                                
                                                Alamofire.request(PutUrl,method: .put, parameters: UserData, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                                                    if response.result.isSuccess {
                                                        print("SETED");
                                                    }else{
                                                        print((response.result.error?.localizedDescription)!);
                                                    }
                                                }
                                            }
                                            
                                            SocketIOManager.sharedInstance.establishConnection();
                                            
                                            if let swreveal = self.presentingViewController?.presentingViewController as? SWRevealViewController {
                                                if let menu = swreveal.rearViewController as? MenuTableViewController {
                                                    menu.UsuarioEnSesion = Session();
                                                    menu.reloadData();
                                                }
                                                if let navigation = swreveal.frontViewController as? Navigation {
                                                    if let Status = navigation.viewControllers.first as? StatusViewController{
                                                        Status.UsuarioEnSesion = Session();
                                                        Status.loadCorrectSubView();
                                                        Status.dismiss(animated: true, completion: nil);
                                                    }
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
                    self.alerta("Sin conexíon a internet", Mensaje: "Favor de conectarse a internet para acceder.");
                    break;
                }
                
            }else{
            
                self.alerta("Oops!", Mensaje: "Favor de introducir un correo válido.");
            }
        }else{
            self.alerta("Oops!", Mensaje: "Favor de rellenar todos los campos.");
        }
        
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
        self.EmailTextfield.resignFirstResponder();
        self.NameTextField.resignFirstResponder();
        self.PasswordTextfield.resignFirstResponder();
        self.PhoneTextfield.resignFirstResponder();
    }

    func isValidEmail(_ testStr:String) -> Bool {
        let emailExpression = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailExpression);
        return emailTest.evaluate(with: testStr);
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
    
    func alertWithCloseView(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.dismiss(animated: true, completion: nil);
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func CloseModal(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil);
    }
    
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default;
    }
    
    


}
