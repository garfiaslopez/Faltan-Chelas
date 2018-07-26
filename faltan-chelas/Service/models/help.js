var mongoose = require("mongoose");
var Schema = mongoose.Schema;

var HelpSchema = new Schema({

    user_id: {
        type: Schema.ObjectId,
        ref: 'User'
	},
	subject: {
		type: String,
		trim: true
    },
	description: {
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
module.exports = mongoose.model("Help",HelpSchema);
