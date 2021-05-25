#!/bin/sh


# home directory
# most of these are set in the Dockerfile
NOW=`date -Iseconds`
SYSLOG="/sbin/syslogd"
HOMEDIR=/home/${WEEWX_UID:-weewx}
DATA_DIR=${WEEWX_DATA:-/data}
SQLLITE_DIR=${WEEWX_SQL_DIR-${DATA_DIR}/archive}
CONF_DIR=${WEEWX_CONF_DIR-${DATA_DIR}/etc}
WEEWX_DAEMON=${HOMEDIR}/bin/weewxd
WEEWX_CONFIG=${HOMEDIR}/bin/wee_config
DIST_CONF_FILE=${HOMEDIR}/weewx.conf
HTML_DIR=${WEEWX_HTML-/public_html}
CONF_FILE=${CONF_DIR}/weewx.conf
ARCHIVE_CONF_FILE=${CONF_FILE}.${NOW}
##
## The override file. Do not change this name to be entrypoint.sh.
## If it exists and this file ($0) is not the same it will be executed
ENTRYPOINT_OVERRIDE=${DATA_DIR}/bin/entrypoint_override.sh
##ENTRYPOINT_OVERRIDE=/tmp/foo

PATH=$HOMEDIR/bin:$PATH

# echo key parameters for debug
for X in NOW DATA_DIR CONF_DIR SQLLITE_DIR HTML_DIR CONF_FILE DIST_CONF_FILE ARCHIVE_CONF_FILE ENTRYPOINT_OVERRIDE
do
  eval Y='$'$X
  echo ${X} "is" ${Y}
done


# Check to see if this is the standard entrypoint and an override exists
if [ "$0" = $ENTRYPOINT_OVERRIDE ]; then
  echo "This is the override entrypoint file" $0
else
  echo "This is the standard entrypointfile" $0
  if [ -x ${ENTRYPOINT_OVERRIDE} ]; then
    echo "Exec Override ${ENTRYPOINT_OVERRIDE} $@"
    exec ${ENTRYPOINT_OVERRIDE} $@
  fi
fi

if [ $# -lt 1 ]; then
  echo "STARTING WEEWX - no special arguments"
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
  if [ ! -d ${CONF_DIR} ]; then
    mkdir -p ${CONF_DIR}
  fi
  if [ ! -d ${SQLLITE_DIR} ]; then
    mkdir -p ${SQLLITE_DIR}
  fi
  if [ ! -d ${HTML_DIR} ]; then
    mkdir -p ${HTML_DIR}
  fi

  cp ${DIST_CONF_FILE} ${CONF_FILE}
  chmod 755 ${CONF_FILE}
  echo "chown ${WEEWX_UID:-weewx} ${CONF_FILE}"
  chown ${WEEWX_UID:-weewx} ${CONF_FILE}
  echo "default file copied"

  # Change 2 areas which will emit data
  # Change default sql location
  sed -i "s;SQLITE_ROOT =.*;SQLITE_ROOT = ${SQLLITE_DIR};g" "${CONF_FILE}"
  # Change default html location
  sed -i "s;HTML_ROOT =.*;HTML_ROOT = ${HTML_DIR};g" "${CONF_FILE}"
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
  if [ -x ${SYSLOG} ]; then
    ${SYSLOG} -n -S -O - &
  else
    echo "SYSLOG daemon ${SYSLOG} not available"
  fi
else
  echo "SYSLOG already running"
fi

echo "STARTING WEEWX"
echo "exec ${WEEWX_DAEMON} $CONF_FILE"

exec ${WEEWX_DAEMON} $CONF_FILE
