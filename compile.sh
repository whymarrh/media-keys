#!/bin/bash

# ...aaannd this is how ObjC is compiled from the command line?
clang -fobjc-arc -framework Cocoa -o main main.m -I ../../../.bin/libwebsockets/include ../../../.bin/libwebsockets/lib/libwebsockets.dylib
