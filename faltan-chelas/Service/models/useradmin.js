var mongoose = require("mongoose");
var Schema = mongoose.Schema;
var bcrypt = require("bcrypt-nodejs");

var UserSchema = new Schema({

	password: {
		type: String,
		required: true,
		select: false
	},
	username: {
		type: String,
		trim: true,
	},
    date: {
        type: Date,
        default: Date.now()
    }

});

function hashPassword(next){

	var user = this;

	if(!user.isModified("password")){
		return next();
	}

	bcrypt.hash(user.password, null, null, function(err,hash){

		if(err){
			return next(err);
		}

		user.password = hash;
		next();
	})
}

UserSchema.pre("save", hashPassword);

function isEqualPassword(password){
	var user = this;
	return bcrypt.compareSync(password,user.password);
}

UserSchema.methods.comparePassword = isEqualPassword;

//Return the module
module.exports = mongoose.model("UserAdmin",UserSchema);
