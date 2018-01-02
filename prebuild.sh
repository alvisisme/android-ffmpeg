#!/bin/bash
set -e

ARCH=arm64
TOOLCHAIN_NAME=aarch64-linux-android-4.9

if [ $ANDROID_NDK ]; then
  echo "ndk root path = $ANDROID_NDK"
else
  echo "cannot find ndk path, please set ANDROID_NDK env"
  exit;
fi

# create ndk toolchain
if [ ! -d _temp/arm64 ]; then
  $ANDROID_NDK/build/tools/make-standalone-toolchain.sh \
  --arch=$ARCH \
  --platform=android-21 \
  --toolchain=$TOOLCHAIN_NAME \
  --install-dir=`pwd`/_temp/$ARCH
fi

if [ ! -d _temp/x264-snapshot-20171210-2245-stable ]; then
  echo "extracting x264 ..."
  cd _temp
  tar xjvf x264-snapshot-20171210-2245-stable.tar.bz2  > /dev/null
  cd ..
  echo "extracting x264 done"
fi
if [ ! -d _temp/fdk-aac-0.1.5 ]; then
  echo "extracting fdk-aac ..."
  cd _temp
  tar zxvf fdk-aac-0.1.5.tar.gz > /dev/null
  cd ..
  echo "extracting fdk-aac done"
fi
if [ ! -d _temp/ffmpeg-3.4.1 ]; then
  echo "extracting ffmpeg ..."
  cd _temp
  tar xjvf ffmpeg-3.4.1.tar.bz2 > /dev/null
  cd ..
  echo "extracting ffmpeg done"
fi
if [ ! -f _temp/ffmpeg.patch ]; then
  echo "patching ffmpeg ..."
  cp ffmpeg.patch _temp/ffmpeg.patch
  cd _temp
  patch -p0 -i ffmpeg.patch
  cd ../
  echo "patching ffmpeg done"
fi

[ ! -f _temp/build-fdk-aac.sh ] && {
  cp build-fdk-aac.sh _temp/build-fdk-aac.sh
}

[ ! -f _temp/build-x264.sh ] && {
  cp build-x264.sh _temp/build-x264.sh
}

[ ! -d _temp/ffmpeg_cmd_src ] && {
  cp -r ffmpeg_cmd_src _temp/ffmpeg_cmd_src
}

[ ! -f _temp/build.sh ] && {
  cp build.sh _temp/build.sh
}


