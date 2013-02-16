#!/bin/bash

SERVER_SOURCE=mediakeys.m
SERVER_EXE=mediakeys
LWS_INCLUDE_DIR=~/.bin/libwebsockets/include
LWS_DYNAMIC_LIB=~/.bin/libwebsockets/lib/libwebsockets.dylib

# ...aaannd this is how ObjC is compiled from the command line?
clang -fobjc-arc -framework Cocoa -o $SERVER_EXE $SERVER_SOURCE -I $LWS_INCLUDE_DIR $LWS_DYNAMIC_LIB
