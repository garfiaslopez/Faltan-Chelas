//
//  ResumeViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 19/06/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire

class ResumeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    
    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    var selectedPaymethod:PaymethodModel!;
    var Products:Array<ProductModel> = [];
    var Paymethods:Array<PaymethodModel> = [];
    var ExtraCharge = 0.0;
    var ActualLocation = Loc();
    let DELEGATE = UIApplication.shared.delegate as! AppDelegate;
    let Save = UserDefaults.standard;

    var lastIndexPath = -1;

    let HeightForProductCell = 45.0;
    let HeightForPaymethodCell = 45.0;
    let HeightForHeader = 50.0;
    let TopScroll = 100.0;
    var TotalOrder = 0.0;
    
    @IBOutlet weak var MainScrollView: UIScrollView!
    @IBOutlet weak var ProductsTableView: UITableView!
    @IBOutlet weak var TotalView: UIView!
    @IBOutlet weak var PaymethodsTableView: UITableView!
    @IBOutlet weak var DetailInfoView: UIView!
    @IBOutlet weak var DetailInfoTextView: UITextView!
    @IBOutlet weak var SubtotalLabel: UILabel!
    @IBOutlet weak var ExtraChargeLabel: UILabel!
    @IBOutlet weak var TotalLabel: UILabel!
    @IBOutlet weak var MainView: UIView!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var AddPaydataButton: UIView!

    @IBOutlet weak var MainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var MainViewEqualHeight: NSLayoutConstraint!
    @IBOutlet weak var PaymethodsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ProductsTableViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "ResumeTableViewCell", bundle: nil);
        self.ProductsTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        self.ProductsTableView.allowsSelection = false;
        self.ProductsTableView.isUserInteractionEnabled = false;
        
        let nibPay = UINib(nibName: "PaydataTableViewCell", bundle: nil);
        self.PaymethodsTableView.register(nibPay, forCellReuseIdentifier: "CustomCellPay");
        self.PaymethodsTableView.isScrollEnabled = false;
        
        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NotificationCenter.default.addObserver(self, selector: #selector(ResumeViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.ProductsTableView.reloadData();
        self.reloadData();
        self.reloadPricesLabels();
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
            
            Alamofire.request(AuthUrl, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        
                        self.Paymethods = [];
                        self.lastIndexPath = -1;
                        self.selectedPaymethod = nil;
                        
                        for (_,card):(String,JSON) in data["cards"] {
                            
                            var tmp:PaymethodModel = PaymethodModel();
                            
                            tmp.tokenization = card["id"].stringValue;
                            tmp.termination = card["last4"].stringValue;
                            tmp.brand = card["brand"].stringValue;
                            
                            self.Paymethods.append(tmp);
                        }
                        print("METODOS DE PAGO: \(self.Paymethods.count)");
                        self.PaymethodsTableView.reloadData();
                        self.resizeTableViews();
                        
                        let ConfigUrl = self.ApiUrl + "/config";
                        Alamofire.request(ConfigUrl,encoding: JSONEncoding.default,headers: headers).responseJSON { response in
                            
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
            //No internet connection:
            self.alerta("Error", Mensaje: "Favor de conectarse a internet");
        }
        
    }

    
    func resizeTableViews(){
    
        let sizeCells = Double(self.Products.count) * self.HeightForProductCell + HeightForHeader;
        self.ProductsTableViewHeight.constant = CGFloat(sizeCells);
        
        let sizeCellsPay = Double(self.Paymethods.count) * self.HeightForPaymethodCell + HeightForHeader;
        self.PaymethodsTableViewHeight.constant = CGFloat(sizeCellsPay);
        
        addBorderUtility(x: 0, y: CGFloat(sizeCells - 1)  , width: self.ProductsTableView.frame.width, height: 1, color: UIColor(hexString: "FAE804"));
        addBorderUtility(x: 0, y: 0  , width: self.ProductsTableView.frame.width, height: 1, color: UIColor(hexString: "FAE804"));
        
//        addBorderUtilityPay(x: 0, y: CGFloat(sizeCellsPay) - 1, width: self.PaymethodsTableView.frame.width, height: 1, color: UIColor(hexString: "FAE804"));
        let borderPaydata = CALayer();
        borderPaydata.backgroundColor = UIColor(hexString: "FAE804").cgColor;
        borderPaydata.frame = CGRect(x: 0, y: self.AddPaydataButton.frame.height, width: self.AddPaydataButton.frame.width, height: 1);
        self.AddPaydataButton.layer.addSublayer(borderPaydata);
        
        addBorderUtilityPay(x: 0, y: 0  , width: self.PaymethodsTableView.frame.width, height: 1, color: UIColor(hexString: "FAE804"));

        
        let totalViewHeightSize = CGFloat(sizeCells) + CGFloat(sizeCellsPay) + self.TotalView.frame.height + self.DetailInfoView.frame.height + CGFloat(self.AddPaydataButton.frame.height);
        
        self.MainScrollView.contentSize = CGSize(width: self.MainScrollView.frame.width, height: totalViewHeightSize);
        let difference = totalViewHeightSize - self.MainScrollView.frame.height;
        self.MainViewEqualHeight.constant = difference;
    }
    
    func addBorderUtility(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        self.ProductsTableView.layer.addSublayer(border)
    }
    
    func addBorderUtilityPay(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        self.PaymethodsTableView.layer.addSublayer(border)
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.tag == 0){
            return self.Products.count;
        }else if(tableView.tag == 1){
            return self.Paymethods.count;
        }
        return 0;
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
        
        let Title = UILabel(frame: CGRect(x: 0, y: 5, width: 100, height: 30));
        if (tableView.tag == 0){
            Title.text = "      TU PEDIDO";
        }else{
            Title.text = "      METODO DE PAGO";
        }
        Title.textColor = UIColor.black;
        Title.font = UIFont(name: "Nexa Bold", size: 15);
        
        return Title;
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (tableView.tag == 0){
            return CGFloat(self.HeightForProductCell);
        }else if(tableView.tag == 1){
            return CGFloat(self.HeightForPaymethodCell);
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView.tag == 0){
            let cell:ResumeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! ResumeTableViewCell;
            
            var Product = self.Products[(indexPath as NSIndexPath).row];
            cell.DenominationLabel.text = Product.denomination;
            if Product.prices.count > 0 {
                cell.PriceLabel.text = "$\(Product.prices[0].price)";
                if(Product.prices[0].quantity == 6) {
                    cell.QuantityLabel.text = "\(Product.counter) six";
                }else {
                    cell.QuantityLabel.text = "\(Product.counter * Product.prices[0].quantity) piezas";
                }
            }
            
            return cell
        }else if(tableView.tag == 1){
            
            let cell:PaydataTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCellPay", for: indexPath) as! PaydataTableViewCell;
            
            if(self.lastIndexPath == (indexPath as NSIndexPath).row){
                cell.CheckmarkImageView.isHidden = false;
            }else{
                cell.CheckmarkImageView.isHidden = true;
            }
            
            cell.TerminationLabel.text = "**** **** **** \(self.Paymethods[(indexPath as NSIndexPath).row].termination)";
            cell.IconImageView.image = UIImage(named: "\(self.Paymethods[(indexPath as NSIndexPath).row].brand).png");
            
            return cell;

        }
        
        
        return UITableViewCell();
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedPaymethod = self.Paymethods[(indexPath as NSIndexPath).row];
        self.lastIndexPath = (indexPath as NSIndexPath).row;
        self.PaymethodsTableView.reloadData();
    }
    
    func keyboardWillShow(_ notification:Notification){
        
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.DismissKeyboard))
        view.addGestureRecognizer(tap);
        
        let userInfo:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height;
        
        let screenSize: CGRect = UIScreen.main.bounds;
        _ = screenSize.height - keyboardHeight;
        
        let size = self.MainScrollView.contentSize.height - keyboardHeight;
        self.MainScrollView.setContentOffset(CGPoint(x: 0, y: size), animated: true);
        
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
        self.DetailInfoTextView.resignFirstResponder();
    }
    
    func reloadPricesLabels(){
        
        var sum = 0.0;
        for product in self.Products {
            if product.prices.count > 0 {
                sum += (product.prices[0].price) * Double(product.counter);
            }
        }
        
        self.SubtotalLabel.text = "$\(sum)";
        self.ExtraChargeLabel.text = "$\(self.ExtraCharge)";
        self.TotalOrder = sum + self.ExtraCharge;
        self.TotalLabel.text = "$\(TotalOrder)";
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
    
    @IBAction func OrderAction(_ sender: AnyObject) {
        if(self.selectedPaymethod != nil){
            
            var DataToSend: Parameters =  Parameters();
            
            DataToSend["user_id"] = self.UsuarioEnSesion._id as AnyObject!;
            
            var products : [[String: AnyObject]]! = [];
            for (_, product) in self.Products.enumerated() {
                var tmp =  [String: AnyObject]();
                tmp["denomination"] = product.denomination as AnyObject?;
                tmp["price"] = product.prices[0].price as AnyObject?;
                tmp["quantity"] = product.prices[0].quantity as AnyObject?;
                tmp["units"] = product.counter as AnyObject?;
                products.append(tmp);
            }
            DataToSend["products"] = products as AnyObject?;
            DataToSend["total"] = self.TotalOrder as AnyObject!;
            
            var destinyDict =  [String: AnyObject]();
            destinyDict["denomination"] = self.ActualLocation.address as AnyObject!;
            destinyDict["lat"] = self.ActualLocation.lat as AnyObject!;
            destinyDict["long"] = self.ActualLocation.long as AnyObject!;
            DataToSend["destiny"] = destinyDict as AnyObject?;
            
            if (self.DetailInfoTextView.text != "") {
                DataToSend["aditionalInfo"] = self.DetailInfoTextView.text as AnyObject!;
            }
            
            DataToSend["paymethod"] = self.selectedPaymethod.tokenization as AnyObject!;
            
            DismissKeyboard();
            SwiftSpinner.show("Enviando Solicitud");
            let AuthUrl = ApiUrl + "/order";
            let headers: HTTPHeaders = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            
            let status = Reach().connectionStatus();
            switch status {
            case .online(.wwan), .online(.wiFi):
                
                Alamofire.request(AuthUrl, method: .post, parameters: DataToSend, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                    
                    if response.result.isSuccess {
                        
                        let data = JSON(data: response.data!);
                        print(data);
                        if(data["success"].boolValue == true){
                            
                            SwiftSpinner.hide();
                            // self.alerta("Correcto", Mensaje: data["message"].stringValue );
                            
                            self.Save.set(true, forKey: "NotifiedNotAccepted");
                            
                            SocketIOManager.sharedInstance.RequestOrder(data["order"]["_id"].stringValue, user_id: self.UsuarioEnSesion._id);
                            let _ = self.navigationController?.popToRootViewController(animated: true);
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
            self.alerta("Oops!", Mensaje: "Selecciona algún método de pago");
        }
    }
    

}
