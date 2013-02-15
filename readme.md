Media Keys is a Chrome extension (and a small app) that allows you use the media keys (F7, F8, F9) on a Mac keyboard to control web-based streaming services like [Grooveshark](http://grooveshark.com). Thanks to [Boris Smus for the implementation idea](http://smus.com/chrome-media-keys-revisited/).

To compile the server source, modify the `compile.sh` script to reflect your installation of [libwebsockets](http://libwebsockets.org/).

Still todo
==========

* Stop event propagation to iTunes & co. Even though Grooveshark will be sent the play/pause command, iTunes starting up negates everything.
* Popups (notifications) could be useful...

Resources
=========

Definitely check out the [Grooveshark API](http://grooveshark.com/GroovesharkAPI.html) and [libwebsockets API](http://libwebsockets.org/libwebsockets-api-doc.html).
