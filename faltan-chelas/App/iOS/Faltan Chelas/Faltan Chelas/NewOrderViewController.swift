//
//  NewOrderViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 21/06/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftSpinner
import SwiftyJSON
import Alamofire

class NewOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let ApiUrl = VARS().getApiUrl();
    var Order:OrderModel!;
    let DELEGATE = UIApplication.shared.delegate as! AppDelegate;
    var UsuarioEnSesion:Session = Session();

    let HeightForProductCell = 45.0;
    let HeightForPaymethodCell = 45.0;
    let HeightForHeader = 50.0;
    let TopScroll = 100.0;
    var ExtraCharge = 0.0;
    var TotalOrder =  0.0;
    var AcceptedOrder = false;
    
    @IBOutlet weak var ProductsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var MainScrollView: UIScrollView!
    @IBOutlet weak var MainView: UIView!
    @IBOutlet weak var ProductsTableView: UITableView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var AddressLabel: UILabel!
    @IBOutlet weak var SubtotalLabel: UILabel!
    @IBOutlet weak var TotalLabel: UILabel!
    @IBOutlet weak var ExtraChargeLabel: UILabel!
    @IBOutlet weak var TotalView: UIView!
    @IBOutlet weak var RankLabel: UILabel!
    @IBOutlet weak var CancelButtonView: UIView!
    @IBOutlet weak var AcceptButtonView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let nib = UINib(nibName: "ResumeTableViewCell", bundle: nil);
        self.ProductsTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        self.ProductsTableView.allowsSelection = false;
        self.ProductsTableView.isUserInteractionEnabled = false;
        
        self.AddressLabel.text = self.Order.destiny.address;
        self.NameLabel.text = self.Order.user_id.name;
        self.RankLabel.text = String(format: "%.1f", self.Order.user_id.rate);
        
        self.CancelButtonView.layer.borderColor = UIColor.white.cgColor;
        self.CancelButtonView.layer.borderWidth = 1.0;
        self.AcceptButtonView.layer.borderColor = UIColor.white.cgColor;
        self.AcceptButtonView.layer.borderWidth = 1.0;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.AcceptedOrder = false;
        
        self.getConfig();
        self.ProductsTableView.reloadData();
        self.reloadPricesLabels();
        self.resizeTableViews();
    }
    
    func getConfig(){
        let ConfigUrl = self.ApiUrl + "/config";
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        Alamofire.request(ConfigUrl, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.result.isSuccess {
                let data = JSON(data: response.data!);
                if(data["success"] == true){
                    for (_,config):(String,JSON) in data["configs"] {
                        if(config["denomination"].stringValue == "COMISION_CHELAS"){
                            self.ExtraCharge = config["parameter"].doubleValue;
                            self.ExtraChargeLabel.text = "$\(self.ExtraCharge)";
                        }
                    }
                    SwiftSpinner.hide();
                    
                }else{
                    SwiftSpinner.hide();
                    self.alerta("Error de sesión", Mensaje: data["message"].stringValue );
                }
            } else {
                SwiftSpinner.hide();
                self.alerta("Error", Mensaje: (response.result.error?.localizedDescription)!);
            }
        }
    }

    func resizeTableViews(){
        let sizeCells = Double(self.Order.products.count) * self.HeightForProductCell + HeightForHeader;
        self.ProductsTableViewHeight.constant = CGFloat(sizeCells);
        
        addBorderUtility(x: 0, y: CGFloat(sizeCells - 1)  , width: self.ProductsTableView.frame.width, height: 1, color: UIColor(hexString: "FAE804"));
        addBorderUtility(x: 0, y: 0  , width: self.ProductsTableView.frame.width, height: 1, color: UIColor(hexString: "FAE804"));

        let totalViewHeightSize = CGFloat(sizeCells) + self.TotalView.frame.height;
        self.MainScrollView.contentSize = CGSize(width: self.MainScrollView.frame.width, height: totalViewHeightSize);
        
        self.MainView.frame = CGRect(x: 0, y: 0, width: self.MainScrollView.frame.width, height: totalViewHeightSize);
    }
    
    func addBorderUtility(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        self.ProductsTableView.layer.addSublayer(border)
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Order.products.count;
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(HeightForHeader);
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let Title = UILabel(frame: CGRect(x: 30, y: 10, width: 100, height: 35));
        Title.text = "      DESCRIPCION DE PEDIDO";
        Title.textColor = UIColor.black;
        Title.font = UIFont(name: "Nexa Bold", size: 15);
        
        return Title;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(self.HeightForProductCell);
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ResumeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! ResumeTableViewCell;
        
        let Product = self.Order.products[(indexPath as NSIndexPath).row];
        cell.DenominationLabel.text = Product.denomination;
        cell.PriceLabel.text = "$\(Product.price)";
        if(Product.quantity == 6){
            cell.QuantityLabel.text = "\(Product.units) six";
        }else{
            cell.QuantityLabel.text = "\(Product.units * Product.quantity) piezas";
        }

        return cell
    }
    
    
    func reloadPricesLabels(){
        var sum = 0.0;
        for product in self.Order.products {
            sum += (product.price) * Double(product.units);
        }
        self.SubtotalLabel.text = "$\(sum)";
        self.ExtraChargeLabel.text = "$\(self.ExtraCharge)";
        self.TotalOrder = sum + self.ExtraCharge;
        self.TotalLabel.text = "$\(self.Order.total)";
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
    
    @IBAction func CancelAction(_ sender: AnyObject) {
        SocketIOManager.sharedInstance.SendState(self.Order._id, user_id: self.UsuarioEnSesion._id, state: "RejectOrder");
        if let parent = self.parent as? StatusViewController {
            if (self.UsuarioEnSesion.typeuser == "vendor") {
                parent.performSegue(withIdentifier: "DashboardSegue", sender: parent);
            }
        }
    }
    @IBAction func AcceptAction(_ sender: AnyObject) {
        if(self.AcceptedOrder == false){
            self.AcceptedOrder = true;
            SocketIOManager.sharedInstance.AcceptOrder(self.Order._id, user_id: self.UsuarioEnSesion._id);
        }
    }

}
