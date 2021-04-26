#!/bin/sh -e


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
fi

./bin/weewxd
