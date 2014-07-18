Safari/Google Chrome Extension
==============================

Despite the name of this folder, this is both a Chrome and Safari extension.

Load Safari Extension
---------------------

1. Open Safari
2. From the Safari menu, choose:
    1. Develop
    2. Show Extension Builder
    3. `+`
    4. Add Extension
    5. Select this folder

Note: You will need a to be a "Safari Developer" (Apple's term). You can sign up for an account at [developer.apple.com].

Load Google Chrome Extension
----------------------------

The easy way (from inside this directory):

```bash
CHROME_BINARY="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [[ ! -x $CHROME_BINARY ]]
then
	echo "You will need to install Google Chrome (Stable) to be able to package the extension"
else
	"$CHROME_BINARY" --pack-extension="$PWD"
	rm ../MediaKeys.safariextension.pem
	mv ../MediaKeys.safariextension.crx ~/Downloads/MediaKeys.crx
fi
```

And drag'n'drop the `MediaKeys.crx` file from your downloads folder onto Chrome.

The "I like menus way":

1. Open Google Chrome
2. Go to `chrome://extensions`
3. Check *Developer Mode*
4. Load unpacked extension
5. Select this folder

  [developer.apple.com]:https://developer.apple.com/
