//
//  OrderMapViewController.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 24/05/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import SwiftSpinner
import Alamofire
import SwiftyJSON

class OrderMapViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, GMSMapViewDelegate, LocateOnTheMap {
    
    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    var NearVendors: Array<Loc> = [];
    var Markers: Array<GMSMarker> = [];
    
    let locationManager = CLLocationManager();
    var searchResultController:SearchResultsController!
    var resultsArray = [String]();
    var ActualLocation = Loc();
    var isSearchingOrigin = false;
    var isManualAddress = false;
    var isLoadingVendors = false;
    var clickedOrder = false;
    var TimerForGetOp = Foundation.Timer();

    
    @IBOutlet weak var MapView: GMSMapView!
    @IBOutlet weak var OriginLabel: UILabel!
    @IBOutlet weak var DestinyLabel: UILabel!
    @IBOutlet weak var LabelView: UIView!
    
    @IBOutlet weak var OrderLabel: UILabel!
    @IBOutlet weak var ArrowImageView: UIImageView!
    @IBOutlet weak var OrderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //LOCATION SETTINGS:
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
        
        //MAPVIEW SETTINGS
        MapView.delegate = self
        MapView.isMyLocationEnabled = true
        MapView.settings.myLocationButton = true;
        
        //LOCATION SETTINGS:
        searchResultController = SearchResultsController();
        searchResultController.delegate = self
        
        SwiftSpinner.show("Localizando repartidores");
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.clickedOrder = false;
    }

    func presentSearchController(_ placeholder:String){
    
        let searchController = UISearchController(searchResultsController: searchResultController);
        searchController.searchBar.sizeToFit();
        searchController.hidesNavigationBarDuringPresentation = false;
        searchController.searchBar.placeholder = placeholder;
        searchController.searchBar.delegate = self;
        self.present(searchController, animated: true, completion: nil);

    }
    
    
    func loadNearVendors(){
        if(!isLoadingVendors){
            self.isLoadingVendors = true;
            print(self.ActualLocation);
            let AuthUrl = ApiUrl + "/users/byavailablevendors/bylocation/\(self.ActualLocation.lat)/\(self.ActualLocation.long)";
            let status = Reach().connectionStatus();
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            switch status {
            case .online(.wwan), .online(.wiFi):
                Alamofire.request(AuthUrl, encoding: JSONEncoding.default,headers: headers).responseJSON { response in
                    
                    if response.result.isSuccess{
                        let data = JSON(data: response.data!);
                        if(data["success"] == true){
                            self.NearVendors = [];
                            
                            for (_,vendor):(String,JSON) in data["vendors"] {
                                
                                var tmp:Loc = Loc();
                                
                                tmp.long = vendor["loc"]["cord"][0].doubleValue;
                                tmp.lat = vendor["loc"]["cord"][1].doubleValue;
                                tmp.address = vendor["marketname"].stringValue;
                                
                                self.NearVendors.append(tmp);
                            }
                            self.isLoadingVendors = false;
                            self.DrawOnMapViewVendors();
                        }else{
                            print(data);
                            self.alerta("Error de sesión", Mensaje: data["message"].stringValue );
                            SwiftSpinner.hide();
                        }
                    }else{
                        print(response);
                        self.alerta("Error", Mensaje: (response.result.error?.localizedDescription)!);
                        SwiftSpinner.hide();

                    }
                }
            case .unknown, .offline:
                //No internet connection:
                self.alerta("Error", Mensaje: "Favor de conectarse a internet");
                SwiftSpinner.hide();
            }
        }
    }
    
    func DrawOnMapViewVendors(){
        
        self.MapView.clear();

        if self.NearVendors.count > 0{
            self.OrderLabel.text = "QUIERO CHELAS";
            self.OrderButton.isUserInteractionEnabled = true;
            self.ArrowImageView.isHidden = false;

            for m in self.Markers {
                m.map = nil;
            }
            self.Markers = [];
            
            for vendor in self.NearVendors {
                let  position = CLLocationCoordinate2DMake(vendor.lat, vendor.long);
                let marker = GMSMarker(position: position);
                //marker.appearAnimation = kGMSMarkerAnimationPop;
                marker.icon = UIImage(named: "BeerMapLoc.png");
                marker.title = vendor.address;
                marker.map = self.MapView;
                self.Markers.append(marker);
            }
            if self.Markers.count > 0 {
                self.MapView.selectedMarker = self.Markers[0];
            }
            SwiftSpinner.hide();

        }else{
            SwiftSpinner.hide();
            self.alerta("En la m...", Mensaje: "Por el momento no hay repartidores activos en tu zona. Danos chance estamos empezando...");
            self.OrderLabel.text = "SIN SERVICIO";
            self.OrderButton.isUserInteractionEnabled = false;
            self.ArrowImageView.isHidden = true;
        }
    }
    
    
    @IBAction func SearchOrigin(_ sender: AnyObject) {
        self.isSearchingOrigin = true;
        self.presentSearchController(self.ActualLocation.address);
    }
    
    @IBAction func SearchDestiny(_ sender: AnyObject) {
        isSearchingOrigin = false;
        self.presentSearchController("Direccion de destino")
    }
    
    @IBAction func Order(_ sender: AnyObject) {
        if(self.clickedOrder == false){
            self.clickedOrder = true;
            if let parent = self.parent as? StatusViewController {
                if(ActualLocation.address != "") {
                    parent.ActualLocation = self.ActualLocation;
                    parent.performSegue(withIdentifier: "MenuChelasSegue", sender: parent);
                }else{
                    self.alerta("Oops!", Mensaje: "Selecciona una ubicación válida.");
                }

            }
        }
    }

    ///*****/////******/////////*****/////******/////////*****/////******/////////*****/////******//////
    /// LOCATION MANAGER METHODS:
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation();
            MapView.isMyLocationEnabled = true
            MapView.settings.myLocationButton = true
        }
    }
    
    // if the users is moving of something like that.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        MapView.camera = GMSCameraPosition(target: locations.last!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0);
        locationManager.stopUpdatingLocation();
        geoCode(locations.first!);
    }
    
    ///*****/////******/////////*****/////******/////////*****/////******/////////*****/////******//////
    //SEARCH BAR METHODS
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let lat = self.ActualLocation.lat;
        let long = self.ActualLocation.long;
        
        let offset = 200.0 / 1000.0;
        let latMax = lat + offset;
        let latMin = lat - offset;
        let lngOffset = offset * cos(lat * M_PI / 200.0);
        let lngMax = long + lngOffset;
        let lngMin = long - lngOffset;
        let initialLocation = CLLocationCoordinate2D(latitude: latMax, longitude: lngMax)
        let otherLocation = CLLocationCoordinate2D(latitude: latMin, longitude: lngMin)

        let placesClient = GMSPlacesClient();
        let Filter = GMSAutocompleteFilter();
        let Bounds = GMSCoordinateBounds(coordinate: initialLocation, coordinate: otherLocation)

        Filter.type = .address
        Filter.country = "MX";
        
        
        placesClient.autocompleteQuery(searchText, bounds: Bounds, filter: Filter, callback: { (results, error) -> Void in
            self.resultsArray.removeAll();
            if results == nil {
                return
            }
            for result in results!{
                self.resultsArray.append(result.attributedFullText.string);
            }
            self.searchResultController.reloadDataWithArray(self.resultsArray)
        });
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.LabelView.isHidden = true;
        
        return true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.LabelView.isHidden = false;
    }
    
    func changeManualStatus(_ status: Bool) {
        self.isManualAddress = status;
        
        
        self.TimerForGetOp = Foundation.Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(OrderMapViewController.loadNearVendors), userInfo: nil, repeats: false);
        RunLoop.main.add(self.TimerForGetOp, forMode: RunLoopMode.commonModes);
        
    }
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        self.OriginLabel.text = title;
        self.ActualLocation.lat = lat;
        self.ActualLocation.long = lon;
        self.ActualLocation.address = title;
        
        DispatchQueue.main.async { () -> Void in
            let Camera  = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 19);
            self.MapView.camera = Camera;
        }
    }
    
    ///*****/////******/////////*****/////******/////////*****/////******/////////*****/////******/////////*****/////******//////
    
    func geoCode(_ location : CLLocation!){
        /* Only one reverse geocoding can be in progress at a time hence we need to cancel existing
         one if we are getting location updates */
        let url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(location.coordinate.latitude),\(location.coordinate.longitude)&sensor=false&key=\(VARS().getGoogleKey())";
        Alamofire.request(url, encoding: JSONEncoding.default).responseJSON { response in
            if response.result.isSuccess{
                let data = JSON(data: response.data!);
                let address = data["results"][0]["formatted_address"].stringValue;
                self.OriginLabel.text = address;
                self.ActualLocation.long = location.coordinate.longitude;
                self.ActualLocation.lat = location.coordinate.latitude;
                self.ActualLocation.address = address;
                
                self.TimerForGetOp = Foundation.Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(OrderMapViewController.loadNearVendors), userInfo: nil, repeats: false);
                RunLoop.main.add(self.TimerForGetOp, forMode: RunLoopMode.commonModes);

                
            }else{
                self.alerta("Error", Mensaje: (response.result.error?.localizedDescription)!);
            }
        }
    }
    
    ///*****/////******/////////*****/////******/////////*****/////******/////////*****/////******/////////*****/////******//////
    /// GOOGLE MAPS MANAGER METHODS:
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if(!isManualAddress){
            let newLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude);
            geoCode(newLocation);
        }
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if (gesture) {
            self.isManualAddress = false;
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        return nil
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.selectedMarker = nil
        return false
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
}
