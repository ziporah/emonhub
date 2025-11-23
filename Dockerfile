FROM debian:bullseye
CMD ["bash"]
RUN echo "Acquire::http::Proxy \"http://apt-cacher-ng.lanzone.home:3142\";" > /etc/apt/apt.conf
RUN echo "Acquire::https::Proxy None;" >> /etc/apt/apt.conf
RUN apt-get update  \
	&& DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends install -y python3-pip python3-setuptools python3-wheel git  \
	&& apt-get clean  \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV EMONHOME=/emonhome
RUN groupadd -g 1000 emonhub  \
	&& useradd -u 1000 -g emonhub -d $EMONHOME -s /bin/sh emonhub  \
	&& mkdir $EMONHOME /config  \
	&& chown emonhub:emonhub $EMONHOME /config
USER emonhub
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/emonhome/.local/bin
RUN pip3 install --user configobj future iso8601 paho-mqtt requests serial
WORKDIR /emonhome
RUN git clone --depth 1 -b rpi4 https://github.com/ziporah/emonhub.git
ENV EMONHUB_CONF=/emonhome/emonhub/conf/emonhub.conf
CMD ["sh" "-c" "python3 $EMONHOME/emonhub/src/emonhub.py --config-file=$EMONHUB_CONF"]
