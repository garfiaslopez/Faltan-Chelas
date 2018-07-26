var AuthServices = angular.module('AuthService',[]);


var configData = {
	APIURL: 'http://faltanchelas.com:3000'
	//APIURL: 'http://localhost:3000'
}

AuthServices.factory("Auth",function($http,$q,AuthToken){

	var AuthFactory = {};
	AuthFactory.LoginAdmin = function(username,password){
		console.log("LOGIN ADMIN");
		var Url = configData.APIURL + "/authenticate/admin";
		console.log(Url);
		return $http.post(Url , {
			username: username,
			password: password
		}).success(function(data){
			console.log('success');
			console.log(data);
			AuthToken.SetToken(data.token);
			return data;
		});
	}
	AuthFactory.Login = function(username,password){
		var Url = configData.APIURL + "/authenticate";
		return $http.post(Url , {
			username: username,
			password: password
		}).success(function(data){
			console.log(data);
			AuthToken.SetToken(data.token);
			return data;
		});
	}
	AuthFactory.LogOut = function(){
		AuthToken.SetToken();
	}
	AuthFactory.isLoggedIn = function(){

		if(AuthToken.GetToken()){
			return true;
		}else{
			return false;
		}

	}
	AuthFactory.GetUser = function(){
		if (AuthToken.GetToken()) {
			return $http.get("/api/me");
		}else{
			return $q.reject({message:"User has no token"});
		}
	}
	return AuthFactory;
});


AuthServices.factory("AuthToken", function($window){
	var AuthTokenFactory = {};
	//get the token from localstorage from browser
	AuthTokenFactory.GetToken = function(){
		return $window.localStorage.getItem("token-FC");
	}
	//guardar el token en localstorage:
	AuthTokenFactory.SetToken = function(token){
		if(token){
			$window.localStorage.setItem("token-FC",token);
		}else{
			$window.localStorage.removeItem("token-FC");
		}
	}
	return AuthTokenFactory;
});

AuthServices.factory("AuthInterceptor",function($q, $location, AuthToken){
	var InterceptorFactory = {};
	InterceptorFactory.request = function(config){
		var token = AuthToken.GetToken();
		if(token){
			config.headers["Authorization"] = token;
		}
		return config;
	}
	InterceptorFactory.ResponseError = function(response){
		if(response.status == 403){
			AuthToken.SetToken();
			$location.path("/");
		}
		return $q.reject(response);
	}
	return InterceptorFactory;
});
