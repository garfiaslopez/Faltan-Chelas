//MODELS
var Config = require("../config/config");

var UserModel = require("../models/user");
var conekta = require('conekta');
conekta.api_key = Config.ConektaApiKey;
conekta.locale = 'es';


module.exports = {

	CreateCard: function(req,res){
        //BODY {card_token, user_id}
        if(req.body.card_token && req.body.user_id){
            UserModel.findById( req.body.user_id, function(err, User){
                //some error
                if(err){
                    res.json({success: false , message: "Error fallo alguna validacion."});;
                }
                if(User.conektauser){
                    // add card to conektauser
                    conekta.Customer.find(User.conektauser, function(ErrorCustomer, customer) {
                        if(ErrorCustomer){
                            res.json({success: false , message: "Error al encontrar usuario conekta."});;
                        }
                        customer.createCard({token: req.body.card_token}, function(ErrorCard, newCard) {
                            if(ErrorCard){
                                res.json({success: false , message: "Error al crear tarjeta conekta"});
                            }
                            res.json({success: true , message: "Agregada Satisfactoriamente."});
                        });
                    });
                }else{
                    //create conekta user with card and save it.
                    var ConektaUser = {
                        name: User.name,
                        email: User.email.address,
                        phone: User.phone,
                        cards:[req.body.card_token]
                    }
                    conekta.Customer.create(ConektaUser, function(ErrorUser, newCustomer) {
                        if(ErrorUser){
                            res.json({success: false , message: "Error al crear usuario conekta"});
                        }
                        User.conektauser = newCustomer.toObject().id;
                        User.save(function(err){
                            if(err){
                                res.json({success: false , message: "Error fallo alguna validacion."});
                            }
                            res.json({success: true , message: "Tarjeta Agregada Satisfactoriamente."});
                        });
                    });
                }
            });
        }else{
            res.json({success: false , message: "Datos necesarios incompletos."});;
        }
	},

	AllCardsByUser: function(req,res){
        if(req.params.user_id){
            UserModel.findById( req.params.user_id, function(err, User){
				console.log(User);
                if(err){
                    res.json({success: false , message: "Error fallo alguna validacion."});;
                }
                if(User.conektauser){
                    conekta.Customer.find(User.conektauser, function(ErrorUser, customer) {
                        if(ErrorUser){
                            res.json({success: false , message: "Error al buscar usuario conekta"});
                        }
                        res.json({success: true , cards: customer.toObject().cards});
                    });
                }else{
                    res.json({success: true , cards: []});
                }
            });
        }else{
            res.json({success: false , message: "Datos necesarios incompletos."});;
        }

	},

	DelCardByUser: function(req,res){
        if(req.params.user_id && req.params.card_id){
            UserModel.findById( req.params.user_id, function(err, User){
                if(err){
                    res.json({success: false , message: "Error fallo alguna validacion."});;
                }
                if(User.conektauser){
                    conekta.Customer.find(User.conektauser, function(ErrorCustomer, customer) {
                        if(ErrorCustomer){
                            res.json({success: false , message: "Error fallo al buscar usuario conekta."});;
                        }
                        customer.cards.forEach(function(Card){
                            if(Card._id == req.params.card_id){
                                Card.delete(function(ErrorCard, CardRes) {
                                    if(ErrorCard){
                                        res.json({success: false , message: "Error fallo alguna validacion."});;
                                    }
                                    res.json({success: true , message: "Tarjeta eliminada correctamente."});
                                });
                            }
                        });
                    });
                }else{
                    res.json({success: false , message: "Este usuario aun no tiene tarjetas."});;
                }
            });
        }else{
            res.json({success: false , message: "Datos necesarios incompletos."});;
        }
	},

	DelUser: function(req,res){

	}

}
