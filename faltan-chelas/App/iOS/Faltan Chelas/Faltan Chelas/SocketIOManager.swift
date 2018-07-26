
//
//  State.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 03/04/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//
import UIKit
import Foundation
import SocketIO
import SwiftyJSON
import SwiftSpinner

class SocketIOManager: NSObject {
    let socket = SocketIOClient(socketURL: URL(string: VARS().getApiUrl())!, config: [.log(false), .forcePolling(true)])
    static let sharedInstance = SocketIOManager();
    var actualState:String = "NO_INITIALIZED";
    var beforeState:String = "NO_INITIALIZED";
    var delegate:StatusViewController!;
    var reconnectTimer:Timer!;
    let DELEGATE = UIApplication.shared.delegate as! AppDelegate;

    var Info: JSON =  [ "user_id": Session()._id,
                        "name": Session().name,
                        "email": Session().email,
                        "typeuser": Session().typeuser,
                        "device": "Iphone"
                    ];
    
    override init() {
        super.init();
        self.listenActions();
    }
    
    func establishConnection() {
        
        // retreive new session user:
        self.Info =  [ "user_id": Session()._id,
                            "name": Session().name,
                            "email": Session().email,
                            "typeuser": Session().typeuser,
                            "device": "Iphone"
        ];
        socket.connect();
    }

    func closeConnection() {
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            socket.disconnect();
        case .unknown, .offline:
            break;
        }
    }
    
    fileprivate func listenActions() {
        socket.on("HowYouAre") {data, ack in
            if (Session().typeuser != "") {
                self.socket.emit("ConnectedUser",self.Info.object as! SocketData);
            }
        }
        socket.on("disconnect") {data, ack in
            print("DISCONNECTED DEVICE FROM SOCKET");
        }
        socket.on("UpdateOrder") {data, ack in
            if ((data[0] as? NSDictionary) != nil) {
                let json = JSON(data[0]);
                let Req = OrderModel(data: json);
                print(Req);
                self.ChangeState(Req);
            }else{
                print("NO DATA");
                self.delegate.normalLoad();
            }

        }
    }

    func GetLastOrder(_ type:String,user_id:String,state:String){
        let Data: JSON =  ["type":type,"user_id":user_id];
        self.socket.emit(state,Data.object as! SocketData);
    }
    func SendState(_ order_id:String,user_id:String,state:String){
        let Data: JSON =  ["order_id":order_id,"user_id":user_id];
        print(Data);
        self.socket.emit(state,Data.object as! SocketData);
    }
    func RequestOrder(_ order_id:String,user_id:String){
        let Data: JSON =  ["order_id":order_id,"user_id":user_id];
        self.socket.emit("SearchForVendor",Data.object as! SocketData);
    }
    func AcceptOrder(_ order_id:String,user_id:String){
        let Data: JSON =  ["order_id":order_id,"user_id":user_id];
        self.socket.emit("AcceptOrder",Data.object as! SocketData);
    }
    func ChangeState(_ Data:OrderModel){
        self.beforeState = self.actualState;
        self.actualState = Data.status;
        self.delegate.reloadWithOrder(Data);
    }
}
