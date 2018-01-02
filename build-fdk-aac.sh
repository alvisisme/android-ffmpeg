#!/bin/bash
set -e

ARCH=arm64
TOOLCHAIN_NAME=aarch64-linux-android-4.9
HOST=aarch64-linux-android
TOOL_PREFIX=${HOST}-
TOOLCHAIN_PATH=/_temp/${ARCH}/bin
NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL_PREFIX}
SYSROOT=${TOOLCHAIN_PATH}/../sysroot

cd /_temp/fdk-aac-0.1.5
./configure \
  --prefix=$TOOLCHAIN_PATH/.. \
  --host=$HOST \
  --with-sysroot=$SYSROOT \
  --enable-static \
  CC="${NDK_TOOLCHAIN_BASENAME}gcc" \
  CXX="${NDK_TOOLCHAIN_BASENAME}g++" \
  STRIP="${NDK_TOOLCHAIN_BASENAME}strip" \
  CFLAGS="-Wno-sequence-point -Wno-extra" \

make clean
make
make install

cd ../../