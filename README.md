Media Keys
==========

Media Keys is a small WebSocket server that run on OS X, emitting events when you press the "media keys" on your keyboard (F7, F8, and F9). With this you can, amongst other things, control web-based music streaming services. In the [extensions] folder, you will find Safari and Chrome extensions that control playback on Rdio.

Credit for the idea of using WebSockets: [Boris Smus](http://smus.com/chrome-media-keys-revisited/)

**Note**: the server starts with the system and is always running. It will always be consuming the media key events whole and no other applications (e.g. iTunes, QuickTime Player, etc) will recieve them.

Building from source
--------------------

Dependencies: [CMake](http://cmake.org/cmake/resources/software.html)

If not already installed, this project will install [libwebsockets](https://github.com/warmcat/libwebsockets).

```bash
$ git clone --recursive git://github.com/whymarrh/media-keys.git
$ ./install.sh
```

Add the Chrome extension found in the extensions folder (the `Media Keys.crx` file) to Google Chrome (via drag'n'drop).

Resources
---------

Definitely check out the [Rdio API](http://developer.rdio.com/docs/Web_Playback_API) and the [libwebsockets API](http://libwebsockets.org/libwebsockets-api-doc.html).

  [extensions]:extensions/
