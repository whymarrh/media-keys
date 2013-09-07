Media Keys
==========

Media Keys is a small WebSocket server and Chrome extension that together allow you to dedicate the media keys (F7, F8, and F9) on a Mac keyboard to controlling [Rdio](http://rdio.com) (or if you're the hacker type, any web-based streaming service). Credit goes to [Boris Smus for the  WebSocket idea](http://smus.com/chrome-media-keys-revisited/).

Still on the to-do list
-----------------------

* Song notifications could be useful...
* Override events sent via headsets/headphones.

Issues/pull requests are welcome.

Building from source
--------------------

Dependencies: [CMake](http://cmake.org/)

Unless specified otherwise, this project will install libwebsockets to `/usr/local/lib`. You can specify the location in which the compile script will look for or install libwebsockets to by changing step 2 below to:

    LWS_DYNAMIC_LIB_DIR=/some/awesome/path ./compile.sh

Just make sure that `/some/awesome/path` is absolute.

1. `git clone --recursive git://github.com/whymarrh/media-keys.git`
2. `./install.sh`
3. Install the Chrome extension

Resources
---------

Definitely check out the [Rdio API](http://developer.rdio.com/docs/Web_Playback_API) and the [libwebsockets API](http://libwebsockets.org/libwebsockets-api-doc.html).

iTunes?
-------

Sorry, since the server is always running (due to it starting with the system) it will always be consuming the media key events whole. No other applications (e.g. iTunes, QuickTime Player) will recieve them.
