#!/bin/bash
set -e

ARCH=arm64
TOOLCHAIN_NAME=aarch64-linux-android-4.9
HOST=aarch64-linux-android
TOOL_PREFIX=${HOST}-
TOOLCHAIN_PATH=/_temp/${ARCH}/bin
NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL_PREFIX}
SYSROOT=${TOOLCHAIN_PATH}/../sysroot

export CC=${NDK_TOOLCHAIN_BASENAME}gcc

cd /_temp/x264-snapshot-20171210-2245-stable
./configure \
  --prefix=$TOOLCHAIN_PATH/.. \
  --cross-prefix=$NDK_TOOLCHAIN_BASENAME \
  --host=${HOST} \
  --sysroot=$SYSROOT \
  --enable-static \
  --enable-pic \
  --disable-cli \
  --extra-cflags="-march=armv8-a" \

make clean
make 
make install

cd ../..