Media Keys
==========

Media Keys is a small WebSocket server and Chrome extension that together allow you to dedicate the media keys (F7, F8, and F9) on a Mac keyboard to controlling [Rdio](http://rdio.com) (or if you're the hacker type, any web-based streaming service). [Credit goes to Boris Smus for the  WebSocket idea.](http://smus.com/chrome-media-keys-revisited/)

Still on the to-do list
-----------------------

* Song notifications could be useful...
* Override events sent via headsets/headphones.

Issues/pull requests welcome.

Building from source
--------------------

Dependencies: [CMake](http://cmake.org/cmake/resources/software.html)

If not already installed, this project will install [libwebsockets](https://github.com/warmcat/libwebsockets).

```bash
$ git clone --recursive git://github.com/whymarrh/media-keys.git
$ ./install.sh
```

Then install the Chrome extension found in the `extension` folder:

```bash
$ cd extension/
$ "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --pack-extension="$PWD"
$ rm ../*.pem
$ mv ../*.crx $HOME/Downloads/
```

Resources
---------

Definitely check out the [Rdio API](http://developer.rdio.com/docs/Web_Playback_API) and the [libwebsockets API](http://libwebsockets.org/libwebsockets-api-doc.html).

iTunes?
-------

Sorry, since the server is always running (due to it starting with the system) it will always be consuming the media key events whole. No other applications (e.g. iTunes, QuickTime Player) will recieve them.
