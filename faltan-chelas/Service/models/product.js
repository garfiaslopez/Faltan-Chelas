var mongoose = require("mongoose");
var Schema = mongoose.Schema;

var ProductSchema = new Schema({

	denomination: {
		type: String,
		trim: true,
		required: true,
	},
	prices: [{
		quantity: {type: String},
		price: {type: Number}
	}],
	type:{
		type: String
	},
	description: {
		type: String,
		trim: true
	},
    date: {
        type: Date,
        default: Date.now()
    }

});

//Return the module
module.exports = mongoose.model("Product",ProductSchema);
