FROM alpine

ENV OPENTTD_VERSION=1.7.1
ENV OPENGFX_VERSION=0.5.4

# COPY data/sample.cat data/trg1r.grf data/trgcr.grf data/trghr.grf data/trgir.grf data/trgtr.grf /home/openttd/.openttd/data/

RUN mkdir -p /usr/local/games \
	&& mkdir -p /home/openttd/.openttd/data \
	&& mkdir -p /home/openttd/.openttd/baseset \
	&& adduser -D -h /home/openttd -s /bin/false openttd \
	&& chown -R openttd:openttd /home/openttd

ENV PATH /usr/local/games:$PATH
WORKDIR /home/openttd

EXPOSE 3979/tcp
EXPOSE 3979/udp

# ENTRYPOINT [ "/usr/local/games/openttd", "-D" ]

## install opengfx ##
RUN apk add --no-cache --virtual=.build-dependencies \
		wget \
		ca-certificates \

	&& cd /home/openttd/.openttd/baseset \
	&& wget https://bundles.openttdcoop.org/opengfx/releases/${OPENGFX_VERSION}/opengfx-${OPENGFX_VERSION}.zip \
	&& unzip opengfx-${OPENGFX_VERSION}.zip \
	&& tar -xf opengfx-${OPENGFX_VERSION}.tar \
	&& rm -rf opengfx-*.tar \
	&& rm -rf opengfx-*.zip \
	&& chown -R openttd:openttd /home/openttd/.openttd/baseset \

	&& apk del .build-dependencies


## install via binary ##
# https://binaries.openttd.org/releases/1.7.1/openttd-1.7.1-linux-generic-amd64.tar.gz
# && wget -q -O openttd.tar.gz http://binaries.openttd.org/releases/${OPENTTD_VERSION}/openttd-${OPENTTD_VERSION}-linux-generic-amd64.tar.gz \
# && tar -zxvf openttd.tar.gz \
# && rm openttd.tar.gz \
# && mv openttd-${OPENTTD_VERSION}-linux-generic-amd64/* . \
# && rm -rf openttd-${OPENTTD_VERSION}-linux-generic-amd64 \

## Compile openttd ##

# https://wiki.openttd.org/Readme.txt
# 7.1) Required/optional libraries
# ---- ---------------------------
# The following libraries are used by OpenTTD for:
#   - libSDL/liballegro: hardware access (video, sound, mouse)
#   - zlib: (de)compressing of old (0.3.0-1.0.5) savegames, content downloads,
#     heightmaps
#   - liblzo2: (de)compressing of old (pre 0.3.0) savegames
#   - liblzma: (de)compressing of savegames (1.1.0 and later)
#   - libpng: making screenshots and loading heightmaps
#   - libfreetype: loading generic fonts and rendering them
#   - libfontconfig: searching for fonts, resolving font names to actual fonts
#   - libicu: handling of right-to-left scripts (e.g. Arabic and Persian) and
#     natural sorting of strings.

# https://www.tt-forums.net/viewtopic.php?t=12149&highlight=segmentation+fault

RUN apk add --no-cache --virtual=.build-dependencies \
		alpine-sdk \
		wget \
		ca-certificates \
		g++ \
		make \
		patch \
		lzo-dev \
		freetype-dev \
		subversion \
		libpng \
		zlib-dev \
		sdl \
		icu-libs \
		fontconfig \
		xz-dev \

		# enable debug backtrace
		gdb \

	&& cd /tmp \
	&& wget -O openttd.tar.gz https://binaries.openttd.org/releases/${OPENTTD_VERSION}/openttd-${OPENTTD_VERSION}-source.tar.gz \
	&& tar -zxvf openttd.tar.gz \
	&& rm openttd.tar.gz \
	&& cd openttd* \
	&& ./configure --enable-dedicated \
	&& make \
	&& make install \
	&& cd /home/openttd \
	&& rm -rf /tmp/openttd*

	# && apk del .build-dependencies \

## install runtime dependencies ##
RUN apk add --no-cache \
		lzo \
		fontconfig \
		libpng \
		xz \
		freetype \
		sdl \
		icu-libs \
		zlib

USER openttd

CMD [ "openttd", "-D" ]
