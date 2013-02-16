Media Keys is a Chrome extension (and a small app) that allows you use the media keys (F7, F8, F9) on a Mac keyboard to control web-based streaming services like [Grooveshark](http://grooveshark.com). Thanks to [Boris Smus for the implementation idea of using WebSockets](http://smus.com/chrome-media-keys-revisited/).

To compile the server source, modify the `compile.sh` script to reflect your installation of [libwebsockets](http://libwebsockets.org/).

Still todo
==========

* Popups (notifications) could be useful...

Resources
=========

Definitely check out the [Grooveshark API](http://grooveshark.com/GroovesharkAPI.html) and [libwebsockets API](http://libwebsockets.org/libwebsockets-api-doc.html).

You want this to run itself?
============================

It can't do that. But you can add a daemon to your system.

1. Compile the server.
2. Move the compiled file somewhere you won't loose it.
3. You'll need some XML. (See the *Writing a "Hello World!" launchd Job* section [found here][1], changing the label and program arguments to any name and the location of the compiled executable respectively.)
2. `sudo launchctl load -w /path/to/xml/file/`
3. `ps -e | grep <the label you chose>` and you should see the process running.

  [1]:http://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html