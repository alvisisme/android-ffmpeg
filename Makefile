all: download prebuild build-env build

download:
	sh download.sh

prebuild:
	sh prebuild.sh

build-env:
	docker build . -t ffmpeg-dev

build:
	docker run -i -t --rm -v `pwd`/_temp:/_temp ffmpeg-dev sh /_temp/build.sh