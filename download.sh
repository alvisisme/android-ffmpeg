#!/bin/bash

mkdir -p _temp
# download x264
if [ ! -f _temp/x264-snapshot-20171210-2245-stable.tar.bz2 ]; then
  cd _temp
  wget ftp://ftp.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20171210-2245-stable.tar.bz2
  cd ..
fi

# download fdk-aac
if [ ! -f _temp/fdk-aac-0.1.5.tar.gz ]; then
  cd _temp
  wget https://nchc.dl.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-0.1.5.tar.gz
  cd ..
fi

# download ffmpeg
if [ ! -f _temp/ffmpeg-3.4.1.tar.bz2 ]; then
  cd _temp
  wget http://ffmpeg.org/releases/ffmpeg-3.4.1.tar.bz2
  cd ..
fi