//
//  MenuChelasViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 25/05/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import SwiftyJSON

class MenuChelasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    var ActualLocation = Loc();

    var Products:Array<ProductModel> = [];
    var MaxChelas = 24;
    var ExtraCharge = 20.00;
    var TotalPrice = 0;
    var ActualChelas = 0;
    
    
    @IBOutlet weak var MainTableView: UITableView!
    @IBOutlet weak var SubtotalLabel: UILabel!
    @IBOutlet weak var ExtrachargeLabel: UILabel!
    @IBOutlet weak var TotalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Nexa Bold", size: 20)!, NSForegroundColorAttributeName:UIColor.black];
        self.navigationController!.navigationBar.isTranslucent = false;
        self.navigationController!.navigationBar.topItem?.backBarButtonItem?.title = "Atras";
        self.navigationController!.title = "Menu Chelero";
    
        
        let nib = UINib(nibName: "ChelaTableViewCell", bundle: nil);
        self.MainTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        self.MainTableView.allowsSelection = false;
        
        self.reloadData();

    }
    
    
    
    func reloadData(){
        SwiftSpinner.show("Revisando el refri");
        
        let AuthUrl = ApiUrl + "/products/bytype/primary";
        let status = Reach().connectionStatus();
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            Alamofire.request(AuthUrl, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    
                    print(data);
                    if(data["success"] == true){
                        
                        self.Products = [];
                        self.ActualChelas = 0;
                        self.TotalPrice = 0;
                        
                        for (_,product):(String,JSON) in data["products"] {
                            
                            var tmp:ProductModel = ProductModel();
                            
                            tmp.denomination = product["denomination"].stringValue;
                            tmp.description = product["description"].stringValue;
                            tmp.type = product["type"].stringValue;
                            
                            var tmpPrice:PriceModel = PriceModel();
                            for (_,price):(String,JSON) in product["prices"] {
                                tmpPrice.quantity = price["quantity"].intValue;
                                tmpPrice.price = price["price"].doubleValue;
                                tmp.prices.append(tmpPrice);
                            }
                            print(tmp);
                            self.Products.append(tmp);
                        }
                        self.MainTableView.reloadData();
                        
                        let ConfigUrl = self.ApiUrl + "/config";
                        Alamofire.request(ConfigUrl, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                            
                            if response.result.isSuccess {
                                let data = JSON(data: response.data!);
                                if(data["success"] == true){
                                    for (_,config):(String,JSON) in data["configs"] {
                                        if(config["denomination"].stringValue == "MAX_CHELAS"){
                                            self.MaxChelas = config["parameter"].intValue;
                                        }
                                        if(config["denomination"].stringValue == "COMISION_CHELAS"){
                                            self.ExtraCharge = config["parameter"].doubleValue;
                                            self.ExtrachargeLabel.text = "$\(self.ExtraCharge)";
                                        }
                                    }
                                    SwiftSpinner.hide();
                                }else{
                                    self.alerta("Error de sesión", Mensaje: data["message"].stringValue );
                                }
                            }else{
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
            //No internet connection:
            SwiftSpinner.hide();
            self.alerta("Error", Mensaje: "Favor de conectarse a internet");
        }
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
    }

    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Products.count;
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
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine;

    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ChelaTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! ChelaTableViewCell;
        
        
        var Product = self.Products[(indexPath as NSIndexPath).row];
        cell.Index = (indexPath as NSIndexPath).row;
        cell.NameLabel.text = Product.denomination;
        cell.Parent = self;
        cell.CountLabel.text = "\(Product.counter)";
        
        if Product.prices.count > 0 {
            let pack = Product.prices[0].quantity;
            let price = Product.prices[0].price;
            
            if(pack == 6) {
                cell.DescriptionLabel.text = "$\(price) pesos el six";
            }else if(pack == 1){
                cell.DescriptionLabel.text = "$\(price) pesos por pieza";
            }else {
                cell.DescriptionLabel.text = "$\(price) pesos \(pack) piezas";
            }
        }
        return cell
    }

    func reloadPricesLabels(){
        
        var sum = 0.0;
        for product in self.Products {
            if product.prices.count > 0 {
                sum += (product.prices[0].price) * Double(product.counter);
            }
        }
        
        self.SubtotalLabel.text = "$\(sum)";
        self.ExtrachargeLabel.text = "$\(self.ExtraCharge)";
        self.TotalLabel.text = "$\(sum + self.ExtraCharge)";
    }
    
    func updateCounterAndPrices(_ Index:Int, isPlus: Bool) {
        if isPlus {
            if self.Products[Index].prices.count > 0 {
                let nextValue = self.Products[Index].prices[0].quantity + ActualChelas;
                if(nextValue <= MaxChelas) {
                    self.Products[Index].counter += 1;
                    self.ActualChelas = nextValue;
                }else{
                    self.alerta("Lo sentimos", Mensaje: "Nuestros repartidores no pueden llevar más de \(self.MaxChelas) chelas.");
                }
            }

        }else{
            if (Products[Index].counter > 0) {
                let nextValue = ActualChelas - self.Products[Index].prices[0].quantity;
                self.Products[Index].counter -= 1;
                self.ActualChelas = nextValue;
            }
        }
        self.MainTableView.reloadData();
        self.reloadPricesLabels();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "ResumeSegue"){
            if let destiny = segue.destination as? ResumeViewController {
                
                destiny.Products = [];

                for product in self.Products {
                    if product.counter != 0 {
                        destiny.Products.append(product);
                        destiny.ExtraCharge = self.ExtraCharge;
                        destiny.ActualLocation = self.ActualLocation;
                    }
                }
            }
        }
    }
    
    @IBAction func ContinueAction(_ sender: AnyObject) {
        
        if (self.ActualChelas != 0) {
            self.performSegue(withIdentifier: "ResumeSegue", sender: self);
        }else{
            self.alerta("¿Seguro?", Mensaje: "Selecciona al menos un tipo de chela");
        }
        
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default;
    }
    
    
    
}
