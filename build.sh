#!/bin/bash
set -e

ARCH=arm64
TOOLCHAIN_NAME=aarch64-linux-android-4.9
HOST=aarch64-linux-android
TOOL_PREFIX=${HOST}-

export TOOLCHAIN_PATH=`pwd`/${ARCH}/bin
export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL_PREFIX}
export SYSROOT=${TOOLCHAIN_PATH}/../sysroot
export CC=${NDK_TOOLCHAIN_BASENAME}gcc
export CXX=${NDK_TOOLCHAIN_BASENAME}g++
export CXX=${NDK_TOOLCHAIN_BASENAME}gcc
export LINK=${CXX}
export LD=${NDK_TOOLCHAIN_BASENAME}ld
export AR=${NDK_TOOLCHAIN_BASENAME}ar
export RANLIB=${NDK_TOOLCHAIN_BASENAME}ranlib
export STRIP=${NDK_TOOLCHAIN_BASENAME}strip
export OBJCOPY=${NDK_TOOLCHAIN_BASENAME}objcopy
export OBJDUMP=${NDK_TOOLCHAIN_BASENAME}objdump
export NM=${NDK_TOOLCHAIN_BASENAME}nm
export PATH=$PATH:`pwd`/${ARCH}/bin
# AS must be gcc when building lib x264, not as
export AS=${NDK_TOOLCHAIN_BASENAME}gcc
# export AS=${NDK_TOOLCHAIN_BASENAME}as
export PLATFORM=android

# build x264
echo 'building x264 ...'
cd x264-snapshot-20171210-2245-stable
./configure \
  --host=${HOST} \
  --prefix=$TOOLCHAIN_PATH/.. \
  --cross-prefix=${TOOLCHAIN_PATH}/aarch64-linux-android- \
  --sysroot=$SYSROOT \
  --enable-shared \
  --enable-static \
  --disable-cli \
  --enable-pic \
  --extra-cflags="-march=armv8-a" \
  --extra-ldflags="-march=armv8-a" \
  --extra-asflags="-march=armv8-a"

make
make install
cd ..
echo 'building x264 done'

# build fdk-aac
echo 'building fdk-aac ...'
export AS=${NDK_TOOLCHAIN_BASENAME}as
export CCFLAGS='-march=armv8-a -p'
export CXXFLAGS='-march=armv8-a'
export LDFLAGS="-lm -lz -ldl -lc"
export LIBS="-lm -lz -ldl -lc"
cd fdk-aac-0.1.5
./configure \
  --prefix=$TOOLCHAIN_PATH/.. \
  --host=$HOST \
  --with-sysroot=$SYSROOT \
  --enable-shared \
  --enable-static

make
make install
cd ..
echo 'building fdk-aac done'

# build ffmpeg
echo 'building ffmpeg ...'
export CXXFLAGS="-march=armv8-a -lm -ldl -I${TOOLCHAIN_PATH}/../include -I${TOOLCHAIN_PATH}/../fdk_aac -I${SYSROOT}/usr/include"
export LDFLAGS="-march=armv8-a -p -lm -Wl,-Bsymbolic -L${TOOLCHAIN_PATH}/../lib -L${SYSROOT}/usr/lib"
echo $PATH
echo $CC
cd ffmpeg-3.4.1
./configure  \
  --prefix=$TOOLCHAIN_PATH/..  \
  --extra-ldexeflags=-pie \
  --arch=aarch64 \
  --target-os=linux \
  --cross-prefix="$HOST-"  \
  --enable-cross-compile  \
  --sysroot=$SYSROOT \
  --extra-cflags="$CXXFLAGS"  \
  --extra-cxxflags="$CXXFLAGS"  \
  --extra-ldflags="$LDFLAGS"  \
  --extra-libs=-lgcc \
  --enable-pic  \
  --ignore-tests \
  --disable-everything \
  --disable-pixelutils \
  --enable-encoder=libx264 \
  --enable-libx264  \
  --enable-encoder=libfdk_aac \
  --enable-decoder=libfdk_aac \
  --enable-libfdk-aac  \
  --enable-gpl  \
  --enable-nonfree  \
  --enable-swscale \
  --enable-avutil  \
  --enable-avcodec \
  --enable-parser=h264 \
  --enable-parser=aac \
  --enable-protocol=file \
  --enable-protocol=hls \
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
  --disable-doc \
  --disable-ffplay   \
  --disable-ffprobe  \
  --disable-ffserver  \
  --disable-avdevice

make
make install

# generating libffmpeg.so
$LD -rpath-link=$SYSROOT/usr/lib -L$SYSROOT/usr/lib -L$TOOLCHAIN_PATH/../lib -soname libffmpeg.so -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o $TOOLCHAIN_PATH/../lib/libffmpeg.so $TOOLCHAIN_PATH/../lib/libfdk-aac.a $TOOLCHAIN_PATH/../lib/libx264.a $TOOLCHAIN_PATH/../lib/libavcodec.a $TOOLCHAIN_PATH/../lib/libavfilter.a $TOOLCHAIN_PATH/../lib/libswresample.a $TOOLCHAIN_PATH/../lib/libavformat.a $TOOLCHAIN_PATH/../lib/libavutil.a $TOOLCHAIN_PATH/../lib/libswscale.a $TOOLCHAIN_PATH/../lib/libpostproc.a -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker $TOOLCHAIN_PATH/../lib/gcc/aarch64-linux-android/4.9.x/libgcc.a 
# backup unstripped so
cp $TOOLCHAIN_PATH/../lib/libffmpeg.so $TOOLCHAIN_PATH/../lib/libffmpeg-debug.so
# strip
$STRIP --strip-unneeded $TOOLCHAIN_PATH/../lib/libffmpeg.so

cd ..
echo 'building ffmpeg done'
