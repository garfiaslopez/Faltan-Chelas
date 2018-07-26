angular.module('HelpCtrl',[]).controller('HelpController',function($scope,$mdDialog,HelpServ){

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
		self.HelpsOnDB = [];
		HelpServ.All().success(function(data){
			self.HelpsOnDB = data.helps;
			console.log(self.HelpsOnDB);
		});
	}

	ReloadData();

	self.Delete = function(HelpDB){

		HelpServ.Delete(HelpDB._id).success(function(data){
			Alerta('Ayuda Eliminada',data.message);
			ReloadData();
		}).error(function(data){
			Alerta('Error',data.message);
	    });

	};


});
