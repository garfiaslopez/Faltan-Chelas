angular.module('VendorCtrl',[]).controller('VendorController',function($rootScope,$location,$scope,$mdSidenav,$mdDialog,Auth,VendorServ){

	var self = this;

	function ReloadData(){
		self.VendorsOnDB = [];
		VendorServ.All().success(function(data){
			console.log(data);
			self.VendorsOnDB = data.users;
			console.log(self.VendorsOnDB);
		});
	}

	ReloadData();

	self.Detail = function (VendorDB){
       	var parentEl = angular.element(document.body);
		$mdDialog.show({
         	parent: parentEl,
         	template:
		           '<md-dialog aria-label="List dialog">' +
		           '  	<md-dialog-content>'+
		           '    	<md-list>'+
		           '      		<md-list-item>'+
		           '       			<p>Name: 	{{info.name}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Phone: 	{{info.phone}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Tienda: 	{{info.marketname}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Genero: 	{{info.gender}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Fecha Nac : 	{{info.birthdate}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Nombre: 	{{info.othercontact.name}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Telefono: 	{{info.othercontact.phone}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Nombre: 	{{info.paydata.name}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>Banco: 	{{info.paydata.bank}}</p>' +
		           '      		</md-list-item>' +
		           '      		<md-list-item>'+
		           '       			<p>CLABE: 	{{info.paydata.clabe}}</p>' +
		           '      		</md-list-item>' +
		           '		</md-list>'+
		           '  	</md-dialog-content>' +
		           '  	<div class="md-actions">' +
		           '    	<md-button ng-click="closeDialog()" class="md-primary">' +
		           '      		Cerrar' +
		           '    	</md-button>' +
		           '  	</div>' +
		           '</md-dialog>',
         	locals: {
           		info: VendorDB
         	},
          	controller: function DialogController($scope, $mdDialog) {
            	$scope.closeDialog = function() {
              		$mdDialog.hide();
            	}
            	$scope.info = VendorDB;
          	}
        });
	}

	self.Delete = function(VendorDB){
		VendorServ.Delete(VendorDB._id).success(function(data){
			Alerta('Repartidor Eliminado',data.message);
			ReloadData();
		}).error(function(data){
			Alerta('Error',data.message);
	    });

	};

	self.Submit = function(){
		if (self.Usuario != undefined &&
			self.Usuario.email != undefined &&
			self.Usuario.password != undefined &&
			self.Usuario.name != undefined &&
			self.Usuario.marketname != undefined &&
			self.Usuario.phone != undefined &&
			self.Usuario.gender != undefined &&
			self.Usuario.birthdate != undefined &&
			self.Usuario.paydata != undefined &&
			self.Usuario.loc != undefined &&
			self.Usuario.othercontact != undefined ){

			self.Usuario.typeuser = "vendor";
			VendorServ.Create(self.Usuario).success(function(data){
				if(data.success){
					self.VendorSaved = true;
					Alerta('Vendedor Agregado.',data.message);
					$location.path("/Vendedores");
				}else{
					Alerta('Error',data.message);
				}
			}).error(function(data){
				Alerta('Error',data.message);
	       	});
		}else{
			Alerta('Datos Incompletos','Favor de rellenar todos los campos.');
		}
	}


	function Alerta(title, message){
		$mdDialog.show( $mdDialog.alert()
	        .parent(angular.element(document.body))
	        .title(title)
	        .content(message)
	        .ariaLabel('Alert Dialog Demo')
	        .ok('OK')
		).finally(function() {
			if(self.VendorSaved){
        		$location.path("/Vendedores");
			}
        });
	}
});
