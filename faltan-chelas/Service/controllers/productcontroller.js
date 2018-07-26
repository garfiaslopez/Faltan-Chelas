//MODELS
var ProductModel = require("../models/product");

module.exports = {

	Create: function(req,res){
		var Product = new ProductModel();
		Product.denomination = req.body.denomination;
		if(req.body.description){
			Product.description = req.body.description;
		}
		Product.type = req.body.type;
		Product.save(function(err){
			if(err){
				res.json({success: false , message: "Algo no salio bien."});
			}
			res.json({success: true , message: "Producto Creado Satisfactoriamente.."});
		});
	},
	All: function(req,res){
		ProductModel.find( function(err, Products) {
			if(err){
				res.json({success: false , message: "Algo no salio bien."});
			}
			res.json({success: true , products: Products});
		});
	},

	AllByType: function(req,res){
		ProductModel.find({type: req.params.type}, function(err, Products) {
			if(err){
				res.json({success: false , message: "Algo no salio bien."});
			}
			res.json({success: true , products: Products});
		});
	},


	ById: function(req,res){
		ProductModel.findById( req.params.product_id, function(err,Product){
			if(err){
				res.json({success: false , message: "Algo no salio bien."});
			}
			res.json({success: true , product: Product});
		});
	},

	UpdateById: function(req,res){
		ProductModel.findById( req.params.product_id, function(err, Product){
			//some error
			if(err){
				res.json({success: false , message: "Algo no salio bien."});
			}
			//Getting the values from the body request and putting on the user recover from mongo
			if(req.body.denomination){
				Product.denomination = req.body.denomination;
			}
			if(req.body.description){
				Product.description = req.body.description;
			}
			if(req.body.type){
				Product.type = req.body.type;
			}
			//ARRAY:
			if(req.body.prices){
				Product.prices = req.body.prices;
			}
			//Salvar el usuario actualizado en la DB.
			Product.save(function(err){
				if(err){
					res.json({success: false , message: "Algo no salio bien."});
				}
				res.json({success: true , message: "Producto Actualizado Satisfactoriamente.."});
			});
		});
	},

	DeleteById: function(req,res){
		ProductModel.remove(
			{
				_id: req.params.product_id
			},
			function(err,Producto){
				if(err){
					res.json({success: false , message: "Algo no salio bien."});
				}
				res.json({success: true , message: "Producto Borrado Satisfactoriamente.."});
			}
		);
	}
}
