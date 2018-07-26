var FCService = angular.module('FCService',['ngRoute']);

var ApiUrl = 'http://faltanchelas.com:3000';
//var ApiUrl = 'http://localhost:3000';

FCService.factory("Socket",function($http,$q,socketFactory){

	var Url = ApiUrl
    var myIoSocket = io.connect(Url);
    mySocket = socketFactory({
        ioSocket: myIoSocket
    });
    return mySocket;
});

FCService.factory("UserAdminServ",function($http,$q){

	var Obj = {};
	var Url = ApiUrl + "/useradmin"

	Obj.Create = function(Data){
		return $http.post(Url,Data).success(function(data){
			return data;
		});
	}

	Obj.All = function(){
		return $http.get(Url).success(function(data){
			return data;
		});
	}

	Obj.Update = function(Id,Data){

		var UpdateUrl = Url +'/'+ Id;

		return $http.put(UpdateUrl,{
			username: Data.username,
			password: Data.password
		}).success(function(data){
			return data;
		});
	}
	Obj.Delete = function(Id){

		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}
	return Obj;
});

FCService.factory("UserServ",function($http,$q){

	var Obj = {};

	var Url = ApiUrl + "/user"

	Obj.All = function(){
		return $http.get(Url).success(function(data){
			return data;
		});
	}

	Obj.Update = function(Id,Data){

		var UpdateUrl = Url +'/'+ Id;

		return $http.put(UpdateUrl,{
			username: Data.username,
			password: Data.password
		}).success(function(data){
			return data;
		});
	}
	Obj.Delete = function(Id){

		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}
	return Obj;
});


FCService.factory("VendorServ",function($http,$q){

	var Obj = {};
	var Url = ApiUrl + "/user"

	Obj.Create = function(Data){

		return $http.post(Url,Data).success(function(data){
			return data;
		});
	}

	Obj.All = function(){
		var URL = ApiUrl +  "/users/byvendors";
		console.log(URL);
		return $http.get(URL).success(function(data){
			return data;
		});
	}

	Obj.Update = function(Id,Data){

		var UpdateUrl = Url +'/'+ Id;
		return $http.put(UpdateUrl,Data).success(function(data){
			return data;
		});
	}
	Obj.Delete = function(Id){

		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}
	return Obj;
});


FCService.factory("ConfigServ",function($http,$q){

	var Obj = {};
	var Url = ApiUrl + "/config"

	Obj.Create = function(Data){

		return $http.post(Url, Data).success(function(data){
			return data;
		});
	}

	Obj.All = function(){
		return $http.get(Url).success(function(data){
			return data;
		});
	}

	Obj.Update = function(Id,Data){

		var UpdateUrl = Url +'/'+ Id;

		return $http.put(UpdateUrl,Data).success(function(data){
			return data;
		});
	}
	Obj.Delete = function(Id){

		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}
	return Obj;
});


FCService.factory("ProductServ",function($http,$q){

	var Obj = {};
	var Url = ApiUrl + "/product"

	Obj.Create = function(Data){

		return $http.post(Url, Data).success(function(data){
			return data;
		});
	}

	Obj.All = function(){
		return $http.get(Url).success(function(data){
			return data;
		});
	}

	Obj.Update = function(Id,Data){

		var UpdateUrl = Url +'/'+ Id;

		return $http.put(UpdateUrl,Data).success(function(data){
			return data;
		});

	}
	Obj.Delete = function(Id){
		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}
	return Obj;
});

FCService.factory("SellServ",function($http,$q){
	var Obj = {};
	var Url = ApiUrl + "/sell"

	Obj.AllByDate = function(initialDate,finalDate){
		return $http.post(Url, {
			initialDate: initialDate,
			finalDate: finalDate
		}).success(function(data){
			return data;
		});
	}

	return Obj;
});


FCService.factory("HelpServ",function($http,$q){

	var Obj = {};
	var Url = ApiUrl + "/help"

	Obj.All = function(){
		return $http.get(Url).success(function(data){
			return data;
		});
	}

	Obj.Delete = function(Id){
		var DeleteUrl = Url +'/'+ Id;
		return $http.delete(DeleteUrl).success(function(data){
			return data;
		});
	}

	return Obj;
});

FCService.factory("OrderServ",function($http,$q){
	var Obj = {};
	var Url = ApiUrl + "/orders"

	Obj.AllByFilter = function(Filter){
		var newUrl = Url + '/byFilters';
		return $http.post(newUrl, Filter).success(function(data){
			return data;
		});
	}

	return Obj;
});
