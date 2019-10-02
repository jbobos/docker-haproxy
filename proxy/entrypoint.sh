#!/bin/sh

set -o errexit
set -o nounset

readonly RSYSLOG_PID="/var/run/rsyslogd.pid"

main() {
  start_keepalived
  start_rsyslogd
  start_haproxy "$@"
}

# make sure we have rsyslogd's pid file not
# created before
start_keepalived() {
  /usr/sbin/keepalived -n -l -D -f /etc/keepalived/keepalived.conf --dont-fork --log-console &
}

# make sure we have rsyslogd's pid file not
# created before
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
