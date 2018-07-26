angular.module('MainCtrl',[]).controller('MainController',function($rootScope,$location,$scope,$mdSidenav,Auth){


    if(Auth.isLoggedIn()){
        // console.log("islogged");
        // $location.path("/Dashboard");
        // $scope.Tittle = "Dashboard";
    }else{
        window.location = '/Login';
    }
	    //MENU TOGGLE:
    $scope.ShowMenu = function() {
        $mdSidenav('left').toggle();
    }

    $scope.CloseMenu = function() {
        $mdSidenav('left').close();
    }

    $scope.navigateTo = function(item){
    	$scope.CloseMenu();
    	$location.path(item.route);
        $scope.Tittle = item.name;

        angular.forEach($scope.MenuList, function(value, key) {
          value.selected = false;
        });

        item.selected = true;
    }

    $scope.LogOut = function(){
        Auth.LogOut();
        window.location = '/Login';
    }

    $scope.MenuList = [
        {
            name:"Dashboard",
            icon:"dashboard",
            route:"/",
            selected: true
        },
        {
            name:"Usuarios",
            icon:"user",
            route:"/Usuarios",
            selected: false

        },
        {
            name:"UsuariosAdmin",
            icon:"usercircle",
            route:"/UsuariosAdmin",
            selected: false

        },
        {
            name:"Vendedores",
            icon:"commercializer",
            route:"/Vendedores",
            selected: false

        },
        {
            name:"Productos",
            icon:"product",
            route:"/Productos",
            selected: false

        },
        {
            name:"Ventas",
            icon:"sell",
            route:"/Ventas",
            selected: false

        },
        {
            name:"Ayuda",
            icon:"help",
            route:"/Ayuda",
            selected: false

        },
        {
            name:"Configuraciones",
            icon:"configurations",
            route:"/Configuraciones",
            selected: false

        }



    ];

});
