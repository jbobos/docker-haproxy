#!/bin/sh

set -o errexit
set -o nounset

readonly RSYSLOG_PID="/var/run/rsyslogd.pid"
readonly KEEPALIVED_PID="/var/run/keepalived"
readonly KEEPALIVED_CONF="/etc/keepalived/keepalived.conf"

main() {
  start_keepalived
  start_rsyslogd
  start_haproxy "$@"
}

# make sure we have keepalived's pid file not created before
start_keepalived() {
  # find the target ip and set it to KEEPALIVED_SRC_IP
  bind_target="$(ip addr show eth0 | grep -m 1 -E -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $2}')"
  # set it as KEEPALIVED_SRC_IP
  sed -i 's/$KEEPALIVED_SRC_IP/'"$bind_target"'/g' $KEEPALIVED_CONF

  # delete keepalived's pid
  rm -rf $KEEPALIVED_PID
  # start keepalived
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
