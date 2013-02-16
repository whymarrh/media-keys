Media Keys is a Chrome extension and a small app that allow you to dedicate the media keys (F7, F8, and F9) on a Mac keyboard to controlling web-based streaming services like [Grooveshark](http://grooveshark.com). Thanks to [Boris Smus for the implementation idea of using WebSockets](http://smus.com/chrome-media-keys-revisited/).

See [Building a Chrome Extension](http://developer.chrome.com/extensions/getstarted.html#unpacked) for the extension install instructions.

To compile the server source, modify the `compile.sh` script to reflect your installation of [libwebsockets](http://libwebsockets.org/).

Still on the to-do list
=======================

* Song notifications could be useful...

Resources
=========

Definitely check out the [Grooveshark API](http://grooveshark.com/GroovesharkAPI.html) and [libwebsockets API](http://libwebsockets.org/libwebsockets-api-doc.html).

You want this to start itself?
==============================

It can't do that. But you can add a daemon to your system.

1. Compile the server.
2. Move the compiled file somewhere you won't loose it.
3. You'll need some XML. [Get some here.](https://gist.github.com/whymarrh/4965481)
4. Change the `/path/to/the/executable/file` to where your compiled server is.
5. `sudo launchctl load -w /path/to/the/plist/file`.
6. `ps -e | grep [m]ediakeys` and you should see the process running.
7. All done. The server will now run automagically on system start.

Will other applications still have access to the media keys?
============================================================

No, not when the server is running. Thus, if the server is always running (due to it starting with the system) it will always be consuming the media key events whole, all other applications will no longer work with them. You could always use something like [Lingon](http://www.peterborgapps.com/lingon/) to start the server.
