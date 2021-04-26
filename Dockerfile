FROM python:3-alpine as stage-1

# general

ARG WEEWX_UID=1001
ENV WEEWX_HOME="/home/weewx/"
ENV WEEWX_VERSION="4.5.1"

ARG WORKDIR="/tmp/webuild/"
ENV ARCHIVE="weewx-${WEEWX_VERSION}.tar.gz"

LABEL org.opencontainers.image.authors="erudita@ankubis.com"
LABEL org.opencontainers.image.vendor="Ankubis"
LABEL org.opencontainers.image.source="https://github.com/erudita/weewx-docker"
LABEL com.weewx.version=${WEEWX_VERSION}

# add user
RUN addgroup --system --gid ${WEEWX_UID} weewx \
  && adduser --system --uid ${WEEWX_UID} --ingroup weewx weewx

RUN apk --no-cache add tar

WORKDIR ${WORKDIR}
COPY checksums requirements.txt $WORKDIR

# Download sources and verify hashes
RUN wget -O "${ARCHIVE}" "http://www.weewx.com/downloads/released_versions/${ARCHIVE}"
RUN wget -O ${WORKDIR}/weewx-mqtt.zip https://github.com/matthewwall/weewx-mqtt/archive/master.zip
RUN wget -O ${WORKDIR}/weewx-interceptor.zip https://github.com/matthewwall/weewx-interceptor/archive/master.zip
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

# WeeWX install

RUN tar --extract --gunzip --directory ${WEEWX_HOME} --strip-components=1 --file "${ARCHIVE}"
RUN chown -R weewx:weewx ${WEEWX_HOME}

# Weewx Extensions install
WORKDIR ${WEEWX_HOME}
RUN bin/wee_extension --install ${WORKDIR}/weewx-mqtt.zip
RUN bin/wee_extension --install ${WORKDIR}/weewx-interceptor.zip

# Weewx Setup 
RUN ./setup.py build && ./setup.py install 
 
RUN apk del .fetch-deps
RUN rm -fr $WORKDIR
RUN find $WEEWX_HOME/bin -name '*.pyc' -exec rm '{}' +;
    
COPY entrypoint.sh $WEEWX_HOME
ENTRYPOINT ["$WEEWX_HOME/entrypoint.sh"]
