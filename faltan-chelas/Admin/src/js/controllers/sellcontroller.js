angular.module('SellCtrl',[]).controller('SellController',function($scope,$mdDialog,SellServ){

	var vc = this;

	//DatePickerConfiguration:
	vc.options = {
	  	format: 'yyyy-mm-dd', 
	  	formatSubmit: 'yyyy-mm-dd',
		monthsFull: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
		monthsShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
		weekdaysFull: ['Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'],
		weekdaysShort: ['Dom', 'Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab'],
		today: 'Hoy',
		clear: 'Cerrar',
		firstDay: 1
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

	//vars Initialization:
	vc.FilterSelected = "0";
	vc.DisableRange=true;

	//i cant reset the dates for the picker.....
	function ClearDateTexts(){
		vc.FechaInicio = undefined;
		vc.FechaFinal = undefined;
	}

	vc.FilterChanged = function(){
		console.log(vc.FilterSelected);
		if(vc.FilterSelected == 4){
			vc.DisableRange=false;
		}else{
			ClearDateTexts();
			vc.DisableRange=true;
		}
	}

	function ReloadData(){

		var initialDate;
		var finalDate;

		vc.isLoading = true;

		switch (vc.FilterSelected) {
		    case "0":
				initialDate = moment().format('YYYY-MM-DD');
				finalDate = moment().add(1, 'days').format('YYYY-MM-DD');		        
				break;
		    case "1":
				initialDate = moment().startOf('isoweek').format('YYYY-MM-DD');
				finalDate = moment().add(1, 'days').format('YYYY-MM-DD');
				break;
		    case "2":
				initialDate = moment().startOf('month').format('YYYY-MM-DD');
				finalDate = moment().add(1, 'days').format('YYYY-MM-DD');
		        break;
		    case "3":
				initialDate = moment().startOf('year').format('YYYY-MM-DD');
				finalDate = moment().add(1, 'days').format('YYYY-MM-DD');
		        break;
		    case "4":
		    	console.log("ini: " + vc.FechaInicio + "  fin: " + vc.FechaFinal);
				initialDate = moment(vc.FechaInicio).format('YYYY-MM-DD');
				finalDate = moment(vc.FechaFinal).add(1,'days').format('YYYY-MM-DD');
		        break;
		}

		SellServ.AllByDate(initialDate,finalDate).success(function(data){
			if(data.success){
				vc.SellsOnDB = data.sells;
				vc.CountSells = vc.SellsOnDB.length;
				var total = 0;
				angular.forEach(vc.SellsOnDB, function(sell, key) {
					total = total + sell.total;
					sell.date = moment(sell.date).format('YYYY-MM-DD');
				});
				vc.TotalSells = total;
			}else{
				Alerta('Error',data.message);
			}
		}).error(function(data){
			Alerta('Error',data.message);
       	});
	}

	ReloadData();

	vc.Search = function(){
		ReloadData();
	}


});