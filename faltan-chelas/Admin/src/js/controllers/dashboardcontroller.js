angular.module('DashCtrl',[]).controller('DashboardController',function($scope,Socket,OrderServ){

	var self = this;
	self.actualPage = 1;

	function Alerta(title, message){
		$mdDialog.show( $mdDialog.alert()
			.parent(angular.element(document.body))
			.title(title)
			.content(message)
			.ariaLabel('Alert Dialog Demo')
			.ok('OK')
		);

	}


	self.onPaginate = function(nextPage) {
		self.actualPage = nextPage;
	}

	function ReloadData(){
		self.OrdersOnDB = [];
		var filter = {
			dateFilter: 'today',
			limit: 200,
			isTotals: false
		}
		OrderServ.AllByFilter(filter).success(function(data){
			self.OrdersOnDB = data.orders.docs;
			self.ordersTotal = 0.0;
			angular.forEach(self.OrdersOnDB, function(order){
				self.ordersTotal = self.ordersTotal + order.total;
			});
		});
	}
	ReloadData();

});
