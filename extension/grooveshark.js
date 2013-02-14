var inject = function (fn) {
	"use strict";
	var script = document.createElement("script");
	script.textContent = "(" + fn + ")();";
	(document.head || document.documentElement).appendChild(script);
	script.parentNode.removeChild(script);
};

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
		console.error("Whoops. Something went wrong.");
	};
	wSocket.onmessage = function (msg) {
		var kcode = msg.data.charCodeAt(0);
		console.log("Received key code " + kcode + ".");
		if (kcode === 20) {
			console.log("Previous song.");
			inject(function () {
				// access to window.Grooveshark
				// through injected JS script
				window.Grooveshark.previous();
			});
		}
		else if (kcode == 16) {
			console.log("Play/pause.");
		}
		else if (kcode == 19) {
			console.log("Next song.");
			inject(function () {
				window.Grooveshark.next();
			});
		}
	};
	wSocket.onclose = function () {
		console.log("Connection to " + host + ":" + port + " closed.");
	};
}();
