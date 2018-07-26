//MODELS
var UserModel = require("../models/user");
var UserAdminModel = require("../models/useradmin");
var OrderModel = require("../models/order");

//JSONWEBTOKEN
var jwt = require("jsonwebtoken");

//Config File
var Config = require("../config/config");
var KeyToken = Config.key;

module.exports = {
	AuthByUser: function(req,res){
		console.log("Iniciando Sesion: " + req.body.email);
		if(req.body.email && req.body.password){
			UserModel.findOne({
					'email.address': req.body.email.toLowerCase()
				}).exec( function(err, Usuario){
					if(err){
						res.json({success: false , message: "Error fallo alguna validacion."});;
					}
					if(!Usuario){
						res.json({success:false,message:"Usuario no encontrado."});
					}else{
						//check the pass:
						var validPass = Usuario.comparePassword(req.body.password);
						if(!validPass){
							res.json({success:false,message:"Contraseña incorrecta."});
						}else{
							//Usuario OK pass OK
							var token = jwt.sign(
								{
									_id: Usuario._id,
									email: Usuario.email,
									phone: Usuario.phone
								},
								KeyToken,
								{
									expiresIn: 172800
								}
							);

							if (Usuario.blocked == false) {
								Usuario.isLogged = true;
								if (Usuario.typeuser == "vendor") {
									// first check if have one active order:
									OrderModel.findOne({vendor_id: Usuario._id}).sort({$natural:-1}).limit(1).exec(function(err,Order){
										if(err) {
											res.json({success:false,message:"Error al consultar ultima orden."});
										}
										if (Order) {
											if (Order.status === "Normal" || Order.status == "Canceled" || Order.status == "NotAccepted"){
												Usuario.available = true;
											}else{
												Usuario.available = false;
											}
										}else{
											Usuario.available = true;
										}
										Usuario.save(function(err){
											res.json({success:true,message:"Bienvenido.",token:token,user:Usuario});
										});
									});
								}else{
									Usuario.available = true;
									Usuario.save(function(ErrorSave){
										if (ErrorSave){
											res.json({success:false,message:"Error al guardar usuario."});
										}
										res.json({success:true,message:"Bienvenido.",token:token,user:Usuario});
									});
								}
							} else {
								res.json({success:false,message:"Permiso denegado."});
							}
						}
					}
				}
			);
		}else{
			res.json({success:false,message:"Rellena los campos faltantes."});
		}
	},

	AuthByUserAdmin: function(req,res){
		console.log("Iniciando Sesion ADMIN: " + req.body);
		UserAdminModel.findOne({
				username: req.body.username
			}).select("username password").exec( function(err, Usuario){
				if(err){
					res.json({success: false , message: "Error fallo alguna validacion."});;
				}
				if(!Usuario){
					res.json({success:false,message:"Authenticate Failed User Not Found"});
				}else{
					//check the pass:
					var validPass = Usuario.comparePassword(req.body.password);
					if(!validPass){
						res.json({success:false,message:"Authenticate Failed, Wrong Pass"});
					}else{
						//Usuario OK pass OK
						var token = jwt.sign(
							{
								username: Usuario.username,
							},
							KeyToken,
							{
								expiresIn: 172800
							}
						);
						res.json({success:true,message:"Bienvenido.",token:token,usuario:Usuario});
					}
				}
			}
		);
	},

	LogOutUser: function(req,res) {
		UserModel.findById(req.params.user_id).exec(function(err, Usuario){
			Usuario.available = false;
			Usuario.isLogged = false;
			Usuario.save(function(ErrorSave){
				if (ErrorSave){
					res.json({success:false,message:"Error al guardar usuario."});
				}
				res.json({success:true,message:"Adios."});
			});
		});
	}
}
