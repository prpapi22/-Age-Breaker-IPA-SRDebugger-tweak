#!/bin/sh
# Needs macOS + Xcode command line tools.
set -e
SDK=$(xcrun --sdk iphoneos --show-sdk-path)
clang -arch arm64 -isysroot "$SDK" -miphoneos-version-min=14.0 \
  -dynamiclib -fobjc-arc -framework Foundation \
  -install_name @rpath/SRDebuggerEnabler.dylib \
  SRDebuggerEnabler.m -o SRDebuggerEnabler.dylib
codesign -f -s - SRDebuggerEnabler.dylib 2>/dev/null || true
echo "Built SRDebuggerEnabler.dylib"
