var accessResolver = require("./accessresolver.js");
var store = require("./storage.js");
var utilities = require("./Utilities.js");
var authentication = require("./OAuth2.js");
var sqlHandle,utils,auth,access;

//empty constructor
function InternalWebService (){

	sqlHandle = new store ();
	utils = new utilities ();
	auth = new authentication ();
	access = new accessResolver();
}

//To DO just check the credentials and see if this is a legitimate request
InternalWebService.prototype.getUsers = function getUsers (req,response) {
	var accessCallback = function (err, user) {
		if(err == null) {
			if(user.role == 2 || user.role == 3 || user.role == 0){
				internalGetUsers (req,response,user.empID);
			}
			else {
				response.status(500).send ("User has no access to this API");
			}
		}
		else {
			response.status(500).send(err);
		}
	};

	//console.log(req.body.tokenID);
	access.determineUser (req.body.tokenID, accessCallback);
};

function internalGetUsers (req,response,supervisorID) {
	var callback = function (err,data) {
		if(err == null){
			response.send (JSON.stringify(data));
		}
		else {
			response.status(500).send (err);
		}
	}
	sqlHandle.getUserInfo(supervisorID,callback);
}

InternalWebService.prototype.getAvailableLeaves = function (req,response) {
	//TO-DO check if this is valid
	var accessCallback = function (err, user) {
		if(err == null) {
			if(user.role_id == 2 || user.role_id == 3 || user.role_id == 0 || user.role_id == 1){
				getLeavesForUser (req,response,user.emp_id);
			}
			else {
				response.status(500).send ("User has no access to this API");
			}
		}
		else {
			response.status(500).send(err);
		}
	};

	access.determineUser (req.body.tokenID, accessCallback);
};

function getLeavesForUser (req,response,empID) {
	var callback = function (err,data){
			if (err == null) {
				response.send(JSON.stringify(data));
			}
			else {
				response.status(500).send(error);
			}
		}
		sqlHandle.getAvailableLeaves(empID,callback);
}

InternalWebService.prototype.applyLeave = function (req,response) {

	var accessCallback = function (err, user) {
		if(err == null) {
			if(user.role_id == 2 || user.role_id == 3 || user.role_id == 0 || user.role_id == 1){
				internalApplyLeave (req,response,req.body.leaveRequest);
			}
			else {
				response.status(500).send ("User has no access to this API");
			}
		}
		else {
			response.status(500).send(err);
		}
	};
	access.determineUser (req.body.tokenID, accessCallback);
};

function internalApplyLeave (req,response,leaveRequest) {
	if(utils.validateDate(req.body.fromDate) && utils.validateDate(req.body.toDate)) {
		var callback = function (err,data) {
			if(err == null){
				response.send("Leave Application Successfull");
			}
			else {
				response.send(error);
			}
		}
		sqlHandle.insertLeaves (leaveRequest,callback);
		
	}
	else {
		response.send ("Invalid dates");
	}
}

InternalWebService.prototype.login = function (req, response) {

	var accessCallback = function (err, user) {
		console.log("callback triggered");
		if(err == null ) {
			console.log("creating user" + user);
			response.send("user");
			
		}
		else {
			console.log("login user" + err);
			response.status(500).send(err);
		}
	};

	//console.log(req.body.tokenID);
	access.determineUser (req.body.tokenID, accessCallback);
};



module.exports = InternalWebService;

