(function (window, document, undefined) {
	"use strict";
	var inject = function (fn) {
		// console.log("Injecting JS");
		var script = document.createElement("script");
		script.textContent = "(" + fn + ")();";
		(document.head || document.documentElement).appendChild(script);
		script.parentNode.removeChild(script);
	};
	var connected = false;
	var address = "127.0.0.1:9331";
	var protocol = "media-keys";
	var ws = undefined;
	var connect = function() {
		if (connected) {
			// console.log("Already connected");
			window.setTimeout(connect, 1000);
			return;
		}
		// console.log("Establishing connection");
		ws = new window.WebSocket("ws://" + address + "/", protocol);
		ws.onopen = function () {
			// console.log("Connection made to " + address);
			console.dir(ws);
			connected = true;
			this.onmessage = function (message) {
				var keyCode = message.data.charCodeAt(0);
				if (keyCode === 20) {
					console.log("Previous song");
					inject(function () {
						window.Grooveshark.previous();
					});
				}
				if (keyCode === 16) {
					console.log("Play/pause");
					inject(function () {
						window.Grooveshark.togglePlayPause();
					});
				}
				if (keyCode === 19) {
					console.log("Next song");
					inject(function () {
						window.Grooveshark.next();
					});
				}
			};
		};
		ws.onclose = function () {
			// console.log("Connection to " + address + " closed");
			connected = false;
		};
		ws.onerror = function () {
			console.log("Something went wrong");
		};
		window.setTimeout(connect, 1000);
	};
	connect();
}(window, document));
