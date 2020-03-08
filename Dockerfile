# See https://github.com/alvisisme/docker-android-ndk
FROM alvisisme/android-ndk:r13b

RUN apt-get update \
     && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends binutils build-essential gawk

ENV ARM64_TOOLCHAIN_HOME=/arm64-android-toolchain

RUN /bin/bash /android-ndk-r13b/build/tools/make-standalone-toolchain.sh \
        --arch=arm64 \
        --platform=android-21 \
        --toolchain=aarch64-linux-android-4.9 \
        --stl=gnustl \
        --install-dir=${ARM64_TOOLCHAIN_HOME}

ENV PATH=${ARM64_TOOLCHAIN_HOME}/bin:$PATH
ENV CC=${ARM64_TOOLCHAIN_HOME}/bin/aarch64-linux-android-gcc
ENV CXX=${ARM64_TOOLCHAIN_HOME}/bin/aarch64-linux-android-g++
ENV LINK=${ARM64_TOOLCHAIN_HOME}/bin/aarch64-linux-android-g++
ENV LD=${ARM64_TOOLCHAIN_HOME}/bin/aarch64-linux-android-ld
ENV AR=${ARM64_TOOLCHAIN_HOME}/bin/aarch64-linux-android-ar
ENV RANLIB=${ARM64_TOOLCHAIN_HOME}/bin/aarch64-linux-android-ranlib
ENV STRIP=${ARM64_TOOLCHAIN_HOME}/bin/aarch64-linux-android-strip
ENV OBJCOPY=${ARM64_TOOLCHAIN_HOME}/bin/aarch64-linux-android-objcopy
ENV OBJDUMP=${ARM64_TOOLCHAIN_HOME}/bin/aarch64-linux-android-objdump
ENV NM=${ARM64_TOOLCHAIN_HOME}/bin/aarch64-linux-android-nm
ENV AS=${ARM64_TOOLCHAIN_HOME}/bin/aarch64-linux-android-as
ENV SYSROOT=${ARM64_TOOLCHAIN_HOME}/sysroot

ENV PLATFORM=android
ENV CFLAGS="-D__ANDROID_API__=21"

COPY ffmpeg.patch /ffmpeg.patch
COPY ffmpeg_cmd_src /ffmpeg_cmd_src
COPY build.sh /build.sh

VOLUME ["/build"]
CMD ["/bin/bash", "/build.sh"]
