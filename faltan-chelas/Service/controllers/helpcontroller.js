//MODELS
var HelpModel = require("../models/help");

module.exports = {

	Create: function(req,res){
		var Help = new HelpModel();
        Help.subject = req.body.subject;
        Help.description = req.body.description;
		Help.user_id = req.body.user_id;
		Help.save(function(err){
			if(err){
                res.json({success: false , message: "Algo no salio bien."});
			}
			res.json({success: true , message: "Peticion de ayuda enviada correctamente."});
		});
	},

	All: function(req,res){
		HelpModel.find().populate('user_id').exec(function(err, Helps) {
			if(err){
                res.json({success: false , message: "Algo no salio bien."});
			}
			res.json({success: true , helps: Helps});
		});
	},

	ById: function(req,res){
		HelpModel.findById(req.params.help_id, function(err,Help){
			if(err){
                res.json({success: false , message: "Algo no salio bien."});
			}
			res.json({success: true , help: Help});
		});
	},

	UpdateById: function(req,res){

		HelpModel.findById( req.params.help_id, function(err, Help){
			//some error
			if(err){
                res.json({success: false , message: "Algo no salio bien."});
			}
			//Getting the values from the body request and putting on the user recover from mongo
			if(req.body.subject){
				Help.subject = req.body.subject;
			}
            if(req.body.description){
				Help.description = req.body.description;
			}
            if(req.body.user_id){
				Help.user_id = req.body.user_id;
			}
			//Salvar el usuario actualizado en la DB.
			Help.save(function(err){
				if(err){
                    res.json({success: false , message: "Algo no salio bien."});
				}
				res.json({success: true , message: "Ayuda Actualizado Satisfactoriamente.."});
			});
		});
	},

	DeleteById: function(req,res){
		HelpModel.remove(
			{
				_id: req.params.help_id
			},
			function(err,Help){
				if(err){
                    res.json({success: false , message: "Algo no salio bien."});
				}
				res.json({success: true , message: "Ayuda Borrado Satisfactoriamente.."});
			}
		);
	}


}
