//JSONWEBTOKEN
var jwt = require("jsonwebtoken");

//Config File
var Config = require("../config/config");
var KeyToken = Config.key;

module.exports = {

	AuthToken: function(req,res,next){
		var token = req.headers['authorization'] || req.body.Authorization;
		if(token){
			jwt.verify(token,KeyToken,{ignoreExpiration:true},function(err,decoded){
				if(err){
					res.json({success: false , message: "Token No Valido."});
				}else{
					req.decoded = decoded;
					next();
				}
			});
		}else{
			res.json({success: false , message: "Token No Valido."});
		}
	}
};
