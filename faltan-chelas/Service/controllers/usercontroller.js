//MODELS
var Config = require("../config/config");


var UserModel = require("../models/user");
var api_key = 'key-f653875d04623700dd6733fca9b2bb32';
var domain = 'sandboxc8bfca74f8654582b79205d3a5487403.mailgun.org';
var mailgun = require('mailgun-js')({apiKey: api_key, domain: domain});


module.exports = {

	Create: function(req,res){
		var User = new UserModel();
		if(req.body.email && req.body.password && req.body.phone){
			User.email.address = req.body.email.toLowerCase();
			User.password = req.body.password;
			User.phone = req.body.phone;
		}else{
			return res.json({success: false , message: "Campos necesarios incompletos."});
		}
		//POSIBLE OPTIONALS ON USER
		if(req.body.name){
			User.name = req.body.name;
		}
		if(req.body.push_id){
			User.push_id = req.body.push_id;
		}
		if(req.body.typeuser){
			User.typeuser = req.body.typeuser;
		}
		//POSIBLE OPTIONALS ON VENDOR
		if(req.body.marketname){
			User.marketname = req.body.marketname;
		}
		if(req.body.gender){
			User.gender = req.body.gender;
		}
		if(req.body.birthdate){
			User.birthdate = req.body.birthdate;
		}
		if(req.body.paydata){
			User.paydata = req.body.paydata;
		}
		if(req.body.othercontact){
			User.othercontact = req.body.othercontact;
		}
		User.loc.cord = [];
		if(req.body.loc){
			User.loc.denomination = req.body.loc.denomination;
			User.loc.cord = [Number(req.body.loc.cord.long),Number(req.body.loc.cord.lat)];
		}
		User.save(function(err){
			if(err){
				//entrada duplicada
				if(err.code == 11000){
					return res.json({success: false , message: "Ya Existe Alguien Registrado Con Este Numero."});
				}else{
					console.log(err);
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
			}
			var welcomeEmail = 'Muchas gracias por subirte a bordo!, para disfrutar de una mejor experiencia te invitamos a confirmar tu correo electronico. <a href="http://0.0.0.0:3030/validate?' + req.params.mail + '">Click aqui para confirmar.</a>'
			var data = {
			  from: 'Faltan Chelas <contacto@faltanchelas.com>',
			  to: User.email.address,
			  subject: 'Gracias por tu registro!',
			  html: welcomeEmail
			};
			mailgun.messages().send(data, function (error, body) {

			});

			res.json({success: true , user: User, message: "Muchas gracias por tu registro, ya puedes iniciar sesion."});
		});
	},

	All: function(req,res){
		UserModel.find( function(err, Users) {
			if(err){
				res.json({success: false , message: "Algo no salio bien."});
			}
			res.json({success: true , users: Users});
		});
	},

	AllUsers: function(req,res){
		UserModel.find({typeuser:'user'}).exec(function(err,Users){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , users: Users});
		});
	},

	AllAvailableUsers:  function(req,res){
		UserModel.find({typeuser:'user',available:true}).exec(function(err,Users){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , users: Users});
		});
	},

	AllVendors: function(req,res){
		console.log('byvendors');
		UserModel.find({typeuser:'vendor'}).exec(function(err,Vendors){
			if(err){
				console.log(err);
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , users: Vendors});
		});
	},

	AllAvailableVendors: function(req,res){
		UserModel.find({typeuser:'vendor',available:true}).exec(function(err,Vendors){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			res.json({success: true , users: Vendors});
		});
	},

	SearchVendorsByLoc: function(req,res){
    	var limit = Config.searchLimit;
	    var maxDistance = Config.searchDistance;
	    if(req.params.lat && req.params.long){
	    	var coords = [Number(req.params.long),Number(req.params.lat)];
			UserModel.find({
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
		        		return res.json({success: false , message: err});
		      		}

		      	res.json({success: true , vendors: vendors});
		    });
	    }else{
			res.json({success: false , message: 'Campos incompletos.'});
		}
	},

	SearchVendorsByStatus: function(req,res) {
    	var limit = Config.searchLimit;
	    var maxDistance = Config.searchDistance;
	    if(req.params.lat && req.params.long) {
	    	var coords = [Number(req.params.long),Number(req.params.lat)];
			var Status = true;
			UserModel.find({
				'blocked': false,
				'available': Status,
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
					return res.json({success: false , message: err});
				}
				res.json({success: true , vendors: vendors});
		    });
	    }else{
			res.json({success: false , message: 'Campos incompletos.'});
		}
	},
	ById: function(req,res){
		UserModel.findById( req.params.user_id, function(err,User){
			if(err){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}

			res.json({success: true , user: User});
		});
	},

	UpdateById: function(req,res) {
		UserModel.findById(req.params.user_id).select("password").exec(function(ErrorUser, User){
			if(ErrorUser){
				res.json({success: false , message: "Error fallo alguna validacion."});;
			}
			if(req.body.oldPassword){
				if(req.body.password) {
					var validPass = User.comparePassword(req.body.oldPassword);
					if(!validPass){
						res.json({success: false , message: "Contraseñas no coinciden."});;
					}else{
						User.password = req.body.password;
					}
				}
			}
			if(req.body.email){
				User.email.address = req.body.email.toLowerCase();
			}
			if(req.body.phone){
				User.phone = req.body.phone;
			}
			if(req.body.name){
				User.name = req.body.name;
			}
			if(req.body.typeuser){
				User.typeuser = req.body.typeuser;
			}
			if(req.body.push_id){
				User.push_id = req.body.push_id;
			}
			if(req.body.marketname){
				User.marketname = req.body.marketname;
			}
			if(req.body.gender){
				User.gender = req.body.gender;
			}
			if(req.body.birthdate){
				User.birthdate = req.body.birthdate;
			}
			if(req.body.paydata){
				User.paydata = req.body.paydata;
			}
			if(req.body.othercontact){
				User.othercontact = req.body.othercontact;
			}
			if(req.body.loc){
				User.loc.denomination = req.body.loc.denomination;
				User.loc.cord = [Number(req.body.loc.cord.long),Number(req.body.loc.cord.lat)];
			}
			if(req.body.available !== undefined){
				User.available = req.body.available;
			}
			//Salvar el usuario actualizado en la DB.
			User.save(function(ErrorSave){
				if(ErrorSave){
					if(ErrorSave.code == 11000){
						res.json({success: false , message: "Numero ya registrado."});;
					}else{
						res.json({success: false , message: "Error fallo alguna validacion."});;
					}
				}
				res.json({success: true , message: "Actualizado Satisfactoriamente.."});
			});
		});
	},

	RateUserById: function(req,res){
		if(req.body.user_id && req.body.rate){
			UserModel.findById(req.body.user_id).exec(function(ErrorUser, User){
				if(ErrorUser){
					res.json({success: false , message: "Error, usuario no encontrado."});;
				}
				switch (Number(req.body.rate)) {
					case 1:
						User.rate.onestar += 1;
						break;
					case 2:
						User.rate.twostar += 1;
						break;
					case 3:
						User.rate.threestar += 1;
						break;
					case 4:
						User.rate.fourstar += 1;
						break;
					case 5:
						User.rate.fivestar += 1;
						break;
					default:
						res.json({success: false , message: "Rankeo no valido."});;
				}
				User.save(function(ErrorSave){
					if(ErrorSave){
						res.json({success: false , message: "Error fallo alguna validacion."});;
					}
					res.json({success: true , message: "Calificado correctamente."});
				});
			});
		}else{
			res.json({success: false , message: "Campos incompletos."});;
		}
	},

	ForgotPassword: function(req, res) {
		if(req.body.email){
			UserModel.findOne({'email.address' : req.body.email}).exec(function(ErrorUser, User){
				if(User){
					var rString = '';
					var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
					for (var i=8; i > 0; --i) rString += chars[Math.floor(Math.random() * chars.length)];
					User.password = rString;
					User.save(function(ErrorSave){
						if(ErrorSave){
							res.json({success: false , message: "Error fallo alguna validacion."});;
						}
						var welcomeEmail = 'Te enviamos tu nueva contraseña, con esta podras acceder nuevamente a la aplicación.  CONTRASEÑA: ' + rString + ' , Una vez adentro de la app la podras cambiar en el menu de perfil.'
						var data = {
						  from: 'Faltan Chelas <contacto@faltanchelas.com>',
						  to: User.email.address,
						  subject: 'Recuperación de contraseña!',
						  html: welcomeEmail
						};
						mailgun.messages().send(data, function (error, body) {
						});
						res.json({success: true , message: "Se ha enviado tu nueva contraseña a tu correo."});
					});
				}else{
					res.json({success: false , message: "Error, usuario no encontrado."});
				}
			});
		}else{
			res.json({success: false , message: "Error, datos incompletos."});;
		}
	},
	DeleteById: function(req,res){
		UserModel.remove(
			{
				_id: req.params.user_id
			},
			function(err,User){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				res.json({success: true , message: "Usuario Borrado Satisfactoriamente.."});
			}
		);
	}


}
