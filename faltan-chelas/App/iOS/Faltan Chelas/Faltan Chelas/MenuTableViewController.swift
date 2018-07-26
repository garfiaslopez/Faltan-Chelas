//
//  MenuTableViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 08/01/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON



class MenuTableViewController: UITableViewController {
    
    let Save = UserDefaults.standard;
    var UsuarioEnSesion:Session = Session();
    var ViewControllers:Array<UIViewController> = [];
    var ViewDescription:Array<[String:String]> = [];
    var ActualView:Int = 0;
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var EmailLabel: UILabel!
    @IBOutlet weak var ProfileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let nib = UINib(nibName: "MenuTableViewCell", bundle: nil);
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell");
        
        self.reloadData();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if UsuarioEnSesion.name != "" {
            self.NameLabel.text = self.UsuarioEnSesion.name;
        }
        if UsuarioEnSesion.email != "" {
            self.EmailLabel.text = self.UsuarioEnSesion.email;
        }
    }
    
    func reloadData(){
        
        self.UsuarioEnSesion = Session();

        
        self.ViewDescription = [];
        self.ViewControllers = [];
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        
        let StatusView = storyboard.instantiateViewController(withIdentifier: "StatusViewNav");
        let HistoryView = storyboard.instantiateViewController(withIdentifier: "HistoryViewNav");
        let ProfileView = storyboard.instantiateViewController(withIdentifier: "ProfileViewNav");
        let PayView = storyboard.instantiateViewController(withIdentifier: "PayViewNav");
        let HelpView = storyboard.instantiateViewController(withIdentifier: "HelpViewNav");
        
        if(UsuarioEnSesion.typeuser == "vendor"){
            self.ViewDescription.append(["name":"Dashboard","icon":"ChartBar.png"]);
        }else{
            self.ViewDescription.append(["name":"PedirChelas","icon":"Location.png"]);
        }
        self.ViewControllers.append(StatusView);
        
        self.ViewDescription.append(["name":"Historial","icon":"History.png"]);
        self.ViewControllers.append(HistoryView);
        
        self.ViewDescription.append(["name":"Perfil","icon":"Profile.png"]);
        self.ViewControllers.append(ProfileView);
        
        if(UsuarioEnSesion.typeuser == "user"){
            self.ViewDescription.append(["name":"Datos de pago","icon":"DebtCard.png"]);
            self.ViewControllers.append(PayView);
        }
        
        self.ViewDescription.append(["name":"Ayuda","icon":"Help.png"]);
        self.ViewControllers.append(HelpView);
        
        self.ViewDescription.append(["name":"Cerrar Sesión","icon":"Power.png"]);
        
        self.tableView.reloadData();
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ViewDescription.count;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! MenuTableViewCell;
        
        cell.NameLabel.text = self.ViewDescription[(indexPath as NSIndexPath).row]["name"];
        let image = UIImage(named: self.ViewDescription[(indexPath as NSIndexPath).row]["icon"]!);
        cell.IconImageView.image = image;
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let swreveal = self.parent as? SWRevealViewController {
            if (indexPath as NSIndexPath).row != self.ViewDescription.count - 1 {
                if(ActualView != (indexPath as NSIndexPath).row) {
                    self.ActualView = (indexPath as NSIndexPath).row;
                    swreveal.pushFrontViewController(self.ViewControllers[(indexPath as NSIndexPath).row], animated: true);
                }else{
                    swreveal.revealToggle(nil);
                }
            }else{
                self.logOut();
                self.Save.set(nil, forKey: "UsuarioEnSesion");
                self.Save.synchronize();
                SocketIOManager.sharedInstance.closeConnection();
                
                if self.ActualView == 0 {
                    if let nav = swreveal.frontViewController as? Navigation {
                        if let front = nav.viewControllers.first as? StatusViewController {
                            front.performSegue(withIdentifier: "LoginRegisterSegue", sender: front);
                        }
                    }
                } else {
                    self.ActualView = 0;
                    swreveal.pushFrontViewController(self.ViewControllers[0], animated: true);
                }
                
            }
        }
    }
    
    
    func logOut() {
        
        // in Server:
        let AuthUrl = VARS().getApiUrl() + "/authenticate/logoutuser";
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ];
        let DataToSend: Parameters = [
            "user_id": self.UsuarioEnSesion._id
        ];
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            Alamofire.request(AuthUrl, method: .post, parameters: DataToSend, encoding: JSONEncoding.default,  headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        print(data);
                    }else{
                    }
                }else{
                }
            }        default:
                break;
        }
        
        // change Local Variables :
        self.Save.set(false, forKey: "connectionState");
        self.Save.synchronize();
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent;
    }
    
}

