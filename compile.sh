#!/bin/bash

# ...aaannd this is how ObjC is compiled from the command line?
clang -fobjc-arc -framework Cocoa -o server server.m -I ../../../.bin/libwebsockets/include ../../../.bin/libwebsockets/lib/libwebsockets.dylib
