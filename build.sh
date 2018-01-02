#!/bin/bash
set -e

# build x264
sh /_temp/build-x264.sh

# build fdk-aac
sh /_temp/build-fdk-aac.sh

# build ffmpeg
echo 'building ffmpeg ...'

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

cd /_temp/ffmpeg-3.4.1
./configure  \
  --prefix=$TOOLCHAIN_PATH/..  \
  --enable-gpl \
  --enable-version3 \
  --enable-nonfree \
  --disable-ffplay \
  --disable-ffprobe \
  --disable-ffserver \
  --disable-doc \
  --disable-avdevice \
  --disable-pthreads \
  --disable-pixelutils \
  --disable-everything \
  --enable-encoder=libx264 \
  --enable-encoder=aac \
  --enable-encoder=libfdk_aac \
  --enable-decoder=h264 \
  --enable-decoder=aac \
  --enable-decoder=libfdk_aac \
  --enable-muxer=hls \
  --enable-muxer=h264 \
  --enable-muxer=rtsp \
  --enable-demuxer=rtsp \
  --enable-demuxer=sdp \
  --enable-demuxer=hls \
  --enable-demuxer=h264 \
  --enable-parser=h264 \
  --enable-parser=aac \
  --enable-protocol=file \
  --enable-protocol=hls \
  --enable-libfdk-aac \
  --enable-libx264 \
  --arch=aarch64 \
  --cross-prefix="$NDK_TOOLCHAIN_BASENAME"  \
  --enable-cross-compile  \
  --sysroot=$SYSROOT \
  --target-os=linux \
  --extra-cflags="-march=armv8-a -I${TOOLCHAIN_PATH}/../include -I${TOOLCHAIN_PATH}/../fdk_aac"  \
  --extra-ldflags="-lm -Wl,-Bsymbolic -L${TOOLCHAIN_PATH}/../lib -L${SYSROOT}/usr/lib"  \
  --extra-ldexeflags="-pie" \
  --extra-libs="-lgcc" \
  --enable-pic \
  --ignore-tests

make clean
make
make install

$LD -rpath-link=${TOOLCHAIN_PATH}/../lib -rpath-link=${SYSROOT}/usr/lib -L${TOOLCHAIN_PATH}/../lib -L${SYSROOT}/usr/lib -soname libffmpeg.so -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o libffmpeg.so libavcodec/libavcodec.a libavfilter/libavfilter.a libswresample/libswresample.a libavformat/libavformat.a libavutil/libavutil.a libswscale/libswscale.a libpostproc/libpostproc.a -lc -lm -lz -ldl -llog -lx264 -lfdk-aac --dynamic-linker=/system/bin/linker $TOOLCHAIN_PATH/../lib/gcc/aarch64-linux-android/4.9.x/libgcc.a
cp libffmpeg.so ${TOOLCHAIN_PATH}/../lib/libffmpeg.so
$STRIP --strip-unneeded $TOOLCHAIN_PATH/../lib/libffmpeg.so
cd ../..

cd /_temp/ffmpeg_cmd_src
sh build.sh
cd ../..