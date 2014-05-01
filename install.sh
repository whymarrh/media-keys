#!/usr/bin/env bash

./compile.sh
DIR="$HOME/.mediakeys"
[[ -d $DIR ]] || mkdir $DIR
mv mediakeys $DIR/mediakeys
cat << EOF > com.whymarrh.apps.mediakeys.plist
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>com.whymarrh.apps.mediakeys</string>
		<key>ProgramArguments</key>
		<array>
			<string>$DIR/mediakeys</string>
		</array>
		<key>KeepAlive</key>
		<true />
	</dict>
</plist>
EOF
mv com.whymarrh.apps.mediakeys.plist $HOME/Library/LaunchAgents
launchctl load $HOME/Library/LaunchAgents/com.whymarrh.apps.mediakeys.plist

# Package Google Chrome extension
cd extension/
CHROME_BINARY="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [[ ! -x $CHROME_BINARY ]]
then
	echo "You will need to install Google Chrome (Stable) to be able to package the extension"
	exit 1
fi
"$CHROME_BINARY" --pack-extension="$PWD"
rm ../extension.pem
mv ../extension.crx ../Media\ Keys.crx
