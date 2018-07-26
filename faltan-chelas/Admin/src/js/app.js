var app = angular.module('FCApp',['RouterCtrl','AuthService','FCService','btford.socket-io','ngMaterial','md.data.table']);

app.config(function($mdIconProvider, $httpProvider, $mdThemingProvider){

    $mdIconProvider
        .icon("menu", "../src/images/icons/menu.svg"        , 24)
        .icon("user", "../src/images/icons/account4.svg"    , 24)
        .icon("commercializer", "../src/images/icons/front17.svg"    , 24)
        .icon("sell", "../src/images/icons/clipboard99.svg"    , 24)
        .icon("product", "../src/images/icons/shopping232.svg"    , 24)
        .icon("dashboard", "../src/images/icons/bed24.svg"    , 24)
        .icon("services", "../src/images/icons/circles23.svg"    , 24)
        .icon("delete", "../src/images/icons/cancel19.svg"    , 24)
        .icon("userlogin", "../src/images/icons/account4.svg"    , 120)
        .icon("logout", "../src/images/icons/thermostat1.svg"    , 120)
        .icon("configurations", "../src/images/icons/settings49.svg"    , 120)
        .icon("info", "../src/images/icons/round52.svg"    , 120)
        .icon("usercircle", "../src/images/icons/round58.svg"    , 120)
        .icon("help", "../src/images/icons/help19.svg"    , 120);

    $httpProvider.interceptors.push('AuthInterceptor');

    $mdThemingProvider.theme('default')
        .primaryPalette('grey', {
            'default': '900'
        })
        .accentPalette('red');

});
