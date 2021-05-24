FROM alpine:3.13

# general

ARG WEEWX_UID=1001

ARG WORKDIR=/tmp/webuild/
ENV WEEWX_VERSION="4.5.1" \
    WEEWX_HOME="/home/weewx" 
    
ENV ARCHIVE="weewx-${WEEWX_VERSION}.tar.gz"

LABEL org.opencontainers.image.authors="erudita@ankubis.com" \
      org.opencontainers.image.vendor="Ankubis" \
      org.opencontainers.image.source="https://github.com/erudita/weewx-docker" \
      com.weewx.version=${WEEWX_VERSION}

ENV SYSLOG_DEST=/var/log/messages \
    TZ=Australia/Melbourne

# add user
RUN addgroup --system --gid ${WEEWX_UID} weewx \
  && adduser --system --uid ${WEEWX_UID} --ingroup weewx weewx

RUN apk --no-cache add tar

WORKDIR ${WORKDIR}
COPY checksums requirements.txt ./

# Download sources and verify hashes
RUN wget -O "${ARCHIVE}" "http://www.weewx.com/downloads/released_versions/${ARCHIVE}"
RUN wget -O ${WORKDIR}/weewx-mqtt.zip https://github.com/matthewwall/weewx-mqtt/archive/master.zip
RUN wget -O ${WORKDIR}/weewx-interceptor.zip https://github.com/matthewwall/weewx-interceptor/archive/master.zip
RUN wget -O ${WORKDIR}/weewx-mqttsubscribe.zip https://github.com/bellrichm/WeeWX-MQTTSubscribe/archive/refs/tags/v2.0.0.zip
RUN sha256sum -c < checksums

# libraries

RUN apk add --no-cache --update \
      curl freetype libjpeg libstdc++ openssh openssl python3 py3-cheetah \
      py3-configobj py3-mysqlclient py3-pillow py3-requests py3-six py3-usb \
      rsync rsyslog tzdata

RUN apk add --no-cache --virtual .fetch-deps \
      file freetype-dev g++ gawk gcc git jpeg-dev libpng-dev make musl-dev \
      py3-pip py3-wheel python3-dev zlib-dev mariadb-dev
RUN pip install -r ./requirements.txt && ln -s python3 /usr/bin/python

# WeeWX install. See https://www.weewx.com/docs/setup.htm

RUN tar --extract --gunzip --directory . --strip-components=1 --file "${ARCHIVE}"
## RUN chown -R weewx:weewx ${WEEWX_HOME}

# Weewx Setup 
RUN ./setup.py build && ./setup.py install --no-prompt

# Weewx Extensions install
WORKDIR ${WEEWX_HOME}
RUN bin/wee_extension --install $WORKDIR/weewx-mqtt.zip
RUN bin/wee_extension --install $WORKDIR/weewx-interceptor.zip
RUN bin/wee_extension --install ${WORKDIR}/weewx-mqttsubscribe.zip
RUN bin/wee_config --reconfigure --driver=user.interceptor --no-prompt

RUN mkdir /data &&  mkdir /data/bin

## CHANGE below line according to 
COPY --chown=$WEEWX_UID entrypoint.sh ./bin

RUN apk del .fetch-deps
RUN rm -fr $WORKDIR
RUN find $WEEWX_HOME/bin -name '*.pyc' -exec rm '{}' +;

ENV PATH="/data/bin:$PATH"

## a volume is an option, but I really want to mount a specific host directory (a bind mount). QNAP interface will not allow this at run-time
## VOLUME ["/data"]

##ENTRYPOINT ["/bin/sh", "/data/bin/entrypoint.sh"]
ENTRYPOINT ["/bin/sh", "./bin/entrypoint.sh"]
CMD ["weewx.conf"]
