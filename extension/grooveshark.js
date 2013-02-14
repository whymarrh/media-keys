!function (undefined) {
	"use strict";
	var host = "127.0.0.1",
	    port = "8800",
	    protocol = "media-keys",
	    wSocket = new window.WebSocket("ws://" + host + ":" + port + "/", protocol);
	wSocket.onopen = function () {
		console.log("Connection established to " + host + ":" + port + ".");
	};
	wSocket.onerror = function () {
		console.error("Oops. Something went wrong.");
	};
	wSocket.onmessage = function (msg) {
		console.log("Received character code " + msg.data.charCodeAt(0) + ".");
	};
	wSocket.onclose = function () {
		console.log("Connection to " + host + ":" + port + " closed.");
	};
}();
