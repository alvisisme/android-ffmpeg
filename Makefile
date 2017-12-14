all: download prebuild build-env

download:
	sh download.sh

prebuild:
	sh prebuild.sh

build-env:
	docker build . -t ffmpeg-dev
