angular.module('UserAdminCtrl',[]).controller('UserAdminController',function($scope,$mdDialog,UserAdminServ){

	var self = this;

	//initialize 'seccion'
	self.Usuario = {
		username: null,
		password: null
	}

	self.isEditing = {
		flag: false,
		id: null
	};

	function ClearTextFields(){

		self.Usuario.username = null;
		self.Usuario.password = null;

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
		self.UsersAdminOnDB = [];
		UserAdminServ.All().success(function(data){
			self.UsersAdminOnDB = data.usersadmin;
			console.log(self.UsersAdminOnDB);
		});	
	}

	ReloadData();

	self.Submit = function(){

		if (self.Usuario.username != undefined && 
			self.Usuario.password != undefined ){

			if(self.isEditing.flag){

				UserAdminServ.Update(self.isEditing.id,self.Usuario).success(function(data){

					if(data.success){
						Alerta('Administrador Actualizado.',data.message);

						ReloadData();
						ClearTextFields();

					}else{
						Alerta('Error',data.message);
					}

				}).error(function(data){
					Alerta('Error',data.message);
		       	});

			}else{		
				UserAdminServ.Create(self.Usuario).success(function(data){
					if(data.success){

						Alerta('Administrador Agregado.',data.message);

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

	self.Edit = function(UserAdminDB){

		ClearTextFields();

		self.Usuario.username = UserAdminDB.username;
		self.Usuario.password = UserAdminDB.password;

		self.isEditing.flag = true;
		self.isEditing.id = UserAdminDB._id;

	}

	self.CancelEditing = function(){
		ClearTextFields();
	}

	self.Delete = function(UserAdminDB){
		UserAdminServ.Delete(UserAdminDB._id).success(function(data){
			Alerta('Administrador Eliminado',data.message);
			ReloadData();
			ClearTextFields();
		}).error(function(data){
			Alerta('Error',data.message);
	    });
	}
});