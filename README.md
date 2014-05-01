Media Keys
==========

Media Keys is a small WebSocket server and Chrome extension that together allow you to dedicate the media keys (F7, F8, and F9) on a Mac keyboard to controlling [Rdio](http://rdio.com) (or if you're the hacker type, any web-based streaming service). [Credit goes to Boris Smus for the  WebSocket idea.](http://smus.com/chrome-media-keys-revisited/)

Note: since the server is always running (due to it starting with the system) it will always be consuming the media key events and no other applications (e.g. iTunes, QuickTime Player, etc) will recieve them.

Building from source
--------------------

Dependencies: [CMake](http://cmake.org/cmake/resources/software.html)

If not already installed, this project will install [libwebsockets](https://github.com/warmcat/libwebsockets).

```bash
$ git clone --recursive git://github.com/whymarrh/media-keys.git
$ ./install.sh
```

Add the Chrome extension found in the folder (the `Media Keys.crx` file) to Google Chrome (via drag-and-drop).

Resources
---------

Definitely check out the [Rdio API](http://developer.rdio.com/docs/Web_Playback_API) and the [libwebsockets API](http://libwebsockets.org/libwebsockets-api-doc.html).
