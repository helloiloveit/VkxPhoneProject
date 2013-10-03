## Copyright (c) 2011 The WebM project authors. All Rights Reserved.
## 
## Use of this source code is governed by a BSD-style license
## that can be found in the LICENSE file in the root of the source
## tree. An additional intellectual property rights grant can be found
## in the file PATENTS.  All contributing project authors may
## be found in the AUTHORS file in the root of the source tree.
# This file automatically generated by configure. Do not edit!
TOOLCHAIN := x86-darwin10-gcc
ALL_TARGETS += libs
ALL_TARGETS += docs

PREFIX=/Users/huyheo/Documents/Linphone/linphone-iphone/submodules/build/..//../liblinphone-sdk/i386-apple-darwin
ifeq ($(MAKECMDGOALS),dist)
DIST_DIR?=vpx-vp8-x86-darwin10-v1.2.0
else
DIST_DIR?=$(DESTDIR)/Users/huyheo/Documents/Linphone/linphone-iphone/submodules/build/..//../liblinphone-sdk/i386-apple-darwin
endif
LIBSUBDIR=lib

VERSION_STRING=v1.2.0

VERSION_MAJOR=1
VERSION_MINOR=2
VERSION_PATCH=0

CONFIGURE_ARGS=--prefix=/Users/huyheo/Documents/Linphone/linphone-iphone/submodules/build/..//../liblinphone-sdk/i386-apple-darwin --sdk-path=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin/../../ --libc=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator6.1.sdk --enable-static --disable-shared --enable-error-concealment --disable-examples --enable-realtime-only --enable-spatial-resampling --enable-vp8 --enable-multithread --target=x86-darwin10-gcc
CONFIGURE_ARGS?=--prefix=/Users/huyheo/Documents/Linphone/linphone-iphone/submodules/build/..//../liblinphone-sdk/i386-apple-darwin --sdk-path=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin/../../ --libc=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator6.1.sdk --enable-static --disable-shared --enable-error-concealment --disable-examples --enable-realtime-only --enable-spatial-resampling --enable-vp8 --enable-multithread --target=x86-darwin10-gcc