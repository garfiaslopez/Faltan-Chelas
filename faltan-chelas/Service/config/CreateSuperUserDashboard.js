var mongoose = require("mongoose");
var Schema = mongoose.Schema;
var bcrypt = require("bcrypt-nodejs");

process.env.NODE_ENV = process.env.NODE_ENV || 'development';

var config = require('./config');
var dbMongo = mongoose.connect(config.mongodb);
var key = config.key;

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

//HASH THE PASSWORD USER BEFORE IS SAVED:
function hashPassword(next){

	var user = this;

	//hash only if the user is new or have been modified.
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

var AdminModel = mongoose.model('UserAdmin', UserSchema);

var Administrador = new AdminModel({
	username: "faltanchelasadmin",
	password: "awesomepassword",
});

Administrador.save(function(err){

	if(err){
		//entrada duplicada
		if(err.code == 11000){
			console.log("ERROR THAT USER ALREADY EXISTS");
		}else{
			return console.log(err);
		}
	}
	console.log("SUCCESFULLY ADMIN REGISTRATION");
});
