# ffmpeg-for-android

[![Build Status](https://img.shields.io/travis/com/alvisisme/android-ffmpeg?style=flat-square)](https://travis-ci.com/alvisisme/android-ffmpeg)

编译ffmpeg至android平台arm64-v8a架构。

本工程主要用于编译**libffmpeg.so**动态库，同时也编译了ffmpeg的命令行工具为可执行文件**ffmpeg_cmd**和动态库**libffmpegcmd.so**，方便快速测试。

## 目录

- [背景](#背景)
- [安装](#安装)
- [用法](#用法)
- [维护人员](#维护人员)
- [贡献参与](#贡献参与)
- [许可](#许可)

## 背景

编译环境

* Ubuntu 18.04.4 LTS amd64
* [android ndk r13b](https://dl.google.com/android/repository/android-ndk-r13b-linux-x86_64.zip)
* [fdk-aac-0.1.5](https://nchc.dl.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-0.1.5.tar.gz)
* [x264-snapshot-20171210-2245-stable](ftp://ftp.videolan.org/pub/videolan/x264/x264-snapshot-20171210-2245-stable.tar.bz2)
* [ffmpeg-3.4.1](http://ffmpeg.org/releases/ffmpeg-3.4.1.tar.bz2)

## 安装

将**dist**目录下对应头文件和静态库/动态库引入，或者推送可执行文件到手机并执行。

## 用法

推荐使用 docker 和 docker-compose 进行编译

```bash
docker-compose up --build
```

编译后的静态库和动态库位于 **build/bin/lib** 目录下，测试的命令行工具位于 **build/bin/bin** 目录下。

## 维护人员

[@Alvis Zhao](https://github.com/alvisisme)

## 贡献参与

欢迎提交PR。

## 许可

© 2020 Alvis Zhao
