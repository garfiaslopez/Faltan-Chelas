angular.module('RouterCtrl',['ngRoute','MainCtrl','DashCtrl','UserCtrl','UserAdminCtrl','VendorCtrl','AddVendorCtrl','ProductCtrl','SellCtrl','HelpCtrl','ConfigCtrl']).config(function($routeProvider, $locationProvider){

		$routeProvider.when('/',{
			templateUrl: '../src/pages/dashboard.html',
			controller: 'DashboardController',
			controllerAs: 'Dashboard'

		}).when('/Usuarios',{
			templateUrl: '../src/pages/user.html',
			controller: 'UserController',
			controllerAs: 'User'

		}).when('/UsuariosAdmin',{
			templateUrl: '../src/pages/useradmin.html',
			controller: 'UserAdminController',
			controllerAs: 'UserAdmin'

		}).when('/Vendedores',{
			templateUrl:'../src/pages/vendor.html',
			controller:'VendorController',
			controllerAs:'Vendor'

		}).when('/AddVendedor',{
			templateUrl:'../src/pages/addvendor.html',
			controller:'AddVendorController',
			controllerAs:'AddVendor'
		}).when('/Productos',{
			templateUrl:'../src/pages/product.html',
			controller:'ProductController',
			controllerAs:'Product'
		}).when('/Ventas',{
			templateUrl:'../src/pages/sell.html',
			controller:'SellController',
			controllerAs:'Sell'
		}).when('/Ayuda',{
			templateUrl:'../src/pages/help.html',
			controller:'HelpController',
			controllerAs:'Help'
		}).when('/Configuraciones',{
			templateUrl:'../src/pages/config.html',
			controller:'ConfigController',
			controllerAs:'Config'
		});

	$locationProvider.html5Mode(true);

});
