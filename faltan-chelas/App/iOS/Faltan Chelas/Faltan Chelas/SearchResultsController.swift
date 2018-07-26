//
//  SearchResultsController.swift
//  PlacesLookup
//
//  Created by Malek T. on 9/30/15.
//  Copyright © 2015 Medigarage Studios LTD. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol LocateOnTheMap{
    func locateWithLongitude(_ lon:Double, andLatitude lat:Double, andTitle title: String);
    func changeManualStatus(_ status:Bool);
    
}

class SearchResultsController: UITableViewController {

    var searchResults: [String]!
    var delegate: LocateOnTheMap!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchResults = Array()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        
        cell.textLabel?.text = self.searchResults[(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
            // 1
            self.dismiss(animated: true, completion: nil)
            // 2
        let correctedAddress:String = self.searchResults[indexPath.row].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!;
        
        let string = "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddress)&sensor=false&key=\(VARS().getGoogleKey())";
        
        Alamofire.request(string).responseJSON { response in
            if response.result.isSuccess {
                let json = JSON(data: response.data!);
                let result = json["results"][0];
                let address = result["formatted_address"].stringValue;
                let lat = result["geometry"]["location"]["lat"].doubleValue;
                let lon = result["geometry"]["location"]["lng"].doubleValue;
                self.delegate.locateWithLongitude(lon, andLatitude: lat, andTitle: address);
                self.delegate.changeManualStatus(true);

            }else{
                print("Error")
            }
        }
    }
    
    
    func reloadDataWithArray(_ array:[String]){
        self.searchResults = array
        self.tableView.reloadData()
    }

}
