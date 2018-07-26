//
//  Variables.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 21/12/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class VARS {
    
    func getApiUrl() -> String{
      
      // Server Production:
      return "http://104.131.24.52:3000";
      
      //LocalHost
      // return "http://10.10.10.2:3000";
   
   }
   
   func getConektaPublicKey() -> String {
      
      // Development
      //return "key_Guc4wPea72sjMdKVMxNbrAQ";
      
      // Produccion:
      return "key_TVZiTMVsZmfMzNLjsy1T9Yw";
   }
   
   func getGoogleKey() -> String {
      return "AIzaSyA1eQddKKkPYFS_L5PnAkdqLNhOxfX6SA4";
   }

}

struct Loc {
    var address:String = "";
    var long:Double = 0.0;
    var lat:Double = 0.0;
}

struct Session {
    
    var _id:String = "";
    var token:String = "";
    var phone:String = "";
    var name:String = "";
    var email:String = "";
    var typeuser:String = "";
    
    init(){
        
        if let UsuarioRecover = UserDefaults.standard.dictionary(forKey: "UsuarioEnSesion") {
            
            if let value = UsuarioRecover["_id"] as? NSString {
                _id = value as String;
            }
            if let value = UsuarioRecover["token"] as? NSString {
                token = value as String;
            }
            if let value = UsuarioRecover["phone"] as? NSString {
                phone = value as String;
            }
            if let value = UsuarioRecover["name"] as? NSString {
                name = value as String;
            }
            if let value = UsuarioRecover["email"] as? NSString {
                email = value as String;
            }
            if let value = UsuarioRecover["typeuser"] as? NSString {
                typeuser = value as String;
            }
        }
        
    }
}

struct PriceModel {
    var quantity:Int = 0;
    var price:Double = 0.0;

}

struct ProductModel {
    var denomination:String = "";
    var type:String = "";
    var description:String = "";
    var prices:Array<PriceModel> = [];
    var counter: Int = 0;
}

struct ProductOrderModel {
   var denomination:String = "";
   var price:Double = 0.0;
   var quantity: Int = 0;
   var units: Int = 0;
}

struct PaymethodModel {
   var tokenization:String = "";
   var termination:String = "";
   var brand:String = "";
}

struct RequestModel {
    var origin:Loc = Loc();
    var user:Session = Session();
    var date:String = "";
    var isSchedule:Bool = false;
}

struct OrderModel {
    
    var _id:String = "";
    var order_id:String = "";
    var destiny:Loc = Loc();
    var user_id:UserTemplate = UserTemplate();
    var vendor_id:UserTemplate = UserTemplate();
    var products:Array<ProductOrderModel> = [];
    var total: Double = 0.0
    var date: String = "";
    var status: String = "Nothing";
    var isPaid: Bool = false;
    var aditionalInfo:String = "";

    init(){
    }
    
    init(data: JSON) {
        
      self._id = data["_id"].stringValue;
      self.total = data["total"].doubleValue;
      self.date = data["date"].stringValue;
      self.order_id = data["order_id"].stringValue;
      self.destiny = Loc(address: data["destiny"]["denomination"].stringValue,
                           long: data["destiny"]["cord"][0].doubleValue,
                           lat: data["destiny"]["cord"][1].doubleValue);
      self.status = data["status"].stringValue;
      self.aditionalInfo = data["aditionalInfo"].stringValue;
      
      self.status = data["status"].stringValue;
      self.isPaid = data["isPaid"].boolValue;
      self.user_id = UserTemplate(
            name: data["user_id"]["name"].stringValue,
            rate: data["user_id"]["rate"]["average"].doubleValue,
            phone: data["user_id"]["phone"].stringValue,
            _id: data["user_id"]["_id"].stringValue,
            typeuser: data["user_id"]["typeuser"].stringValue,
            marketname: "");
   
      self.vendor_id = UserTemplate(
            name: data["vendor_id"]["name"].stringValue,
            rate: data["vendor_id"]["rate"]["average"].doubleValue,
            phone: data["vendor_id"]["phone"].stringValue,
            _id: data["vendor_id"]["_id"].stringValue,
            typeuser: data["vendor_id"]["typeuser"].stringValue,
            marketname: data["vendor_id"]["marketname"].stringValue);
      
      for (_,product):(String,JSON) in data["products"] {
         
         var tmp:ProductOrderModel = ProductOrderModel();
         
         tmp.denomination = product["denomination"].stringValue;
         tmp.price = product["price"].doubleValue;
         tmp.quantity = product["quantity"].intValue;
         tmp.units = product["units"].intValue;
         
         self.products.append(tmp);
      }
      
      
    }
}

struct UserTemplate {
    var name:String = "";
    var rate:Double = 0.0;
    var phone:String = "";
    var _id:String = "";
    var typeuser:String = "";
   var marketname:String = "";
}

struct DashboardTemplate {
    var color:UIColor = UIColor.clear;
    var icon:String = "tickets.png";
    var total:String = "$0.0";
    var count:String = "0";
    var description:String = "Servicios";
}

