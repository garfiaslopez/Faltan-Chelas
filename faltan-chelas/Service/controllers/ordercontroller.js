//MODELS
var OrderModel = require("../models/order");
var mongoose = require("mongoose");
var ObjectId = mongoose.Types.ObjectId;

var moment = require("moment");
moment.locale('MX');

var Schema = mongoose.Schema;

module.exports = {

	Create: function(req,res){
		var Order = new OrderModel();
		Order.aditionalInfo = req.body.aditionalInfo;
		Order.user_id = req.body.user_id;
		Order.products = req.body.products;
		Order.total = req.body.total;
		Order.destiny.denomination = req.body.destiny.denomination;
		Order.destiny.cord = [0,0];
		Order.destiny.cord[0] = Number(req.body.destiny.long);
		Order.destiny.cord[1] = Number(req.body.destiny.lat);
		Order.paymethod = req.body.paymethod;

		Order.save(function(err){
			if(err){
				console.log(err);
				return res.json({success:false,message:'Algo Salio mal.'});
			}
			return res.json({success:true, order: Order, message:'Orden creada correctamente.'});
		});
	},

	All: function(req, res){
		var Paginator = {
			page: 1,
			limit: 10
		};
		OrderModel.paginate({},Paginator, function(err, result) {
			if(err){
				return res.json({success:false,message:'Algo Salio mal.'});
			}
			res.json({success: true , orders: result});
		});
	},

	Filter: function(req, res){
		// DATES ON UTC();
		// defaultProps Paginator.
		var Query = {};
		var Paginator = {
			page: 1,
			limit: 10,
			sort: { order_id: -1 },
			populate: ['user_id','vendor_id']
		};
		if (req.body.page){
			Paginator.page = req.body.page;
		}
		if (req.body.limit) {
			Paginator.limit = req.body.limit;
		}
		var initialDate = undefined;
		var finalDate = undefined;
		if (req.body.dateFilter) {
			switch (req.body.dateFilter) {
				case "today" || "TODAY":
					initialDate = moment().startOf('day').utc();
					finalDate = moment().utc();
				break;
				case "week" || "WEEK":
					initialDate = moment().startOf('week').isoWeekday(1).utc();
					finalDate = moment().utc();
				break;
				case "month" || "MONTH":
					initialDate = moment().startOf('month').utc();
					finalDate = moment().utc();
				break;
				case "year" || "YEAR":
					initialDate = moment().startOf('year').utc();
					finalDate = moment().utc();
				break;
				case "range" || "RANGE":
					if (req.body.initialDate && req.body.finalDate) {
						initialDate = moment(req.body.initialDate);
						finalDate = moment(req.body.finalDate);
					} else {
						initialDate = undefined;
						finalDate = undefined;
					}
				break;
				default:
					initialDate = undefined;
					finalDate = undefined;
				break;
			}
		}
		if (initialDate !== undefined && finalDate !== undefined) {
			Query['date'] = {
				$gt: initialDate.toDate(),
				$lt: finalDate.toDate()
			};
		}
		var typeUser = "";
		if(req.body.user_id){
			typeUser = "$user_id";
			Query['user_id'] = new ObjectId(req.body.user_id);
		}
		if(req.body.vendor_id){
			typeUser = "$vendor_id";
			Query['vendor_id'] = new ObjectId(req.body.vendor_id);
		}
		if (req.body.status) {
			Query['status'] = req.body.status;
		}
		if (req.body.order_id) {
			Query['order_id'] = req.body.order_id;
		}
		Query['status'] = "Normal";

		if (req.body.isTotals) {
			OrderModel.aggregate([
				{$match: Query},
				{$group: {_id: typeUser, count: {$sum: 1}, total: {$sum: "$total"}}
			}], function (err, result){
				if(err){
					return res.json({success:false,message:'Algo Salio mal.'});
				}
				if (result.length > 0) {
					res.json({ success: true , count: result[0].count, total: result[0].total });
				} else{
					res.json({ success: true , count: 0, total: 0 });
				}
			});
		} else {
			OrderModel.paginate(Query,Paginator, function(err, result) {
				if(err){
					res.json({success:false,message:'Algo Salio mal.'});
				}
				res.json({success: true , orders: result});
			});
		}
	},
	LastByUser: function(req,res){
		OrderModel.findOne({user_id:req.params.user_id}, {sort:{$natural:-1}}).exec(function(err,Order){
			if(err){
				return res.json({success:false,message:'Algo Salio mal.'});
			}
			res.json({success: true , order:Order});

		});
	},
	ById: function(req,res){
		OrderModel.findById(req.params.order_id)
		.populate({ path: 'user_id', select: '_id name phone rate typeuser email push_id'})
		.populate({ path: 'vendor_id', select: '_id name phone rate typeuser email marketname push_id'})
		.exec(function(err,Order){
			if(err){
				return res.json({success:false,message:'Algo Salio mal.'});
			}
			res.json({success: true , order:Order});

		});
	},
	UpdateById: function(req,res){
		OrderModel.findById(req.params.order_id, function(err, Order){
			if(err){
				return res.json({success:false,message:'Algo Salio mal.'});
			}
			if (req.body.user_id) {
				Order.user_id = req.body.user_id;
			}
			if (req.body.vendor_id) {
				Order.vendor_id = req.body.vendor_id;
			}
			if (req.body.products) {
				Order.products = req.body.products;
			}
			if (req.body.total) {
				Order.total = req.body.total;
			}
			if (req.body.destiny) {
				Order.destiny = req.body.destiny;
			}
			if (req.body.status) {
				Order.status = req.body.status;
			}
			if (req.body.transaction) {
				Order.transaction = req.body.transaction;
			}
			Order.save(function(err){
				if(err){
					return res.json({success:false,message:'Algo Salio mal.'});
				}
				return res.json({success:true,message:'Orden actualizada correctamente.'});
			});
		});
	},
	DeleteById: function(req,res){
		OrderModel.remove({ _id: req.params.order_id }, function(err,Order) {
				if(err){
					return res.json({success:false,message:'Algo Salio mal.'});
				}
				res.json({success: true , message:"Order Borrado Exitosamente."});
			}
		);
	}
}
