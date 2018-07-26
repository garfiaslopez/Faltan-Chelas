var Config = require("../config/config");
var mongoose = require("mongoose");
var Schema = mongoose.Schema;
var bcrypt = require("bcrypt-nodejs");
var autoIncrement = require('mongoose-auto-increment');
var mongoosePaginate = require('mongoose-paginate');
var moment = require('moment');

var connection = mongoose.createConnection(Config.mongodb);
autoIncrement.initialize(connection);

var OrderSchema = new Schema({
	user_id: {
        type: Schema.ObjectId,
        ref: 'User'
	},
	vendor_id: {
        type: Schema.ObjectId,
        ref: 'User'
	},
	order_id: {
		type: Number
	},
	products: [{
		denomination: {
			type: String
		},
		price: {
			type: Number
		},
		quantity: {
			type: Number
		},
		units: {
			type: Number
		}
	}],
	total: {
		type: Number
	},
	destiny: {
		denomination: String,
		cord: {
    		type: [Number],
    		index: '2dsphere'
		}
	},
	aditionalInfo: {
		type: String,
		default: "Sin Informacion Adicional."
	},
	status: {
		type: String,
		default: "Normal"
	},
	paymethod: {
		type: String
	},
	isPaid: {
		type: Boolean,
		default: false,
	},
	transaction_id: {
		type: String
	},
    date: {
        type: Date,
        default: moment().utc()
    }
});


OrderSchema.plugin(autoIncrement.plugin, {
	model: 'Order',
	field: 'order_id',
	startAt: 1,
    incrementBy: 1
});
OrderSchema.plugin(mongoosePaginate);

module.exports = mongoose.model("Order",OrderSchema);
