#!/bin/bash

# ...aaannd this is how ObjC is compiled from the command line?
clang -fobjc-arc -framework Cocoa -o main main.m ../../../.bin/libwebsockets/lib/libwebsockets.dylib
