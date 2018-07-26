
var request = require('request');

function BATCHPUSH(){
	var UrlToBatch = 'https://api.batch.com/1.0/DEV576B99498A2588AE5E76495BFAE/transactional/send';
	console.log(UrlToBatch);
	var Notification = {
		group_id: "FC_NewOrder",
		recipients: {
		    custom_ids: ['57708abec195ec0a5b9d8208']
		},
		priority: "high",
		message: {
		    title: "Prueba",
		    body: "BODY TEST FOR PUSH NOTIFICATIONS"
		},
		custom_payload: JSON.stringify({'Custom':'Data'})
	}
    var header = {
        'X-Authorization': 'c6e992f50666aacb5e329f10d58f8177'
    }
	console.log(MultiPart);
	request({method: 'POST', uri: UrlToBatch, headers: header, body: JSON.stringify(Notification) } , function(error, response, body) {
		if (error) {
			console.log(error);
		}
        console.log(body);
    });
}

function push(){
	var UrlToPush = "https://go.urbanairship.com/api/push";
	var Order = {
		"order":"order_id"
	}

	var Notification = {
		audience: {
			OR: [
				{ ios_channel:  "372d2c8a-c608-4467-9af2-4205bfd4f999" },
				{ android_channel: "372d2c8a-c608-4467-9af2-4205bfd4f999" }
			]
		},
		notification: {
			ios: {
				alert: "test Push Not",
				extra: Order
			},
			android: {
				alert: "test Push Not",
				extra: Order
			}
		},
		device_types: "all"
	}
	var Headers = {
		'Accept': 'application/vnd.urbanairship+json; version=3',
		'Content-Type': 'application/json'
	}
	var Auth = {
	    'user': '2S_HJOwvS5aPEvZZazjgrw',
	    'pass': '96YA2uRjTpmKvfrnGptOAQ'
	}
	request({method: 'POST', uri: UrlToPush, headers: Headers, auth: Auth, body: JSON.stringify(Notification) } , function(error, response, body) {
		if (error) {
			console.log(error);
		}
		console.log(body);
	});
}
push();
