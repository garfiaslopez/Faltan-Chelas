angular.module('UserCtrl',[]).controller('UserController',function($scope,$mdDialog,UserServ){

	var self = this;

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
		self.UsersOnDB = [];
		UserServ.All().success(function(data){
			self.UsersOnDB = data.users;
			console.log(self.UsersOnDB);
		});	
	}

	ReloadData();


	self.Delete = function(UserDB){

		UserServ.Delete(UserDB._id).success(function(data){
			Alerta('Usuario Eliminado',data.message);
			ReloadData();
		}).error(function(data){
			Alerta('Error',data.message);
	    });

	};


});