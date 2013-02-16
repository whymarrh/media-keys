var inject = function (fn) {

	"use strict";
	// content scripts for Chrome extensions run
	// in an isolated environment with no
	// access to the embedding page. Thus, one of the
	// ways to execute JS on the embedding page is to
	// literally inject it into the DOM.
	var script = document.createElement("script");
	script.textContent = "(" + fn + ")();";
	(document.head || document.documentElement).appendChild(script);
	script.parentNode.removeChild(script);

};

!function (undefined) {

	"use strict";
	var connected = false,
	host = "127.0.0.1",
	port = "9331",
	protocol = "media-keys",
	wSocket = undefined,
	connect = function () {
		wSocket = new window.WebSocket("ws://" + host + ":" + port + "/", protocol);
		wSocket.onopen = function () {
			var socket = this; // http://evanprodromou.name/2013/02/08/on-using-this-exactly-once/
			console.log("Connection established to " + host + ":" + port + ".");
			connected = true;
			// attach 'onerror', 'onmessage', and 'onclose' handlers
			// only when a connection has been made (inside this 'onopen' function)
			socket.onerror = function () {
				console.error("Whoops. Something went wrong.");
			};
			socket.onmessage = function (msg) {
				var kcode = msg.data.charCodeAt(0); // we're only expecting a single number
				// console.log("Received key code " + kcode + ".");
				if (kcode === 20) {
					console.log("Previous song.");
					inject(function () {
						// access to window.Grooveshark
						// through injected JS script
						window.Grooveshark.previous();
					});
				}
				else if (kcode === 16) {
					console.log("Play/pause.");
					inject(function () {
						var status = window.Grooveshark.getCurrentSongStatus().status;
						if (status === "playing") {
							window.Grooveshark.pause();
						}
						else {
							window.Grooveshark.play();
						}
					});
				}
				else if (kcode === 19) {
					console.log("Next song.");
					inject(function () {
						window.Grooveshark.next();
					});
				}
			};
			socket.onclose = function () {
				console.log("Connection to " + host + ":" + port + " lost.");
				connected = false;
			};
		};
	};
	// attempt to connect straight away, and
	// every second after a connection is lost
	!function reconnect() {
		if (!connected) {
			// reconnect to the server
			connect();
		}
		// every second
		setTimeout(reconnect, 1000);
	}();

}();
