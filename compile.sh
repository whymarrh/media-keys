#!/usr/bin/env bash

DYLIB=libwebsockets.dylib

SERVER_EXE=${SERVER_EXE:-mediakeys}
LWS_DYNAMIC_LIB_DIR=${LWS_DYNAMIC_LIB_DIR:-/usr/local}

SERVER_SOURCE=mediakeys.m
LWS_INCLUDE_DIR=$LWS_DYNAMIC_LIB_DIR/include
LWS_DYNAMIC_LIB=$LWS_DYNAMIC_LIB_DIR/lib/$DYLIB

# build libwebsockets if it not found
if [ ! -f "$LWS_DYNAMIC_LIB" ]
then
	echo "$DYLIB was not found in $LWS_DYNAMIC_LIB"
	echo "Building libwebsockets"
	mkdir build
	cd build
	cmake -DCMAKE_INSTALL_PREFIX:"PATH=$LWS_DYNAMIC_LIB_DIR" ../lib/libwebsockets
	make
	sudo make install
	cd ..
fi

clang -framework Cocoa -o "$SERVER_EXE" "$SERVER_SOURCE" -I "$LWS_INCLUDE_DIR" "$LWS_DYNAMIC_LIB"
echo "Done"
