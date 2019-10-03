#!/bin/sh

set -o errexit
set -o nounset

readonly RSYSLOG_PID="/var/run/rsyslogd.pid"
readonly KEEPALIVED_PID="/var/run/keepalived"
readonly KEEPALIVED_CONF="/etc/keepalived/keepalived.$KEEPALIVED_STATE.conf"

main() {
  start_keepalived
  start_rsyslogd
  start_haproxy "$@"
}

# make sure we have keepalived's pid file not created before
start_keepalived() {
  rm -rf $KEEPALIVED_PID
  /usr/sbin/keepalived -n -l -D -f $KEEPALIVED_CONF --dont-fork --log-console &
}

# make sure we have rsyslogd's pid file not created before
start_rsyslogd() {
  rm -f $RSYSLOG_PID
  rsyslogd
}

# Starts the load-balancer (haproxy) with 
# whatever arguments we pass to it ("$@")
start_haproxy() {
  exec /docker-entrypoint.sh "$@"
}

main "$@"
