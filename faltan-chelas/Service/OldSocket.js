var Config = require("../../config/config");

var OrderFunctions = require("../controllers/ordercontroller");
var UserModel = require("../models/user");
var VendorModel = require("../models/vendor");
var SellModel = require("../models/sell");
var ConfigModel = require("../models/configuration");

var _ = require('lodash');
var async = require('async');
var conekta = require('conekta');
conekta.api_key = Config.ConektaApiKey;
conekta.locale = 'es';

exports.initialize = function(server){

	var io = require('socket.io')(server);

	var UsersConnected = [];
	var VendorsConnected = [];
	var MoviblesConnected = [];
	var OrdersOnWay = [];

	io.on('connection', function (MainSocket) {

		console.log("Nueva Conexion Al Servidor.");

		MainSocket.emit('HowYouAre');

	  	MainSocket.on('AddUser', function (data) {
	  			console.log("Se conectó Usuario.");
	  			var usuario = {
	  				user: data,
	  				socket: MainSocket
	  			}
	  			UserModel.findById(data._id, function(err, User){
					//some error
					if(err){
						console.log(err);
					}

					if(User){

						User.online = true;
						//Salvar el usuario actualizado en la DB.
						User.save(function(err){
							if(err){
								console.log(err);
							}
						});

					}

				});
				var isOnArray = false;
				UsersConnected.forEach(function(User){
					if(User.user._id == usuario.user._id){
						console.log("Ya está conectado: " + usuario.user._id);
						isOnArray = true;
					}
		    	});
				if(!isOnArray){
					UsersConnected.push(usuario);
				}
				MainSocket.on('disconnect', function() {
	  				console.log("Se Desconecto Usuario.");
		  			UserModel.findById(data._id, function(err, User){
						//some error
						if(err){
							console.log(err);
						}

						if(User){

							User.online = true;
							//Salvar el usuario actualizado en la DB.
							User.save(function(err){
								if(err){
									console.log(err);
								}
							});

						}
					});
      				var i = UsersConnected.indexOf(usuario);
      				UsersConnected.splice(i, 1);
   				});
	  	});

	  	MainSocket.on('AddVendor', function (data) {
	  			console.log("Se conectó el repartidor.");
	  			var tiendero = {
	  				vendor: data,
	  				socket: MainSocket
	  			}
	  			VendorModel.findById(data._id, function(err, Vendor){
					//some error
					if(err){
						console.log(err);
					}
					if(Vendor){
						Vendor.online = true;
						//Salvar el usuario actualizado en la DB.
						Vendor.save(function(err){
							if(err){
								console.log(err);
							}
						});
					}

				});
				VendorsConnected.push(tiendero);
				MainSocket.on('disconnect', function() {
	  				console.log("Se desconectó el repartidor.");
		  			VendorModel.findById(data._id, function(err, Vendor){
						//some error
						if(err){
							console.log(err);
						}
						if(Vendor){
							Vendor.online = true;
							//Salvar el usuario actualizado en la DB.
							Vendor.save(function(err){
								if(err){
									console.log(err);
								}
							});
						}
					});
      				var i = VendorsConnected.indexOf(tiendero);
      				VendorsConnected.splice(i, 1);
   				});
	  	});

	  	MainSocket.on('AddMovible', function (data) {
	  			console.log("Se conectó el Móvible.");
	  			var movible = {
	  				movible: data,
	  				socket: MainSocket
	  			}
	  			VendorModel.findById(data._id, function(err, Vendor){
					//some error
					if(err){
						console.log(err);
					}
					if(Vendor){
						Vendor.online = true;
						//Salvar el usuario actualizado en la DB.
						Vendor.save(function(err){
							if(err){
								console.log(err);
							}
						});
					}
				});
				MoviblesConnected.push(movible);
				MainSocket.on('disconnect', function() {
	  				console.log("Se desconectó el Móvible.");
		  			VendorModel.findById(data._id, function(err, Vendor){
						//some error
						if(err){
							console.log(err);
						}
						if(Vendor){
							Vendor.online = true;
							//Salvar el usuario actualizado en la DB.
							Vendor.save(function(err){
								if(err){
									console.log(err);
								}
							});
						}
					});
      				var i = MoviblesConnected.indexOf(movible);
      				MoviblesConnected.splice(i, 1);
   				});
	  	});



	  	//ENVIAR LA ORDEN A TODOS LOS TIENDEROS CONECTADOS Y EL PRIMERO QUE LA ACEPTE SE GANA LA ORDEN; SI NADIE ACEPTO ENVIAR A 'BICICLETEROS',(USUARIOS ESPECIFICOS QUE SE IDENTIFICARAN AL MOMENTO DE LOGUEARSE);
	  	MainSocket.on('SearchVendor', function(DataSocket){

	  		console.log("Buscando Proveedores:");
			var TaskFunctions = [];
			TaskFunctions.push(function(callback){
				//Obtener el usuario quien esta ordenando:
				console.log('Obteniendo el usuario de petición');
				UsersConnected.forEach(function(usuario){
					if(usuario.user._id == DataSocket.user._id){
						console.log("Usuario: " + usuario.user._id);
						callback(null, usuario);
					}
		    	});

            });

			TaskFunctions.push(function(UserRequest, callback){
	    		//Crear la orden en MONGODB Status: "Buscando";
	    		console.log("Salvando la orden en la base de datos.");
				var Order = new SellModel();

				Order.user_id = UserRequest.user._id;

				var totalOrder = 0;

				console.log(DataSocket);

				DataSocket.order.forEach(function(producto){
					var ProductTemp = {
						denomination: producto.product,
						price: Number(producto.price),
						units: Number(producto.quantity)
					}

					totalOrder = totalOrder + ProductTemp.price;
					Order.products.push(ProductTemp);
		    	});

				Order.total = totalOrder;
				var LocArray = [DataSocket.coords.loc.long,DataSocket.coords.loc.lat];
				Order.loc = LocArray;
				Order.status = 'Buscando';

				Order.save(function(err){
					if(err){
						console.log(err);
					}
					callback(null,UserRequest,Order._id);
				});
            });

			TaskFunctions.push(function(UserRequest,OrderId, callback){
				console.log("Obteniendo Vendedores Disponibles y Cercanos:")
	    		//Obtener a los vendedores mas cercanos para poder comparar con los conectados:
	    		var limit = Config.searchLimit;
			    var maxDistance = Config.searchDistance;
			    // get coordinates [ <longitude> , <latitude> ]
				var coords = [Number(DataSocket.coords.loc.long),Number(DataSocket.coords.loc.lat)];
			    console.log('Coordenadas: ' + coords);

				VendorModel.find({
					'loc.cord': {
						$near: {
							$geometry: {
								type:'Point',
								coordinates:coords
							},
							$maxDistance:maxDistance
						}
					}
				}).limit(limit).exec(function(err, vendors) {
			      		if (err) {
							console.log(err);
			      		}
			      	callback(null, UserRequest,OrderId,vendors);
			    });

            });

			TaskFunctions.push(function( UserRequest, OrderId, VendorsFromDB, callback){
				//VendorFromDB Check if are conected.
				console.log('Verificando quienes están disponibles.');
				var VendorsAvailables = [];
				VendorsConnected.forEach(function(vendor){
					VendorsFromDB.forEach(function(vendorDB){
						if(vendor.vendor._id == vendorDB._id){
							VendorsAvailables.push(vendor);
						}
					});
		    	});
				callback(null, UserRequest, OrderId, VendorsAvailables);
            });


			TaskFunctions.push(function(UserRequest, OrderId, VendorsAvailables, callback){
				//EMIT TO VENDORS:
				console.log("Emitiendo a los vendedores:");

				var Loops = 0;
				var intervalo = setInterval(function Search() {

					if(Loops > 1){
						//Quitar Listener de los movibles y emitir que nadie acepto;
				  		MoviblesConnected.forEach(function(MovibleToDel){
				  			MovibleToDel.socket.removeAllListeners('AcceptOrder');
							MovibleToDel.socket.emit('ExpiredOrder', {msg: "La orden fue tomada por otro repartidor, gracias."});
			  			});
					  	clearInterval(intervalo);
					  	callback(null, 'Rejected', UserRequest, OrderId, VendorsAvailables);
					}else if(Loops == 1){

						//Quitar listener de tienderos y emitir que nadie acepto:
				  		VendorsAvailables.forEach(function(VendorToDel){
				  			VendorToDel.socket.removeAllListeners('AcceptOrder');
							VendorToDel.socket.emit('ExpiredOrder', {msg: "La orden fue tomada por otro repartidor, gracias."});
			  			});

						//Emit To All Movibles:
						MoviblesConnected.forEach(function(Movible){
							Movible.socket.emit('NewOrder', {order_id: OrderId, user: DataSocket.user, order: DataSocket.order, coords:DataSocket.coords});

						  	Movible.socket.on('AcceptOrder', function(data) {

						  		MoviblesConnected.forEach(function(MovibleToDel){
						  			MovibleToDel.socket.removeAllListeners('AcceptOrder');

					  				if(Movible != MovibleToDel){
										MovibleToDel.socket.emit('ExpiredOrder', {msg: "La orden fue tomada por otro repartidor, gracias."});
					  				}
					  			});
					  			console.log("Movible Acepto Pedido: " + Movible.movible._id);
		  						clearInterval(intervalo);
		  						callback(null,'Accepted-Movible',UserRequest,OrderId,Movible);
						  	});
				    	});

					}else if(Loops == 0){

						//Emit To All Vendors:
						VendorsAvailables.forEach(function(Vendor){
							Vendor.socket.emit('NewOrder', {order_id: OrderId, user: DataSocket.user, order: DataSocket.order, coords:DataSocket.coords});

						  	Vendor.socket.on('AcceptOrder', function(data) {

						  		VendorsAvailables.forEach(function(VendorToDel){
						  			VendorToDel.socket.removeAllListeners('AcceptOrder');

					  				if(Vendor != VendorToDel){
										VendorToDel.socket.emit('ExpiredOrder', {msg: "La orden fue tomada por otro repartidor, gracias."});
					  				}
					  			});

					  			console.log("Repartidor Acepto Pedido: " + Vendor.vendor._id);
		  						clearInterval(intervalo);
		  						callback(null,'Accepted-Vendor',UserRequest,OrderId,Vendor);
						  	});
				    	});
					}else{
						clearInterval(intervalo);
					}

					Loops += 1;

				  	return Search;
				}(), 60000);

            });

	    	TaskFunctions.push(function( Status, UserRequest, OrderId,VendorAccept, callback){
	    		//Handle Possiible status
	    		console.log('Handle Options');

	    		if(Status == 'Accepted-Vendor'){

	    			//Marcar como no disponible al vendedor:
	    			VendorModel.findById(VendorAccept.vendor._id, function(err, Vendor){
						//some error
						if(err){
							console.log(err);
						}
						Vendor.online = false;

						Vendor.save(function(err){
							if(err){
								console.log(err);
							}

							//Modificar estado de orden a 'Aceptada' y agregar vendor_id;
			    			SellModel.findById(OrderId, function(err,Order){
								if(err){
									console.log(err);
								}
								Order.status = 'Aceptada';
								Order.vendor_id = VendorAccept.vendor._id;

								Order.save(function(err){
									if(err){
										console.log(err);
									}
									console.log("Emitiendo usuario");
									UserRequest.socket.emit('Accepted', {msg: 'Orden Aceptada',order: Order});
									OrdersOnWay.push({order_id:OrderId, vendor_id:VendorAccept.vendor._id,user_id:UserRequest.user._id,paymethod: DataSocket.info});
									callback(null);

								});
							});
						});
					});

	    		}else if(Status == 'Accepted-Movible'){


	    			//Marcar como no disponible al vendedor:
	    			VendorModel.findById(VendorAccept.movible._id, function(err, Vendor){
						//some error
						if(err){
							console.log(err);
						}
						Vendor.online = false;

						Vendor.save(function(err){
							if(err){
								console.log(err);
							}

							//Modificar estado de orden a 'Aceptada' y agregar vendor_id;
			    			SellModel.findById(OrderId, function(err,Order){
								if(err){
									console.log(err);
								}
								Order.status = 'Aceptada';
								Order.vendor_id = VendorAccept.movible._id;

								Order.save(function(err){
									if(err){
										console.log(err);
									}

									console.log("Emitiendo usuario");
									UserRequest.socket.emit('Accepted', {msg: 'Orden Aceptada',order: Order});
									OrdersOnWay.push({order_id:OrderId,vendor_id:VendorAccept.movible._id,user_id:UserRequest.user._id,paymethod: DataSocket.info});
									callback(null);
								});
							});
						});
					});

	    		}else if(Status == 'Rejected'){

	    			//Modificar estado de orden a 'Aceptada' y agregar vendor_id;
	    			SellModel.findById(OrderId, function(err,Order){
						if(err){
							console.log(err);
						}
						Order.status = 'Rechazada';
						Order.save(function(err){
							if(err){
								console.log(err);
							}
						});
					});

	    			//Emitir a los vendedores que ya expiro porque nadie acepto:
	    			//Quitar Listener
					VendorAccept.forEach(function(VendorToDel){
						VendorToDel.socket.emit('ExpiredOrder', {msg: "Expiró el tiempo de espera, lo sentimos."});
		  			});
	    			//Emitir al usuario que nadie acepto.
	    			UserRequest.socket.emit('Rejected', {msg: "Por el momento estamos saturados, lo sentimos."});
	    			callback(null);


	    		}else{

	    			//Modificar estado de orden a 'Aceptada' y agregar vendor_id;
	    			SellModel.findById(OrderId, function(err,Order){
						if(err){
							console.log(err);
						}
						Order.status = 'Desconocido';

						Order.save(function(err){
							if(err){
								console.log(err);
							}
						});
					});

					//Quitar Listener
					VendorAccept.forEach(function(VendorToDel){
						VendorToDel.socket.emit('ExpiredOrder', {msg: "Expiró el tiempo de espera, lo sentimos."});
		  			});
	    			//Emitir al usuario que nadie acepto.
	    			UserRequest.socket.emit('Rejected', {msg: "Por el momento estamos saturados, lo sentimos."});
	    			callback(null);
	    		}
            });

			async.waterfall(TaskFunctions, function(err) {
				console.log('Se ejecutaron todas las tareas');
			});

	  	});

		MainSocket.on('Arrived', function(Data) {

			//FIND THE ORDER ON ARRAY:
			console.log(Data);

			var OrderOnWay;
			OrdersOnWay.forEach(function(Order){
				if(Order.order_id == Data.order_id){
					console.log("ORDEN ENCONTRADA");
					OrderOnWay = Order;
				}
	    	});

	    	if(OrderOnWay){

				var UserRequest;
				UsersConnected.forEach(function(User){
					if(User.user._id == OrderOnWay.user_id){
						console.log("User Founded: ");
						UserRequest = User;
					}
			    });

			    SellModel.findById(OrderOnWay.order_id, function(err,Order){
					if(err){
						console.log(err);
					}
					Order.status = 'Cobrando';
					Order.save(function(err){
						if(err){
							console.log(err);
						}
					});
					if(!OrderOnWay.paymethod.isTokenized){

						console.log('La tarjeta es nueva.');

						UserModel.findById(OrderOnWay.user_id, function(err, User){
							//some error
							if(err){
								console.log(err);
							}

							console.log(OrderOnWay);

							conekta.Customer.create({
							  	"name": User.name || 'No Name Provided Yet',
							  	"email": User.email.address,
							  	"phone": User.phone,
							  	"cards": [OrderOnWay.paymethod.token]

							}, function(customer) {

							  	console.log("Saved Customer...");
							  	console.log(customer.toObject());

							  	var SavedCustomer = customer.toObject();

								var totalOrder = 0;
								var totalUnits = 0;
								var products = [];

								Order.products.forEach(function(producto){
									var ProductTemp = {
										name: producto.denomination,
										unit_price: Number(producto.price) * 100,
										quantity: Number(producto.units),
										description: 'Chelas For Deliver Description'
									}
									totalOrder = totalOrder + ProductTemp.unit_price;
									totalUnits = totalUnits + ProductTemp.quantity;
									products.push(ProductTemp);
						    	});
						    	//Save the CustomerID to paymethods on client.
						    	if(SavedCustomer.cards[0]){
							    	var Paymethod = {
							    		denomination: SavedCustomer.cards[0].brand,
							    		termination: SavedCustomer.cards[0].last4,
							    		tokenization: SavedCustomer.id
							    	}
						    		User.paymethods.push(Paymethod);
						    	}

								User.save(function(err){
									if(err){
										console.log(err);
									}
								});

								//GET THE EXTRA IN CONFIG
								ConfigModel.find( function(err, Configs) {
									if(err){
										res.send(err);
									}
									var Extra = 0;
									Configs.forEach(function(conf){

										if(conf.denomination == "COMISION_FC" ||conf.denomination == "comisionfc" ||
					                        conf.denomination == "Comision_FC" ||conf.denomination == "Comision" ||
					                        conf.denomination == "COMISION" ||conf.denomination == "COMISIONFC"){
					                        Extra = Number(conf.parameter);
					                    }else{
					                        Extra = 20;
					                    }
					                });

									totalOrder = totalOrder + (Extra * 100);

									conekta.Charge.create({
									  	"amount": totalOrder,
									  	"currency": "MXN",
									  	"description": "FaltanChelas Delivery",
									  	"card": SavedCustomer.id,
									  	"details": {
									  		"name": User.name || 'No Name Provided Yet',
								  			"email": User.email.address,
								  			"phone": User.phone,
									    	"line_items": products
									  	}

									}, function(charge) {
										console.log("CARGO COBRADO");
									  	console.log(charge.toObject());

										Order.status = "Cobrado";
										Order.total = totalOrder/100;

										Order.save(function(err){
											if(err){
												console.log(err);
											}
										});

										if(UserRequest){
											UserRequest.socket.emit('Arrived', {title: 'Â¡Tus chelas han llegado!', msg: "Se ha realizado el cargo por $" + totalOrder/100 + " Muchas Gracias"});
									    }else{
									    	console.log("USER NOT FOUND OR CONNECTED");
									    }

									  	//delete the order from array;
									  	var i = OrdersOnWay.indexOf(OrderOnWay);
			  							OrdersOnWay.splice(i, 1);

									}, function(err) {

									  	console.log(err.message_to_purchaser);

										Order.status = "Error - " + err.message_to_purchaser;
										Order.total = totalOrder/100;

										Order.save(function(err){
											if(err){
												console.log(err);
											}
										});

										if(UserRequest){
											UserRequest.socket.emit('Arrived', {title: 'Ocurrió un error', msg: err.message_to_purchaser});
										}else{
									    	console.log("USER NOT FOUND OR CONNECTED");
									    }

										//delete the order from array;
									  	var i = OrdersOnWay.indexOf(OrderOnWay);
			  							OrdersOnWay.splice(i, 1);

									});


								});

							}, function(err) {
							  	console.log(err.message_to_purchaser);
								Order.status = "Error - " + err.message_to_purchaser;
								Order.save(function(err){
									if(err){
										console.log(err);
									}
								});

								if(UserRequest){
									UserRequest.socket.emit('Arrived', {title: 'Ocurrió un error', msg: err.message_to_purchaser});
								}else{
							    	console.log("USER NOT FOUND OR CONNECTED");
							    }

								//delete the order from array;
							  	var i = OrdersOnWay.indexOf(OrderOnWay);
	  							OrdersOnWay.splice(i, 1);
							});
						});
					}else{

						console.log("PAGO DE METODO CONOCIDO");
						console.log(OrderOnWay);

						UserModel.findById(OrderOnWay.user_id, function(err, User){
							//some error
							if(err){
								console.log(err);
							}

							var totalOrder = 0;
							var totalUnits = 0;
							var products = [];

							Order.products.forEach(function(producto){
								var ProductTemp = {
									name: producto.denomination,
									unit_price: Number(producto.price) * 100,
									quantity: Number(producto.units),
									description: 'Chelas For Deliver Description'
								}
								totalOrder = totalOrder + ProductTemp.unit_price;
								totalUnits = totalUnits + ProductTemp.quantity;
								products.push(ProductTemp);
					    	});

							//GET THE EXTRA IN CONFIG
							ConfigModel.find( function(err, Configs) {
								if(err){
									res.send(err);
								}
								var Extra = 0;
								Configs.forEach(function(conf){

									if(conf.denomination == "COMISION_FC" ||conf.denomination == "comisionfc" ||
				                        conf.denomination == "Comision_FC" ||conf.denomination == "Comision" ||
				                        conf.denomination == "COMISION" ||conf.denomination == "COMISIONFC"){
				                        Extra = Number(conf.parameter);
				                    }else{
				                        Extra = 20;
				                    }
				                });

								totalOrder = totalOrder + (Extra * 100);

							  	conekta.Charge.create({
								  	"amount": totalOrder,
								  	"currency": "MXN",
								  	"description": "FaltanChelas Delivery",
								  	"card": OrderOnWay.paymethod.token,
								  	"details": {
								  		"name": User.name || 'No Name Provided Yet',
							  			"email": User.email.address,
							  			"phone": User.phone,
								    	"line_items": products
								  	}

								}, function(charge) {

									console.log("CARGO COBRADO");
								  	console.log(charge.toObject());

	      							//Update on DB:
									Order.status = "Cobrado";
									Order.total = totalOrder/100;
									Order.save(function(err){
										if(err){
											console.log(err);
										}
									});

									if(UserRequest){
								    	UserRequest.socket.emit('Arrived', {title: 'Â¡Tus chelas han llegado!', msg: "Se ha realizado el cargo por $" + totalOrder/100 + " Muchas Gracias"});
								    }else{
								    	console.log("USER NOT FOUND OR CONNECTED");
								    }

								  	//delete the order from array;
								  	var i = OrdersOnWay.indexOf(OrderOnWay);
		  							OrdersOnWay.splice(i, 1);

								}, function(err) {
								  	console.log(err.message_to_purchaser);

								  	Order.status = "Error - " + err.message_to_purchaser;
								  	Order.total = totalOrder/100;

									Order.save(function(err){
										if(err){
											console.log(err);
										}
									});

									if(UserRequest){
										UserRequest.socket.emit('Arrived', {title: 'Ocurrió un error', msg: err.message_to_purchaser});
									}else{
								    	console.log("USER NOT FOUND OR CONNECTED");
								    }

									//delete the order from array;
								  	var i = OrdersOnWay.indexOf(OrderOnWay);
		  							OrdersOnWay.splice(i, 1);
								});

							});
						});
					}
				});
	    	}else{
	    		console.log("NO ORDER FOUND WITH THIS ID");
    			//Modificar estado de orden a 'Aceptada' y agregar vendor_id;
    			SellModel.findById(Data.order_id, function(err,Order){
					if(err){
						console.log(err);
					}
					Order.status = 'La orden no se proceso correctamente.';
					Order.save(function(err){
						if(err){
							console.log(err);
						}
					});
				});
	    	}

		});

		console.log("Usuarios: " + UsersConnected.length);
		console.log("Repartidors: " + VendorsConnected.length);
		console.log("Móviles: " + MoviblesConnected.length);
	});

}
