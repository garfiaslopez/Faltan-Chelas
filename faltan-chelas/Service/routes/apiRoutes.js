 'use strict'
//  Module dependencies.

var AuthMidd = require("../middlewares/auth");
var AuthenticateFunctions = require("../controllers/authcontroller");

var UserFunctions = require("../controllers/usercontroller");
var UserAdminFunctions = require("../controllers/useradmincontroller");
var ConfigFunctions = require("../controllers/configcontroller");
var ProductFunctions = require("../controllers/productcontroller");
var OrderFunctions = require("../controllers/ordercontroller");
var HelpFunctions = require("../controllers/helpcontroller");
var ConektaFunctions = require("../controllers/conektacontroller");


module.exports = function(server) {

    //  Redirect request to controller
    server.post('/authenticate',AuthenticateFunctions.AuthByUser);
    server.post('/authenticate/admin',AuthenticateFunctions.AuthByUserAdmin);
    server.post('/authenticate/logoutuser',AuthenticateFunctions.LogOutUser);

    // Create user Endpoint
    server.post('/user',UserFunctions.Create);

    // Recover Password Endpoint
    server.post('/forgotpassword',UserFunctions.ForgotPassword);

    //the routes put before the middleware does not is watched.
    server.use(AuthMidd.AuthToken);

    server.get('/user',UserFunctions.All);
    server.get('/user/:user_id',UserFunctions.ById);
    server.put('/user/:user_id',UserFunctions.UpdateById);
    server.del('/user/:user_id',UserFunctions.DeleteById);
    server.post('/rateuser',UserFunctions.RateUserById);

    server.get('/users/byusers',UserFunctions.AllUsers);
    server.get('/users/byavailableusers',UserFunctions.AllAvailableUsers);
    server.get('/users/byvendors',UserFunctions.AllVendors);
    server.get('/users/byavailablevendors',UserFunctions.AllAvailableVendors);
    server.get('/users/byvendors/bylocation/:lat/:long',UserFunctions.SearchVendorsByLoc);
    server.get('/users/byavailablevendors/bylocation/:lat/:long',UserFunctions.SearchVendorsByStatus);

    server.post('/conekta/card',ConektaFunctions.CreateCard);
    server.get('/conekta/cards/:user_id',ConektaFunctions.AllCardsByUser);
    server.del('/conekta/card/:user_id/:card_id',ConektaFunctions.DelCardByUser);
    server.del('/conekta/user/:user_id/',ConektaFunctions.DelUser);

    server.post('/useradmin',UserAdminFunctions.Create);
    server.get('/useradmin',UserAdminFunctions.All);
    server.get('/useradmin/:useradmin_id',UserAdminFunctions.ById);
    server.put('/useradmin/:useradmin_id',UserAdminFunctions.UpdateById);
    server.del('/useradmin/:useradmin_id',UserAdminFunctions.DeleteById);

    server.post('/order',OrderFunctions.Create);
    server.get('/order',OrderFunctions.All);
    server.get('/order/:order_id',OrderFunctions.ById);
    server.put('/order/:order_id',OrderFunctions.UpdateById);
    server.del('/order/:order_id',OrderFunctions.DeleteById);

    server.get('/orders/LastByUser/:user_id',OrderFunctions.LastByUser);
    server.post('/orders/byFilters',OrderFunctions.Filter);

    server.post('/config',ConfigFunctions.Create);
    server.get('/config',ConfigFunctions.All);
    server.get('/config/:config_id',ConfigFunctions.ById);
    server.put('/config/:config_id',ConfigFunctions.UpdateById);
    server.del('/config/:config_id',ConfigFunctions.DeleteById);

    server.post('/product',ProductFunctions.Create);
    server.get('/product',ProductFunctions.All);
    server.get('/product/:product_id',ProductFunctions.ById);
    server.get('/products/bytype/:type',ProductFunctions.AllByType);
    server.put('/product/:product_id',ProductFunctions.UpdateById);
    server.del('/product/:product_id',ProductFunctions.DeleteById);

    server.post('/help',HelpFunctions.Create);
    server.get('/help',HelpFunctions.All);
    server.get('/help/:help_id',HelpFunctions.ById);
    server.put('/help/:help_id',HelpFunctions.UpdateById);
    server.del('/help/:help_id',HelpFunctions.DeleteById);


};
