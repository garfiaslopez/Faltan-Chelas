angular.module('ConfigCtrl',[]).controller('ConfigController',function($scope,$mdDialog,UserAdminServ,ConfigServ){

	var self = this;

	//initialize 'seccion'
	self.Configuracion = {
		denomination: null,
		parameter: null
	}

	self.isEditing = {
		flag: false,
		id: null
	};

	function ClearTextFields(){

		self.Configuracion.denomination = null;
		self.Configuracion.parameter = null;

		self.isEditing.flag = false;
		self.isEditing.id = null;
	}

	function Alerta(title, message){

		$mdDialog.show( $mdDialog.alert()
	        .parent(angular.element(document.body))
	        .title(title)
	        .content(message)
	        .ariaLabel('Alert Dialog Demo')
	        .ok('OK')
		);

	}

	function ReloadData(){
		self.ConfigsOnDB = [];
		ConfigServ.All().success(function(data){
			self.ConfigsOnDB = data.configs;
			console.log(self.ConfigsOnDB);
		});	
	}

	ReloadData();

	self.Submit = function(){

		if (self.Configuracion.denomination != undefined && 
			self.Configuracion.parameter != undefined ){

			if(self.isEditing.flag){

				ConfigServ.Update(self.isEditing.id,self.Configuracion).success(function(data){

					if(data.success){
						Alerta('Configuracion Actualizada.',data.message);

						ReloadData();
						ClearTextFields();

					}else{
						Alerta('Error',data.message);
					}

				}).error(function(data){
					Alerta('Error',data.message);
		       	});

			}else{		
				ConfigServ.Create(self.Configuracion).success(function(data){
					if(data.success){

						Alerta('Configuracion Agregada.',data.message);

						ReloadData();
						ClearTextFields();

					}else{
						Alerta('Error',data.message);
					}
				}).error(function(data){
					Alerta('Error',data.message);
		       	});
			}
		}else{
			Alerta('Datos Incompletos','Favor de rellenar todos los campos.');
		}
	}

	self.Edit = function(ConfigDB){

		ClearTextFields();

		self.Configuracion.denomination = ConfigDB.denomination;
		self.Configuracion.parameter = ConfigDB.parameter;

		self.isEditing.flag = true;
		self.isEditing.id = ConfigDB._id;

	}

	self.CancelEditing = function(){
		ClearTextFields();
	}

	self.Delete = function(ConfigDB){
		ConfigServ.Delete(ConfigDB._id).success(function(data){
			Alerta('Configuracion Eliminada',data.message);
			ReloadData();
			ClearTextFields();
		}).error(function(data){
			Alerta('Error',data.message);
	    });
	}
});