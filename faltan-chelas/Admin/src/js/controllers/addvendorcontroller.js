angular.module('AddVendorCtrl',[]).controller('AddVendorController',function($scope,$mdDialog,$location,VendorServ){
	
	var self = this;

	self.VendorSaved = false;

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

	self.Submit = function(){

		if (self.Usuario != undefined && 
			self.Usuario.email != undefined && 
			self.Usuario.type != undefined && 
			self.Usuario.password != undefined && 
			self.Usuario.name != undefined && 
			self.Usuario.marketname != undefined && 
			self.Usuario.phone != undefined && 
			self.Usuario.gender != undefined && 
			self.Usuario.birthdate != undefined && 
			self.Usuario.paydata != undefined && 
			self.Usuario.othercontact != undefined ){

			if(self.Usuario.loc.lon == undefined){
				self.Usuario.loc.lon = 0.00;
			}
			if(self.Usuario.loc.lat == undefined){
				self.Usuario.loc.lat = 0.00;
			}
			if(self.Usuario.loc.denomination == undefined){
				self.Usuario.loc.denomination = "Sin Direccion";
			}
			


			VendorServ.Create(self.Usuario).success(function(data){
				if(data.success){
					self.VendorSaved = true;
					Alerta('Vendedor Agregado.',data.message);
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
});