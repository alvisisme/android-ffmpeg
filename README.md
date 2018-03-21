# Build ffmpeg for android

Build ffmpeg and cmd tools for android(arm64)

## Build Environment

  * Ubuntu 16.04.4 LTS(amd64)

  * Docker version 17.12.1-ce, build 7390fc6

## Related Source and tools

  * [fdk-aac-0.1.5](https://nchc.dl.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-0.1.5.tar.gz)

  * [x264-snapshot-20171210-2245-stable](ftp://ftp.videolan.org/pub/videolan/x264/x264-snapshot-20171210-2245-stable.tar.bz2)

  * [ffmpeg-3.4.1](http://ffmpeg.org/releases/ffmpeg-3.4.1.tar.bz2)

  * [android ndk r13b](https://dl.google.com/android/repository/android-ndk-r13b-linux-x86_64.zip)

## How to build

* Download this project

  ```shell
  git https://github.com/alvisisme/android-ffmpeg.git
  ```

* Build

  ```shell
  cd android-ffmpeg
  make
  ```

  Check the **out** directory for output files.