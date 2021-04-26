#!/bin/sh -e

# set timezone
if [ ! -f /etc/timezone ] && [ ! -z "$TZ" ]; then
  # At first startup, set timezone
  cp /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ >/etc/timezone
fi

# home directory
HOMEDIR=/home/${WEEWX_UID:-weewx}
PATH=$HOMEDIR/bin:$PATH

# edit initial distribution
if [ ! -e $HOMEDIR/weewx.conf.bak ]; then
  echo "INITAL SETTINGS"
fi

./bin/weewxd
