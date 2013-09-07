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
