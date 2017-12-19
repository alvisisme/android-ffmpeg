#!/bin/bash
set -e

ARCH=arm64
TOOLCHAIN_NAME=aarch64-linux-android-4.9
HOST=aarch64-linux-android
TOOL_PREFIX=${HOST}-
TOOLCHAIN_PATH=/_temp/${ARCH}/bin
NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL_PREFIX}
SYSROOT=${TOOLCHAIN_PATH}/../sysroot

export PATH=$PATH:/_temp/arm64/bin

echo $PATH
# build ffmpeg
echo 'building ffmpeg ...'
cd /_temp/ffmpeg-3.4.1
./configure \
  --prefix=$TOOLCHAIN_PATH/.. \
  --enable-gpl \
  --enable-version3 \
  --enable-nonfree \
  --disable-ffplay \
  --disable-ffprobe \
  --disable-ffserver \
  --disable-doc \
  --disable-avdevice \
  --disable-pixelutils \
  --disable-everything \
  --enable-encoder=aac \
  --enable-decoder=h264 \
  --enable-decoder=aac \
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
  --arch=aarch64 \
  --target-os=linux \
  --cross-prefix=$TOOL_PREFIX \
  --enable-cross-compile \
  --sysroot=$SYSROOT \
  --nm=${TOOL_PREFIX}nm \
  --ar=${TOOL_PREFIX}ar \
  --strip=${TOOL_PREFIX}strip \
  --cc=${TOOL_PREFIX}gcc \
  --cxx=${TOOL_PREFIX}g++ \
  --ranlib=${TOOL_PREFIX}ranlib \
  --extra-cflags="" \
  --extra-cxxflags="-march=armv8-a" \
  --extra-ldflags="-lm -ldl -lc" \
  --extra-libs="-lgcc" \
  --extra-ldexeflags="-pie" \
  --enable-pic \
  --ignore-tests \

make
make install

# generating libffmpeg.so
${TOOL_PREFIX}gcc fftools/*.o compat/*.o libavutil/*.o libavutil/aarch64/*.o libavcodec/*.o libavcodec/aarch64/*.o libavformat/*.o libavfilter/*.o libswscale/*.o libswscale/aarch64/*.o libswresample/*.o libswresample/aarch64/*.o libpostproc/*.o -o libffmpeg.so -fPIC --shared -Isrc -lm -ldl -lc
cp libffmpeg.so $TOOLCHAIN_PATH/../lib/libffmpeg.so
${TOOL_PREFIX}strip --strip-unneeded $TOOLCHAIN_PATH/../lib/libffmpeg.so

cd ../..
echo 'building ffmpeg done'