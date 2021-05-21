#!/bin/sh


# home directory
NOW=`date -Iseconds`
HOMEDIR=/home/${WEEWX_UID:-weewx}
WEEWX_DAEMON=${HOMEDIR}/bin/weewxd
WEEWX_CONFIG=${HOMEDIR}/bin/wee_config
DIST_CONF_FILE=${HOMEDIR}/weewx.conf
CONF_FILE="/data/etc/weewx.conf"
ARCHIVE_CONF_FILE=${CONF_FILE}.${NOW}

PATH=$HOMEDIR/bin:$PATH

# echo key parameters for debug
for X in NOW WEEWX_DAEMON CONF_FILE DIST_CONF_FILE ARCHIVE_CONF_FILE
do
  eval Y='$'$X
  echo ${X} "is" ${Y}
done

copy_default_config() {
  # create config file on the mountable volume
  echo "Creating a configuration file " ${CONF_FILE}

  cp ${DIST_CONF_FILE} ${CONF_FILE}
  echo "default config copied"

}

if [ $# -lt 1 ]; then
  echo "no arguments"
  echo "STARTING WEEWX"
  echo "exec ${WEEWX_DAEMON} $CONF_FILE"
  exec ${WEEWX_DAEMON} $CONF_FILE
fi

if [ "$1" = "--upgrade" ]; then
  echo "Generate a new config file"
  ${WEEWX_CONFIG} --upgrade --no-prompt --dist-config weewx.conf ${CONF_FILE}
  exit 0
fi


# copy + edit dist config file
if [ ! -e ${CONF_FILE} ]; then
  echo "Create working Config file"
  cp ${DIST_CONF_FILE} ${CONF_FILE}
  chmod 755 ${CONF_FILE}
  echo "chown ${WEEWX_UID:-weewx} ${CONF_FILE}"
  chown ${WEEWX_UID:-weewx} ${CONF_FILE}
  echo "default file copied"

  # Change 2 areas which will emit data
  # Change default sql location
  sed -i "s/SQLITE_ROOT =.*/SQLITE_ROOT = \/data\/archive/g" "${CONF_FILE}"
  # Change default html location
  sed -i "s/HTML_ROOT =.*/HTML_ROOT = \/public_html/g" "${CONF_FILE}"
fi

#
# Check syslog
#
# weewx has its own logging method which varies according to the OS
# see weeutil/logger.py
# the result is sysloghandler stack traces on Alpine in Docker
# need to make sure we start syslogd
#
echo "CHECKING SYSLOG"
LINES=`ps a | grep syslog | grep -v "grep" | wc -l`
if [ ${LINES} -lt 1 ]; then
  echo "SYSLOG not running"
  /sbin/syslogd -n -S -O - &
else
  echo "SYSLOG already running"
fi

echo "STARTING WEEWX"
echo "exec ${WEEWX_DAEMON} $CONF_FILE"

exec ${WEEWX_DAEMON} $CONF_FILE
