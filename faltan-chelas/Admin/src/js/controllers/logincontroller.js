var app = angular.module('LoginApp',['ngMaterial','AuthService']);

app.config(function($mdIconProvider,$mdThemingProvider){

    $mdIconProvider
      .icon("pass", "../src/images/icons/locked57.svg"        , 24)
      .icon("user", "../src/images/icons/account4.svg"    , 24)
      .icon("userlogin", "../src/images/icons/account4.svg"    , 120);

    $mdThemingProvider.theme('default')
        .primaryPalette('blue')
        .accentPalette('red');

});

app.controller('LoginController',function($scope,$mdDialog,Auth){

	var vm = $scope;

	vm.doLogin = function(loginData) {

		console.log("LoginData: " + loginData);

     	Auth.LoginAdmin(loginData.username, loginData.password)
     		.success(function(data) {

                if(data.success){

                    window.location = '/';

                }else{
                    "ERRORsadjklasjdlkas"
                    $mdDialog.show(
                      $mdDialog.alert()
                        .parent(angular.element(document.body))
                        .title('Error Al Iniciar Sesion.')
                        .content(data.message)
                        .ariaLabel('Alert Dialog Demo')
                        .ok('OK')
                    );
                }
       		})
       		.error(function(data){
                console.log("ERROR");
                console.log(data);
        		$mdDialog.show(
				      $mdDialog.alert()
				        .parent(angular.element(document.body))
				        .title('Error Al Iniciar Sesion.')
				        .content(data.message)
				        .ariaLabel('Alert Dialog Demo')
				        .ok('OK')
			    );

       		});

   	};

});
