//
//  ProfileViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 24/05/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class ProfileViewController: UIViewController {

    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    let TopScroll = 40;
    let Save = UserDefaults.standard;

    @IBOutlet weak var MainScrollView: UIScrollView!
    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PhoneTextField: UITextField!
    @IBOutlet weak var OldPasswordTextField: UITextField!
    @IBOutlet weak var NewPasswordTextField: UITextField!
    @IBOutlet weak var SaveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if revealViewController() != nil {
            MenuButton.target = revealViewController();
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:));
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer());
        }
        self.NameTextField.text = self.UsuarioEnSesion.name;
        self.EmailTextField.text = self.UsuarioEnSesion.email;
        self.PhoneTextField.text = self.UsuarioEnSesion.phone;
        
        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
    }


    
    @IBAction func SaveAction(_ sender: AnyObject) {
        
        
        var DatatoSend: Parameters = ["":"" as AnyObject!];
        
        if(self.OldPasswordTextField.text != "" && self.NewPasswordTextField.text != "") {
            DatatoSend["oldPassword"] = self.OldPasswordTextField.text!;
            DatatoSend["password"] = self.NewPasswordTextField.text!;
        }
        
        if(self.EmailTextField.text != "") {
            if (isValidEmail(self.EmailTextField.text!)){
                DatatoSend["email"] = self.EmailTextField.text!;
            }else{
                self.alerta("Oops!", Mensaje: "El correo electrónico no es válido.");
            }
        }
        
        if(self.NameTextField.text != "") {
            DatatoSend["name"] = self.NameTextField.text!;
        }
        
        if(self.PhoneTextField.text != "") {
            DatatoSend["phone"] = self.PhoneTextField.text!;
        }
        
        DismissKeyboard();
        SwiftSpinner.show("Actualizando...");
        let AuthUrl = ApiUrl + "/user/" + self.UsuarioEnSesion._id;
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            Alamofire.request(AuthUrl, method: .put, parameters: DatatoSend, encoding: JSONEncoding.default,  headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        SwiftSpinner.hide();
                        self.alerta("Correcto", Mensaje: data["message"].stringValue );
                        // UPDATE LOCAL USUARIO SESION:
                        var SaveObj = [String : String]();
                        SaveObj["token"] = self.UsuarioEnSesion.token;
                        SaveObj["_id"] = self.UsuarioEnSesion._id;
                        SaveObj["email"] = self.EmailTextField.text;
                        SaveObj["password"] = self.NewPasswordTextField.text;
                        SaveObj["phone"] = self.UsuarioEnSesion.phone;
                        SaveObj["name"] = self.NameTextField.text;
                        SaveObj["typeuser"] = self.UsuarioEnSesion.typeuser;
                        
                        self.Save.set(SaveObj, forKey: "UsuarioEnSesion")
                        self.Save.synchronize();
                        
                        if let swreveal = self.parent?.parent as? SWRevealViewController {
                            if let menu = swreveal.rearViewController as? MenuTableViewController {
                                menu.UsuarioEnSesion = Session();
                                menu.reloadData();
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
    
    func KeyboardDidShow(){
        
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.DismissKeyboard))
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
        self.NewPasswordTextField.resignFirstResponder();
        self.OldPasswordTextField.resignFirstResponder();
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


}
