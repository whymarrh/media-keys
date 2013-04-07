What is this?
=============

Media Keys is a Chrome extension and a small app that allow you to dedicate the media keys (F7, F8, and F9) on a Mac keyboard to controlling web-based streaming services like [Grooveshark](http://grooveshark.com). Thanks to [Boris Smus for the implementation idea of using WebSockets](http://smus.com/chrome-media-keys-revisited/).

Still on the to-do list
=======================

* Song notifications could be useful...
* Override events sent via headsets/headphones.

Building
========

Unless specified otherwise, this project will install libwebsockets to `/usr/local/lib`. You can specify the location in which the compile script will look for or install libwebsockets to by changing step two (2) below to:

    LWS_DYNAMIC_LIB_DIR=/some/awesome/path ./compile.sh

Just make sure that `/some/awesome/path` is absolute.

1. `git clone --recursive git://github.com/whymarrh/media-keys.git`
2. `./compile.sh`
3. Install the Chrome extension - see [load the extension](http://developer.chrome.com/extensions/getstarted.html#unpacked).

Resources
=========

Definitely check out the [Grooveshark API](http://developers.grooveshark.com/docs/js_api/) and the [libwebsockets API](http://libwebsockets.org/libwebsockets-api-doc.html).

You want this to start itself?
==============================

It can't do that. But you can add a daemon to your system.

1. Compile the server. (See above.)
2. Move the compiled file somewhere you won't loose it.
3. You'll need some XML. [Get some here.](https://gist.github.com/whymarrh/4965481)
4. Change the `/path/to/the/executable/file` to where your compiled server is.
5. Move the modified p-list file to `~/Library/LaunchAgents/`.
6. Restart the system.
7. `ps -e | grep [m]ediakeys` and you should see the process running.
8. All done. The server will now run automagically on system start.

Will other applications still have access to the media keys?
============================================================

No, not when the server is running. Thus, if the server is always running (due to it starting with the system) it will always be consuming the media key events whole, all other applications will no longer work with them. You could always use something like [Lingon](http://www.peterborgapps.com/lingon/) to start the server.
