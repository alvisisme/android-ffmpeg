#!/bin/bash

set -o nounset
set -o errexit

HOME=$PWD
BUILD_DIR=$HOME/build
PREFIX=$BUILD_DIR/bin

HOST=aarch64-linux-android
CORSS_PREFIX=aarch64-linux-android-

mkdir -p $BUILD_DIR
mkdir -p $PREFIX

build-x264(){
  cd $BUILD_DIR
  X264_ZIP=x264-snapshot-20171210-2245-stable.tar.bz2
  X264_DIR=x264-snapshot-20171210-2245-stable
  AS_ORI=$AS
  # AS must be CC
  export AS=${CC}

  if [ ! -f ${BUILD_DIR}/${X264_ZIP} ]; then
    wget ftp://ftp.videolan.org/pub/videolan/x264/snapshots/${X264_ZIP}
  fi
  if [ ! -d ${BUILD_DIR}/${X264_ZIP} ]; then
    tar xjvf ${BUILD_DIR}/${X264_ZIP} > /dev/null
  fi
  cd ${BUILD_DIR}/${X264_DIR}
  ./configure \
    --prefix=${PREFIX} \
    --cross-prefix=${CORSS_PREFIX} \
    --host=${HOST} \
    --enable-static \
    --enable-pic \
    --disable-cli \
    --extra-cflags="-march=armv8-a"

  make clean
  make
  make install
  # reset AS
  export AS=${AS_ORI}
}

build-fdk-aac(){
  cd ${BUILD_DIR}
  AAC_ZIP=fdk-aac-0.1.5.tar.gz
  AAC_DIR=fdk-aac-0.1.5
  if [ ! -f ${BUILD_DIR}/${AAC_ZIP} ]; then
    wget --no-check-certificate https://nchc.dl.sourceforge.net/project/opencore-amr/fdk-aac/${AAC_ZIP}
  fi
  if [ ! -d ${BUILD_DIR}/${AAC_DIR} ]; then
    tar zxvf ${BUILD_DIR}/${AAC_ZIP} > /dev/null
  fi
  cd ${BUILD_DIR}/${AAC_DIR}
  ./configure \
    --prefix=${PREFIX} \
    --host=${HOST} \
    --enable-static \
    --disable-shared \
    CFLAGS="-Wno-sequence-point -Wno-extra" \

  make clean
  make
  make install
}

build-ffmpeg(){
  cd ${BUILD_DIR}
  FFMPEG_ZIP=ffmpeg-3.4.1.tar.bz2
  FFMPEG_DIR=ffmpeg-3.4.1
  if [ ! -f ${BUILD_DIR}/${FFMPEG_ZIP} ]; then
    wget http://ffmpeg.org/releases/${FFMPEG_ZIP}
  fi
  if [ ! -d ${BUILD_DIR}/${FFMPEG_DIR} ]; then
    tar xjvf ${FFMPEG_ZIP} > /dev/null
    cp ../ffmpeg.patch .
    patch -p0 -i ffmpeg.patch
  fi

  cd ${BUILD_DIR}/${FFMPEG_DIR}
  ./configure  \
    --prefix=${PREFIX} \
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
    --cross-prefix=${CORSS_PREFIX} \
    --enable-cross-compile \
    --target-os=linux \
    --extra-cflags="-march=armv8-a -I${PREFIX}/include -I${PREFIX}/include/fdk_aac"  \
    --extra-ldflags="-lm -Wl,-Bsymbolic -L${PREFIX}/lib"  \
    --extra-ldexeflags="-pie" \
    --extra-libs="-lgcc" \
    --enable-pic \
    --ignore-tests

  make clean
  make
  make install

  # build libffmpeg.so
  $LD -rpath-link=${PREFIX}/lib \
    -rpath-link=${SYSROOT}/usr/lib \
    -L${PREFIX}/lib \
    -L${SYSROOT}/usr/lib \
    -soname libffmpeg.so \
    -shared -nostdlib -Bsymbolic --whole-archive --no-undefined \
    -o libffmpeg.so \
    ${PREFIX}/lib/libavcodec.a \
    ${PREFIX}/lib/libavfilter.a \
    ${PREFIX}/lib/libswresample.a \
    ${PREFIX}/lib/libavformat.a \
    ${PREFIX}/lib/libavutil.a \
    ${PREFIX}/lib/libswscale.a \
    ${PREFIX}/lib/libpostproc.a \
    -lc -lm -lz -ldl -lx264 -lfdk-aac \
    --dynamic-linker=/system/bin/linker ${ARM64_TOOLCHAIN_HOME}/lib/gcc/aarch64-linux-android/4.9.x/libgcc.a

  cp libffmpeg.so ${PREFIX}/lib/libffmpeg.so
  $STRIP --strip-unneeded ${PREFIX}/lib/libffmpeg.so

  # shared library libffmpegcmd.so
  $CC ${HOME}/ffmpeg_cmd_src/*.c \
    -I${PREFIX}/include \
    -I${BUILD_DIR}/${FFMPEG_DIR} \
    -L${PREFIX}/lib \
    -L${SYSROOT}/usr/lib \
    -lffmpeg -fPIC -Wl,-soname,libffmpegcmd.so -shared -o libffmpegcmd.so
  
  mv libffmpegcmd.so $PREFIX/lib

  # exectuable ffmpeg_cmd
  $CC ${HOME}/ffmpeg_cmd_src/*.c \
    -I${PREFIX}/include \
    -I${BUILD_DIR}/${FFMPEG_DIR} \
    -L${PREFIX}/lib \
    -L${SYSROOT}/usr/lib \
    -lffmpeg -lm -lz -fPIC -pie -o ffmpeg_cmd

  mv ffmpeg_cmd $PREFIX/bin
}

build-x264
build-fdk-aac
build-ffmpeg

