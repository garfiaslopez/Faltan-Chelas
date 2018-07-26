//MODELS
var UserAdminModel = require("../models/useradmin");

module.exports = {

	Create: function(req,res){
		var user = new UserAdminModel();
		user.username = req.body.username;
		user.password = req.body.password;
		user.save(function(err){
			if(err){
				//entrada duplicada
				if(err.code == 11000){
					return res.json({success: false , message: "Ya Existe Un Admin Con Ese Nombre."});
				}else{
					res.json({success: false , message: "Algo no salio bien."});
				}
			}
			res.json({success: true , message: "Admin Creado Satisfactoriamente.."});
		});
	},


	All: function(req,res){
		UserAdminModel.find( function(err, usuarios) {
			if(err){
				res.json({success: false , message: "Algo no salio bien."});
			}
			res.json({success: true , usersadmin: usuarios});
		});
	},

	ById: function(req,res){
		UserAdminModel.findById( req.params.useradmin_id, function(err,Usuario){
			if(err){
				res.json({success: false , message: "Algo no salio bien."});
			}
			res.json({success: true , useradmin: Usuario});
		});
	},

	UpdateById: function(req,res){
		UserAdminModel.findById( req.params.useradmin_id, function(err, Usuario){
			if(err){
				res.json({success: false , message: "Algo no salio bien."});
			}
			//Getting the values from the body request and putting on the user recover from mongo
			if(req.body.username){
				Usuario.username = req.body.username;
			}
			if(req.body.password){
				Usuario.password = req.body.password;
			}
			//Salvar el usuario actualizado en la DB.
			Usuario.save(function(err){
				if(err){
					res.json({success: false , message: "Algo no salio bien."});
				}
				res.json({success: true , message: "Admin Actualizado Satisfactoriamente.."});
			});
		});
	},

	DeleteById: function(req,res){
		UserAdminModel.remove(
			{
				_id: req.params.useradmin_id
			},
			function(err,Usuario){
				if(err){
					res.json({success: false , message: "Algo no salio bien."});
				}
				res.json({success: true , message: "Admin Borrado Satisfactoriamente.."});
			}
		);
	}
}
