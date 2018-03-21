all: env build

env:
	docker build -t android-ffmpeg-build .

build:
	mkdir -p out
	docker run -i -t --rm -v `pwd`/out:/home/dev/out android-ffmpeg-build
