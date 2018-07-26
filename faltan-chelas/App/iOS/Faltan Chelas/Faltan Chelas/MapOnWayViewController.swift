//
//  MapOnWayViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 26/06/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire
import SwiftyJSON
import MessageUI
import SwiftSpinner


class MapOnWayViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, MFMessageComposeViewControllerDelegate {
    
    var Order:OrderModel!;
    var UsuarioEnSesion:Session = Session();
    var ActualLocation = Loc();
    var MarkersArray:Array<GMSMarker> = [];
    var clickedOrder = false;

    let DELEGATE = UIApplication.shared.delegate as! AppDelegate;
    let locationManager = CLLocationManager();
    
    var deliveredOrder = false;

    @IBOutlet weak var MapView: GMSMapView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var AddressLabel: UILabel!
    @IBOutlet weak var ObervationsLabel: UILabel!
    @IBOutlet weak var RankLabel: UILabel!
    @IBOutlet weak var CallView: UIView!
    @IBOutlet weak var SmsView: UIView!
    @IBOutlet weak var DeliverView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //LOCATION SETTINGS:
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
        
        //MAPVIEW SETTINGS
        MapView.delegate = self;
        MapView.isMyLocationEnabled = true
        MapView.settings.myLocationButton = true;
        MapView.isTrafficEnabled = false;

        self.DrawMarker(self.Order.destiny.lat, Long: self.Order.destiny.long, title: self.Order.vendor_id.name);
        // Do any additional setup after loading the view.
        
        self.NameLabel.text = self.Order.user_id.name;
        self.AddressLabel.text = self.Order.destiny.address;
        self.RankLabel.text = String(format: "%.1f", self.Order.user_id.rate);
        self.ObervationsLabel.text = self.Order.aditionalInfo;
        
        self.SmsView.layer.borderColor = UIColor.white.cgColor;
        self.SmsView.layer.borderWidth = 1.0;
        self.CallView.layer.borderColor = UIColor.white.cgColor;
        self.CallView.layer.borderWidth = 1.0;
        self.DeliverView.layer.borderColor = UIColor.white.cgColor;
        self.DeliverView.layer.borderWidth = 1.0;
    

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.deliveredOrder = false;
    }
    func drawMap(){
        let  position = CLLocationCoordinate2DMake(self.ActualLocation.lat, self.ActualLocation.long);
        let marker = GMSMarker(position: position);
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.title = title;
        marker.isFlat = true;
        self.MarkersArray.append(marker);
        
        self.addOverlayToMapView();
        self.FocusMapOnAllMarkers();
    }
    func DrawMarker(_ Lat:Double, Long: Double, title:String) {
        let  position = CLLocationCoordinate2DMake(Lat, Long);
        let marker = GMSMarker(position: position);
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.title = title;
        marker.isFlat = true;
        marker.map = self.MapView;
        self.MarkersArray.append(marker);
    }
    
    func FocusMapOnAllMarkers() {
        
        var bounds = GMSCoordinateBounds(coordinate: MarkersArray[0].position, coordinate: MarkersArray[0].position);
        for marker in self.MarkersArray {
            bounds = bounds.includingCoordinate(marker.position);
        }
        let Camera  = GMSCameraUpdate.fit(bounds, withPadding: 20.0);
        self.MapView.animate(with: Camera);
        
    }

    func addPolyLineWithEncodedStringInMap(_ encodedString: String) {
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyLine = GMSPolyline(path: path)
        polyLine.strokeWidth = 5
        polyLine.strokeColor = UIColor.yellow
        polyLine.map = self.MapView;
    }
    
    func addOverlayToMapView(){
        
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.ActualLocation.lat),\(self.ActualLocation.long)&destination=\(self.Order.destiny.lat),\(self.Order.destiny.long)&key=\(VARS().getGoogleKey())";
        
        Alamofire.request(directionURL, parameters: nil).responseJSON { response in
            if response.result.isSuccess {
                let json = JSON(response.data!)
                let errornum = json["error"]
                if (errornum == true){
                }else{
                    let routes = json["routes"].array
                    
                    if routes != nil{
                        if (routes?.count)! > 0 {
                            let overViewPolyLine = routes![0]["overview_polyline"]["points"].string
                            if overViewPolyLine != nil{
                                self.addPolyLineWithEncodedStringInMap(overViewPolyLine!)
                            }
                        }
                    }
                }
            }else{
                print("Failure");
            }
        }
        
    }
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        DispatchQueue.main.async { () -> Void in
            let Camera  = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 15);
            self.MapView.camera = Camera;
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation();
            MapView.isMyLocationEnabled = true
            MapView.settings.myLocationButton = true
        }
    }
    
    // if the users is moving of something like that.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.ActualLocation.lat = locations.first!.coordinate.latitude;
        self.ActualLocation.long = locations.first!.coordinate.longitude;
        self.drawMap();
        locationManager.stopUpdatingLocation();

    }
    
    @IBAction func CallAction(_ sender: AnyObject) {
        let phoneNumber: String = "telprompt://" + self.Order.user_id.phone;
        UIApplication.shared.openURL(URL(string:phoneNumber)!);
        
    }

    @IBAction func SmsAction(_ sender: AnyObject) {
        let messageVC = MFMessageComposeViewController();
        messageVC.body = "Hola \(self.Order.user_id.name), ya estoy en camino a tu domicilio.";
        messageVC.recipients = [self.Order.user_id.phone];
        messageVC.messageComposeDelegate = self;
        self.present(messageVC, animated: false, completion: nil);
    }
    
    @IBAction func CancelOrder(_ sender: Any) {
        
        if(self.clickedOrder == false){
            self.clickedOrder = true;
            SocketIOManager.sharedInstance.SendState(self.Order._id, user_id: self.UsuarioEnSesion._id, state: "CancelOrder");
        }
        
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case MessageComposeResult.cancelled:
            print("Message was cancelled");
            self.dismiss(animated: true, completion: nil);
        case MessageComposeResult.failed:
            print("Message failed");
            self.dismiss(animated: true, completion: nil);
        case MessageComposeResult.sent:
            print("Message was sent");
            self.dismiss(animated: true, completion: nil);
        }
    }
    
    @IBAction func DeliverAction(_ sender: AnyObject) {
        if(self.deliveredOrder == false){
            self.deliveredOrder = true;
            SocketIOManager.sharedInstance.SendState(self.Order._id, user_id: self.UsuarioEnSesion._id, state: "DeliverOrder");
            SwiftSpinner.show("Procesando Pago");
        }
    }

}
