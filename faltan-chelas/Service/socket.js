var Config = require("./config/config");

var socketio = require('socket.io')();
var UserModel = require("./models/user");
var OrderModel = require("./models/order");
var async = require('async');
var _ = require('lodash');

var request = require('request');
var conekta = require('conekta');
conekta.api_key = Config.ConektaApiKey;
conekta.locale = 'es';

var ConnectedUsers = [];
var ConnectedVendors = [];
var ConnectedAdmins = [];
var ActualOrders = {};

function ConnectUser(NewUser){
	//añadir al arreglo
	if (NewUser.info.typeuser == 'vendor') {
		if(ConnectedVendors.indexOf(NewUser) == -1){
			ConnectedVendors.push(NewUser);
			NewUser.socket.join('vendors');
			console.log("connecting - Vendor");
		}
		GetLastOrderFromVendor(NewUser.info.user_id,function(Err, Order){
			NewUser.socket.emit('UpdateOrder',Order);
		});
	}else {
		if(ConnectedUsers.indexOf(NewUser) == -1){
			ConnectedUsers.push(NewUser);
			NewUser.socket.join('users');
			console.log("connecting - user");
		}
		GetLastOrderFromUser(NewUser.info.user_id,function(Err, Order){
			NewUser.socket.emit('UpdateOrder',Order);
		});
	}
}

function RemoveUser(NewUser){
	if (NewUser.info.typeuser == 'vendor') {
		console.log("disconnecting - vendor");
		var i = ConnectedVendors.indexOf(NewUser);
		ConnectedVendors.splice(i, 1);
		NewUser.socket.leave('vendors');
	} else {
		console.log("disconnecting - user");
		var i = ConnectedUsers.indexOf(NewUser);
		ConnectedUsers.splice(i, 1);
		NewUser.socket.leave('users');
	}
}

function ConnectAdmin(NewAdmin) {
	if(ConnectedAdmins.indexOf(NewAdmin) == -1){
		ConnectedAdmins.push(NewAdmin);
		NewAdmin.socket.join('admins');
	}
}

function RemoveAdmin(NewAdmin) {
	var i = ConnectedAdmins.indexOf(NewAdmin);
	ConnectedAdmins.splice(i, 1);
	NewAdmin.socket.leave('admins');
}

function GetUserConnected(UserId,callback){
	var counter = 0;
	ConnectedUsers.forEach(function(UserObject){
		if (UserObject.info.user_id == UserId) {
			callback(UserObject);
		}else{
			counter +=1;
			if(counter == ConnectedUsers.length){
				callback(null);
			}
		}
	});
}

function GetLastOrderFromUser(UserId,callback) {
	OrderModel.findOne({user_id:UserId})
				.sort({$natural:-1})
				.populate({ path: 'user_id', select: '_id name phone rate typeuser email push_id'})
				.populate({ path: 'vendor_id', select: '_id name phone rate typeuser email marketname push_id'})
				.exec(function(err,Order){
		if(err){
			console.log(err);
			callback('Algo salio mal');
		}
		callback(null,Order);
	});
}

function GetLastOrderFromVendor(VendorId,callback) {

	// here validate if that vendor is in the ActualOrders Notifications for send it her push order:
	var indexVendor = -1;
	var orderVendor = 0;
	_.forEach(ActualOrders, function(ActualOrder, OrderId) {
		indexVendor = _.findIndex(ActualOrder.foundedVendors, function(vendor){return vendor == VendorId});
		if (indexVendor != -1) {
			orderVendor = OrderId;
		}
	});
	if (orderVendor != 0) {
		OrderModel.findById(orderVendor)
					.populate({ path: 'user_id', select: '_id name phone rate typeuser email push_id'})
					.populate({ path: 'vendor_id', select: '_id name phone rate typeuser email marketname push_id'})
					.exec(function(err,Order){
			if(err){
				callback('Algo salio mal');
			}
			// Agregar al vendor al otro arreglo que asegura que vio la orden.
			ActualOrders[orderVendor].vendors.push(VendorId);
			// status OFF for getting a new order
			ConnectedVendors.forEach(function(VendorObject){
				if (VendorObject.info.user_id == VendorId) {
					VendorObject.available = false;
				}
			});

			callback(null,Order);
		});
	}else{
		OrderModel.findOne({vendor_id:VendorId})
					.sort({$natural:-1})
					.populate({ path: 'user_id', select: '_id name phone rate typeuser email push_id'})
					.populate({ path: 'vendor_id', select: '_id name phone rate typeuser email marketname push_id'})
					.exec(function(err,Order){
			if(err){
				callback('Algo salio mal');
			}
			callback(null,Order);
		});
	}
}

function ChangeOrderStatus(OrderId,NewOrder,callback){
	OrderModel.findById(OrderId)
				.populate({ path: 'user_id', select: '_id name phone rate typeuser email push_id'})
				.populate({ path: 'vendor_id', select: '_id name phone rate typeuser email marketname push_id'}).exec(function(err, Order) {
		if(err){
			callback({info:'Something wrong with getting user.',error: err});
		}
		if (Order.status === 'Normal' && NewOrder.status === 'Searching' 	|| 
			Order.status === 'Searching' && NewOrder.status === 'Accepted' 	||
			Order.status === 'Accepted' && NewOrder.status === 'Delivered'	||
			Order.status === 'Delivered' && NewOrder.status === 'Delivered' ||
			Order.status === 'Delivered' && NewOrder.status === 'Normal'	||
			Order.status === 'NotAccepted' && NewOrder.status === 'Normal'		){

				if(NewOrder.status){
					Order.status = NewOrder.status;
				}
				if(NewOrder.vendor_id){
					Order.vendor_id = NewOrder.vendor_id;
				}
				if(NewOrder.isPaid){
					Order.isPaid = NewOrder.isPaid;
				}
				if(NewOrder.transaction_id){
					Order.transaction_id = NewOrder.transaction_id;
				}
				Order.save(function(err){
					if(err){
						callback({info:'Error saving on db.'});
					}
					if(NewOrder.vendor_id){
						Order.populate({ path: 'vendor_id', select: '_id name phone rate typeuser email marketname push_id'},function(ErrPop){
							if(ErrPop){
								callback({info:'Error populating from db.'});
							}
							callback(null,Order);
						});
					}else{
						callback(null,Order);
					}
				});

		} else if(NewOrder.status == 'NotAccepted') {
			if(Order.status === 'Searching'){
				Order.status = 'NotAccepted';
				Order.save(function(err){
					if(err){
						callback({info:'Error saving on db.'});
					}
					callback(null,Order);
				});
			}else{
				callback({info:'La orden fue tomada por otro repartidor.'});
			}
		} else if(NewOrder.status == 'Canceled') {
			if(Order.status !== 'Normal'){
				Order.status = 'Canceled';
				Order.save(function(err){
					if(err){
						callback({info:'Error saving on db.'});
					}
					callback(null,Order);
				});
			}else{
				callback({info:'La orden fue cancelada.'});
			}
		} else {
			callback({info:'La orden fue cancelada.'});
		}

	});
}

function GetNearAndAvailableVendors(NearCoords, callback){
	var limit = Config.searchLimit;
	var maxDistance = Config.searchDistance;
	var queryLoc = {
		$near: {
			$geometry: {
				type:'Point',
				coordinates:NearCoords
			},
			$maxDistance:maxDistance
		}
	};
	UserModel.find({'loc.cord': queryLoc, 'available': true, 'typeuser': 'vendor'}).limit(limit).exec(function(err, vendors) {
  		if (err) {
			callback(null);
  		}
      	callback(vendors);
    });
}

function SendPNToUser(push_id,message,callback){
	var UrlToPush = "https://go.urbanairship.com/api/push";
	var Notification = {
		audience: {
			OR: [
				{ ios_channel:  push_id },
				{ android_channel: push_id }
			]
		},
		notification: {
			ios: {
				alert: message.body,
				extra: message.customData,
				sound: "default"
			},
			android: {
				alert: message.body,
				extra: message.customData,
				sound: "default"
			}
		},
    	device_types: "all"
	}
	var Headers = {
		'Accept': 'application/vnd.urbanairship+json; version=3',
		'Content-Type': 'application/json'
	}
	var Auth = {
		'user': Config.UrbanAppKey,
		'pass': Config.UrbanMasterSecret
	}
	request({method: 'POST', uri: UrlToPush, headers: Headers, auth: Auth, body: JSON.stringify(Notification) } , function(error, response, body) {
		if (error) {
			callback(null);
		}
    	callback(body);
	});
}

function MakePay(Order,callback){
	var ConektaProducts = [];
	Order.products.forEach(function(producto){
		var p = {
			name: producto.denomination,
			unit_price: Number(producto.price) * 100,
			quantity: Number(producto.units),
			description: 'Paquete de chelas.'
		}
		ConektaProducts.push(p);
	});
	var OrderCharge = {
		amount: Order.total * 100,
		currency: 'MXN',
		description: 'Pedido Faltan Chelas',
		card: Order.paymethod,
		details: {
			name: Order.user_id.name,
			email: Order.user_id.email.address,
			phone: Order.user_id.phone,
			line_items: ConektaProducts
		}
	}
	conekta.Charge.create(OrderCharge,function(ErrorCharge,Charge){
		if(ErrorCharge){
			callback({info:ErrorCharge.message_to_purchaser});
		}
		callback(null,Charge);
	});
}

exports.initialize = function(server){
	var io = socketio.listen(server);

	io.on('connection', function (MainSocket) {
		console.log('OnConnection');
		MainSocket.emit('HowYouAre');
		/////// CONNECTION HANDLER FUNCTIONS   /////////////
		MainSocket.on('ConnectedUser', function (data) {
			if(data.user_id != ''){
				var NewUser = { info: data, socket: MainSocket, available: true };
				ConnectUser(NewUser);
				MainSocket.on('disconnect', function() {
					console.log('DESCONECTADO');
					RemoveUser(NewUser);
				});
			}else{

			}
		});

		MainSocket.on('ConnectedAdmin', function (data) {
			if(data.user_id != ''){
				console.log("CONECTADO ADMIN");
				var NewAdmin = { info: data, socket: MainSocket, available: true  };
				ConnectAdmin(NewAdmin);
				MainSocket.on('disconnect', function() {
					console.log("DESCONECTADO ADMIN");
					RemoveAdmin(NewAdmin);
				});
			}
	  	});

		MainSocket.on('GetLastOrder', function (data) {
			if (data.type == 'vendor') {
				GetLastOrderFromVendor(data.user_id,function(Err, Order){
					MainSocket.emit('UpdateOrder',Order);
				});
			}else{
				GetLastOrderFromUser(data.user_id,function(Err, Order){
					MainSocket.emit('UpdateOrder',Order);
				});
			}

		});

		/////// OPERATIONAL FUNCTIONS   /////////////
		///////////////////////////////////////////////////////////////////////////////////////////
		MainSocket.on('SearchForVendor', function (data) {
			ChangeOrderStatus(data.order_id,{status:'Searching'},function(Error,Order){
			    if(Order){
					MainSocket.emit("UpdateOrder",Order);
					var cancelTimer;
					var Timer = setInterval(function searchVendors() {
						GetNearAndAvailableVendors(Order.destiny.cord,function(VendorsOnDb){
							if(VendorsOnDb != null && VendorsOnDb.length != 0){
								clearInterval(Timer);
								VendorsOnDb.forEach(function(VendorDB) {
									ActualOrders[data.order_id].foundedVendors.push(VendorDB._id);
									//Notify each vendor on notification push.
									const msg = {body:'Tienes un nuevo pedido.',customData:{order_id:data.order_id}};
									SendPNToUser(VendorDB.push_id,msg,function(response){
										if(response){
											console.log('notification sended');
										}
									});
									//Notify each vendor on socket connected
									ConnectedVendors.forEach(function(VendorObject){
										if (VendorObject.info.user_id == VendorDB._id && VendorObject.available == true) {
											//Add to the array of vendors on actual order
											ActualOrders[data.order_id].vendors.push(VendorObject.info.user_id);
											VendorObject.available = false;
											VendorObject.socket.emit("UpdateOrder",Order);
										}
									});
								});
							}else{
								console.log('NO VENDOR');
							}
						});
					},3000);
					cancelTimer = setTimeout(function(){
						ChangeOrderStatus(data.order_id,{status:'NotAccepted'},function(Error,OrderChanged){
							MainSocket.emit("UpdateOrder",OrderChanged);
						});
						clearInterval(Timer);
						ActualOrders[data.order_id].vendors.forEach(function(vendorid){
							//Compare if the vendor is connected:
							ConnectedVendors.forEach(function(VendorObject){
								if (VendorObject.info.user_id == vendorid) {
									var VendorOrder = Order;
									VendorOrder.status = "Normal";
									VendorObject.socket.emit("UpdateOrder",VendorOrder);
									VendorObject.available = true;
								}
							});
						});
						delete ActualOrders[data.order_id];
					},60000);
					ActualOrders[data.order_id] = {
						user_id: data.user_id,
						vendors: [],
						foundedVendors: [],
						status: 'Searching',
						timer: Timer,
						expiredTimer: cancelTimer
					}
				}else{
					console.log('NO ORDER');
				}
			});
		});
		MainSocket.on('AcceptOrder', function (data) {
			clearInterval(ActualOrders[data.order_id].timer);
			clearTimeout(ActualOrders[data.order_id].expiredTimer);
			ActualOrders[data.order_id].foundedVendors = [];
			var NewOrder = {status:'Accepted', vendor_id:data.user_id};
			ChangeOrderStatus(data.order_id,NewOrder,function(Err, Order){
				if(Order){
					ActualOrders[data.order_id].status = "Accepted";
					// set status of vendor on false DB
					UserModel.findById(data.user_id, function(err, User) {
						User.available = false;
						User.save();
					});
					//Notify vendor.
					MainSocket.emit('UpdateOrder',Order);
					//Notify User
					GetUserConnected(Order.user_id._id, function(UserSocket){
						UserSocket.socket.emit('UpdateOrder',Order);
					});
					//notify to other vendors that was notified with order before.
					ActualOrders[data.order_id].vendors.forEach(function(vendorid){
						//Compare if the vendor is connected:
						ConnectedVendors.forEach(function(VendorObject){
							if (VendorObject.info.user_id == vendorid) {
								var VendorOrder = Order;
								VendorOrder.status = "Normal";
								VendorObject.socket.emit("UpdateOrder",VendorOrder);
								VendorObject.available = true;
							}
						});
					});
				}
				if(Err){
					MainSocket.emit('ErrorOrder',Err);
				}
			});
		});

		// MainSocket.on('OpenOrder', function (data) {
		// 	//Add to the vendors array on order object
		// 	ActualOrders[data.order_id].vendors.push(data.user_id);
		// 	// status OFF for getting a new order
		// 	ConnectedVendors.forEach(function(VendorObject){
		// 		if (VendorObject.info.user_id == data.user_id) {
		// 			VendorObject.available = false;
		// 		}
		// 	});
		// });

		MainSocket.on('DeliverOrder', function (data) {
			UserModel.findById(data.user_id, function(err, User) {
				User.available = true;
				User.save();
			});
			var NewOrder = {status:'Delivered'};
			ChangeOrderStatus(data.order_id,NewOrder,function(Err, Order){
				if(Order){
					const msg = {body:'Tus chelas han llegado!',customData:{}};
					SendPNToUser(Order.user_id.push_id,msg,function(response){
						if(response){
							console.log('notification sended');
						}
					});
					var NewNewOrder = {};
					MakePay(Order,function(ErrorPay,Charge){
						if(Charge){
							NewNewOrder = {status:'Delivered', isPaid:true, transaction_id: Charge.id};
						}else{
							NewNewOrder = {status:'Delivered', isPaid:false};
						}
						ChangeOrderStatus(data.order_id,NewNewOrder,function(Err, Order){
							if(Order){
								MainSocket.emit('UpdateOrder',Order);
								GetUserConnected(Order.user_id._id, function(UserSocket){
									UserSocket.socket.emit('UpdateOrder',Order);
								});
							}
							if(Err){
								MainSocket.emit('ErrorOrder',Err);
							}
						});
					});
					delete ActualOrders[data.order_id];
				}
				if(Err){
					MainSocket.emit('ErrorOrder',Err);
				}
			});
		});

		MainSocket.on('RatedUser', function (data) {
			var NewOrder = {status:'Normal'};
			ChangeOrderStatus(data.order_id,NewOrder,function(Error,Order){
				if(Order){
					MainSocket.emit('UpdateOrder',Order);
				}
			});
		});

		MainSocket.on('CancelOrder', function (data) {
			console.log("ORDER CANCELED");
			if(ActualOrders[data.order_id]){
				if(ActualOrders[data.order_id].timer) {
					clearInterval(ActualOrders[data.order_id].timer);
				}
				if(ActualOrders[data.order_id].expiredTimer){
					clearTimeout(ActualOrders[data.order_id].expiredTimer);
				}
			}
			var NewOrder = {status:'Canceled'};
			ChangeOrderStatus(data.order_id,NewOrder,function(Error,Order){
				if(Order){
					if (Order.vendor_id) {
						UserModel.findById(Order.vendor_id._id, function(err, Op) {
							Op.available = true;
							Op.save();
						});
						if (Order.vendor_id.push_id) {
							const msg = {body:'Orden Cancelada.',customData:{order_id:data.order_id}};
							SendPNToUser(Order.vendor_id.push_id,msg,function(response){
								if(response){
								}
							});
						}
					}
					if (Order.user_id) {
						if (Order.user_id.push_id) {
							const msg = {body:'Orden Cancelada.',customData:{order_id:data.order_id}};
							SendPNToUser(Order.user_id.push_id,msg,function(response){
								if(response){
								}
							});
						}
					}
					//notify to the user that the order was canceled.
					ConnectedUsers.forEach(function(UserObj){
						if (UserObj.info.user_id == ActualOrders[data.order_id].user_id) {
							var UserOrder = Order;
							UserOrder.status = "Canceled";
							UserObj.socket.emit("UpdateOrder",UserOrder);
						}
					});

					//notify to other vendors that the order wan canceled.
					if(ActualOrders[data.order_id]){
						ActualOrders[data.order_id].vendors.forEach(function(vendorid){
							//Compare if the vendor is connected:
							ConnectedVendors.forEach(function(VendorObject){
								if (VendorObject.info.user_id == vendorid) {
									var VendorOrder = Order;
									VendorOrder.status = "Canceled";
									VendorObject.socket.emit("UpdateOrder",VendorOrder);
									VendorObject.available = true;
								}
							});
						});
						delete ActualOrders[data.order_id];
					} else {
						//notify to vendor that the order wan canceled.
						ConnectedVendors.forEach(function(VendorObject){
							if (VendorObject.info.user_id == Order.vendor_id._id) {
								var VendorOrder = Order;
								VendorOrder.status = "Canceled";
								VendorObject.socket.emit("UpdateOrder",VendorOrder);
								VendorObject.available = true;
							}
						});
					}
				}
			});
		});

		MainSocket.on('RejectOrder', function (data) {
			console.log("REJECTING ORDER");
			// MainSocket.emit('UpdateOrder',{ status: 'Normal' });
			if (ActualOrders[data.order_id]) {
				if(ActualOrders[data.order_id].vendors.length > 0) {
					//delete from the vendors array on order object
					var i = ActualOrders[data.order_id].vendors.indexOf(data.user_id);
					ActualOrders[data.order_id].vendors.splice(i, 1);
					// delete from the foundedVendors array for duplicate get order:
					var x = ActualOrders[data.order_id].foundedVendors.indexOf(data.user_id);
					ActualOrders[data.order_id].foundedVendors.splice(i, 1);

					// status on again for getting a new order
					ConnectedVendors.forEach(function(VendorObject){
						if (VendorObject.info.user_id == data.user_id) {
							VendorObject.available = true;
						}
					});
				}
			}
		});

		/////// ANOTHER EXTRA FUNCTIONS   /////////////
		MainSocket.on('RefreshDashboard', function () {
			io.to('admins').emit('RefreshDashboard');
		});
		MainSocket.on('SendMessage', function (data) {
			if (data.to == 'operator') {
				io.to('operators').emit('Message',{title: data.title , message: data.message});
			} else {
				io.to('users').emit('Message',{title: data.title , message: data.message});
			}
		});
	});
}
