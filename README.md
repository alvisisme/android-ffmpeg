# android-ffmpeg

编译android平台arm64架构ffmpeg库

## 测试环境

* Ubuntu16.40
* android-ndk-r13b

## 如何编译

* 下载该工程

  ```shell
  git https://github.com/alvisisme/android-ffmpeg.git
  ```

* 搭建编译环境

  根据NDK安装路径, 配置NDK环境变量
  ```shell
  export ANDROID_NDK=/opt/android-ndk
  ```
  执行构建命令
  ```shell
  make
  ```

* 进入docker镜像,将工程 _temp 目录挂载至镜像 /_temp 目录

  ```shell
  docker run -i -t -v `pwd`/_temp:/_temp ffmpeg-dev /bin/bash
  ```

* docker镜像内执行编译脚本

  ```shell
  cd /_temp
  sh build.sh
  ```