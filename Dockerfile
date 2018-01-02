FROM alvisisme/docker-ubuntu-1604-163

# update system
RUN apt-get update && \
		apt-get -y upgrade && \
		apt-get install -y build-essential gawk && \
		apt-get autoclean && \
		apt-get autoremove

VOLUME /_temp