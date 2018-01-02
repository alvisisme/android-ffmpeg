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
export CXX=${NDK_TOOLCHAIN_BASENAME}g++
export LINK=${CXX}
export LD=${NDK_TOOLCHAIN_BASENAME}ld
export AR=${NDK_TOOLCHAIN_BASENAME}ar
export RANLIB=${NDK_TOOLCHAIN_BASENAME}ranlib
export STRIP=${NDK_TOOLCHAIN_BASENAME}strip
export OBJCOPY=${NDK_TOOLCHAIN_BASENAME}objcopy
export OBJDUMP=${NDK_TOOLCHAIN_BASENAME}objdump
export NM=${NDK_TOOLCHAIN_BASENAME}nm
export AS=${NDK_TOOLCHAIN_BASENAME}as
export PATH=${TOOLCHAIN_PATH}:$PATH

# shared library
$CC /_temp/ffmpeg_cmd_src/*.c -I${TOOLCHAIN_PATH}/../include -I/_temp/ffmpeg-3.4.1 -L${TOOLCHAIN_PATH}/../lib -L${SYSROOT}/usr/lib -lffmpeg -fPIC -Wl,-soname,libffmpegcmd.so -shared -o libffmpegcmd.so
# exectuable
$CC /_temp/ffmpeg_cmd_src/*.c -I${TOOLCHAIN_PATH}/../include -I/_temp/ffmpeg-3.4.1 -L${TOOLCHAIN_PATH}/../lib -L${SYSROOT}/usr/lib -lffmpeg -lm -lz -fPIC -pie -o ffmpeg_cmd
