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
if [ ! -e $HOMEDIR/weewx.conf.orig ]; then
  echo "INITAL SETTINGS"
  cp $HOMEDIR/weewx.conf $HOMEDIR/weewx.conf.orig
  
# add interceptor driver details  
  if [ -f $HOMEDIR/interceptor.conf ]; then
    cat $HOMEDIR/interceptor.conf >> $HOMEDIR/weewx.conf
fi

./bin/weewxd
