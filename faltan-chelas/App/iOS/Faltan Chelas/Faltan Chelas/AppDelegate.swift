//
//  AppDelegate.swift
//  Faltan Chelas
//
//  Created by Jose De Jesus Garfias Lopez on 21/05/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import AirshipKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var hasPushOrder = false;
    var Order = "";
    var isInitial = true;

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        GMSServices.provideAPIKey(VARS().getGoogleKey());
        GMSPlacesClient.provideAPIKey(VARS().getGoogleKey());

        
        let config = UAConfig.default();
        config.developmentLogLevel = UALogLevel.none;

        UAirship.takeOff(config);
        UAirship.push().userPushNotificationsEnabled = true;
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
//        if((userInfo["order_id"]) != nil){
//            if(application.applicationState == UIApplicationState.active) {
//            }else if(application.applicationState == UIApplicationState.background){
//                self.hasPushOrder = true;
//                self.Order = userInfo["order_id"] as! String;
//            }else if(application.applicationState == UIApplicationState.inactive){
//                self.hasPushOrder = true;
//                self.Order = userInfo["order_id"] as! String;
//            }
//        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        SocketIOManager.sharedInstance.closeConnection();
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if(Session()._id != ""){
            SocketIOManager.sharedInstance.establishConnection();
        }else{
        }

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

