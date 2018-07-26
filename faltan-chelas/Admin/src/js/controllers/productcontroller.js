angular.module('ProductCtrl',[]).controller('ProductController',function($scope,$mdDialog,ProductServ){

	var self = this;

//initialize 'seccion'
	self.Producto = {
		denomination: null,
		description: null,
		type: "primary",
		prices: null
	}

	self.Precio = {
		quantity: null,
		price: null
	}

	self.EditingProduct = {
		flag: false,
		id: null
	};

	self.EditingPrice = {
		flag: false,
		id: null
	};

	function ClearProducto(){

		self.Producto.denomination = null;
		self.Producto.description = null;
		self.Producto.type = "primary";
		self.Producto.prices = null;

		self.EditingProduct.flag = false;
		self.EditingProduct.id = null;
	}

	function ClearPrecio(){

		self.ProductSelected = null;


		self.Precio.quantity = null;
		self.Precio.price = null;

		self.EditingPrice.flag = false;
		self.EditingPrice.id = null;
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
		self.ProductsOnDB = [];
		ProductServ.All().success(function(data){
			self.ProductsOnDB = data.products;
			console.log(self.ProductsOnDB);
		});	
	}

	ReloadData();


	self.SubmitProduct = function(){

		console.log(self.Producto);

		if (self.Producto.denomination != undefined && 
			self.Producto.type != undefined ){

			if(self.EditingProduct.flag){

				ProductServ.Update(self.EditingProduct.id,self.Producto).success(function(data){

					if(data.success){
						Alerta('Producto Actualizado.',data.message);

						ReloadData();
						ClearProducto();

					}else{
						Alerta('Error',data.message);
					}

				}).error(function(data){
					Alerta('Error',data.message);
		       	});

			}else{		
				ProductServ.Create(self.Producto).success(function(data){
					if(data.success){

						Alerta('Producto Agregado.',data.message);

						ReloadData();
						ClearProducto();

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


	self.SubmitPrice = function(){

		angular.forEach(self.ProductsOnDB, function(product, key) {
			if(product._id == self.ProductSelected){
				self.ProductoPrice = product;
			}
		});

		if (self.Precio.quantity != undefined && 
			self.Precio.price != undefined ){

			if(self.EditingPrice.flag){

				angular.forEach(self.ProductoPrice.prices, function(price, key) {
					if(price._id == self.EditingPrice.id){
						price.quantity = self.Precio.quantity;
						price.price = self.Precio.price;
					}
				});


				ProductServ.Update(self.ProductoPrice._id,self.ProductoPrice).success(function(data){

					if(data.success){

						Alerta('Precio Actualizado.');

						ReloadData();
						ClearPrecio();

					}else{
						Alerta('Error',data.message);
					}
				}).error(function(data){
					Alerta('Error',data.message);
		       	});

			}else{		
				self.ProductoPrice.prices.push(self.Precio);

				ProductServ.Update(self.ProductoPrice._id,self.ProductoPrice).success(function(data){

					if(data.success){

						Alerta('Precio Agregado.');

						ReloadData();
						ClearPrecio();

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

	self.EditProduct = function(ProductDB){
	
		console.log(ProductDB);

		self.Producto = {};

		self.Producto.denomination = ProductDB.denomination;
		self.Producto.description = ProductDB.description;
		self.Producto.type = ProductDB.type;

		self.EditingProduct.flag = true;
		self.EditingProduct.id = ProductDB._id;

	};

	self.EditPrice = function(ProductDB,PriceDB){
	
		console.log(PriceDB);

		self.Precio = {};

		self.ProductSelected = ProductDB._id;

		self.Precio.quantity = PriceDB.quantity;
		self.Precio.price = PriceDB.price;

		self.EditingPrice.flag = true;
		self.EditingPrice.id = PriceDB._id;

	};

	self.DeleteProduct = function(ProductDB){

		ProductServ.Delete(ProductDB._id).success(function(data){
			Alerta('Producto Eliminado',data.message);
			ReloadData();
			ClearProducto();
		}).error(function(data){
			Alerta('Error',data.message);
	    });

	};


	self.DeletePrice = function(ProductDB,PriceDB){

		console.log(ProductDB);
		console.log(PriceDB);

		var index = ProductDB.prices.indexOf(PriceDB);
  		ProductDB.prices.splice(index, 1);

		ProductServ.Update(ProductDB._id,ProductDB).success(function(data){

			if(data.success){
				Alerta('Precio Eliminado.');

				ReloadData();
				ClearPrecio();

			}else{
				Alerta('Error',data.message);
			}

		}).error(function(data){
			Alerta('Error',data.message);
       	});
	    
	};



	self.CancelProduct = function(){
		ClearProducto();
	};	
	self.CancelPrice = function(){
		ClearPrecio();
	};


});