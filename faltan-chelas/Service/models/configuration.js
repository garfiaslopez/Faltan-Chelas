var mongoose = require("mongoose");
var Schema = mongoose.Schema;

var ConfigSchema = new Schema({

	denomination: {
		type: String,
		trim: true,
		required: true,
	},
	parameter: {
		type: String,
		trim: true,
		required: true,
	},
    date: {
        type: Date,
        default: Date.now()
    }

});

//Return the module
module.exports = mongoose.model("Configuration",ConfigSchema);
