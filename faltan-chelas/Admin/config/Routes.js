module.exports = function(root,app,express){

	function AdministerPage(req,res){
		res.sendFile(root + '/src/pages/index.html');
	}
	function LoginPage(req,res){
		res.sendFile(root + '/src/pages/login.html');
	}
	//STATIC ROUTES:
	app.use("/src", express.static(root + "/src"));
	app.use("/bower_components", express.static(root + "/bower_components"));
	app.get('/',AdministerPage);
	app.get("/login",LoginPage);
	//put the index to homepage

}
