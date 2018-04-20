#!/bin/bash
set -e

BUILD_DIR=/home/dev/out
HOME=/home/dev

PREFIX=/home/dev/arm64
HOST=aarch64-linux-android
CORSS_PREFIX=aarch64-linux-android-

# ====== x264 begin ======
cd ${HOME}
X264_ZIP=x264-snapshot-20171210-2245-stable.tar.bz2
X264_DIR=x264-snapshot-20171210-2245-stable
AS_ORI=$AS
# AS must be CC
export AS=${CC}
if [ ! -f ${HOME}/${X264_ZIP} ]; then
  wget ftp://ftp.videolan.org/pub/videolan/x264/snapshots/${X264_ZIP}
fi
if [ ! -d ${HOME}/${X264_DIR} ]; then
  tar xjvf ${HOME}/${X264_ZIP}  > /dev/null
fi
cd ${HOME}/${X264_DIR}
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
# ====== x264 end ======

# ====== fdk-aac begin ======
cd ${HOME}
AAC_ZIP=fdk-aac-0.1.5.tar.gz
AAC_DIR=fdk-aac-0.1.5
if [ ! -f ${HOME}/${AAC_ZIP} ]; then
  wget --no-check-certificate https://nchc.dl.sourceforge.net/project/opencore-amr/fdk-aac/${AAC_ZIP}
fi
if [ ! -d ${HOME}/${AAC_DIR} ]; then
  tar zxvf ${HOME}/${AAC_ZIP} > /dev/null
fi
cd ${HOME}/${AAC_DIR}
./configure \
  --prefix=${PREFIX} \
  --host=${HOST} \
  --enable-static \
  --disable-shared \
  CFLAGS="-Wno-sequence-point -Wno-extra" \

make clean
make
make install
# ====== fdk-aac end ======

# ====== ffmpeg begin ======
cd ${HOME}
FFMPEG_ZIP=ffmpeg-3.4.1.tar.bz2
FFMPEG_DIR=ffmpeg-3.4.1
if [ ! -f ${HOME}/${FFMPEG_ZIP} ]; then
  wget http://ffmpeg.org/releases/${FFMPEG_ZIP}
fi
if [ ! -d ${HOME}/${FFMPEG_DIR} ]; then
  tar xjvf ${FFMPEG_ZIP} > /dev/null
  patch -p0 -i ffmpeg.patch
fi

cd ${HOME}/${FFMPEG_DIR}
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
$LD -rpath-link=${PREFIX}/lib -rpath-link=${PREFIX}/sysroot/usr/lib -L${PREFIX}/lib -L${PREFIX}/sysroot/usr/lib -soname libffmpeg.so -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o libffmpeg.so libavcodec/libavcodec.a libavfilter/libavfilter.a libswresample/libswresample.a libavformat/libavformat.a libavutil/libavutil.a libswscale/libswscale.a libpostproc/libpostproc.a -lc -lm -lz -ldl -lx264 -lfdk-aac --dynamic-linker=/system/bin/linker ${PREFIX}/lib/gcc/aarch64-linux-android/4.9.x/libgcc.a
cp libffmpeg.so ${PREFIX}/lib/libffmpeg.so
$STRIP --strip-unneeded ${PREFIX}/lib/libffmpeg.so
# ====== ffmpeg end ======

# ====== ffmpeg cmd tools begin ======
# shared library
$CC ${HOME}/ffmpeg_cmd_src/*.c -I${PREFIX}/include -I${HOME}/${FFMPEG_DIR} -L${PREFIX}/lib -L${PREFIX}/sysroot/usr/lib -lffmpeg -fPIC -Wl,-soname,libffmpegcmd.so -shared -o libffmpegcmd.so
# exectuable
$CC ${HOME}/ffmpeg_cmd_src/*.c -I${PREFIX}/include -I${HOME}/${FFMPEG_DIR} -L${PREFIX}/lib -L${PREFIX}/sysroot/usr/lib -lffmpeg -lm -lz -fPIC -pie -o ffmpeg_cmd
# ====== ffmpeg cmd tools begin ======

rm -rf ~/out/*
cp -r ${PREFIX}/include/fdk-aac ~/out
cp -r ${PREFIX}/include/libavcodec ~/out
cp -r ${PREFIX}/include/libavfilter ~/out
cp -r ${PREFIX}/include/libavformat ~/out
cp -r ${PREFIX}/include/libavutil ~/out
cp -r ${PREFIX}/include/libpostproc ~/out
cp -r ${PREFIX}/include/libswresample ~/out
cp -r ${PREFIX}/include/libswscale ~/out
cp ${PREFIX}/include/x264.h ~/out
cp ${PREFIX}/include/x264_config.h ~/out
cp ${PREFIX}/lib/libffmpeg.so ~/out
cp libffmpegcmd.so ~/out
cp ffmpeg_cmd ~/out
