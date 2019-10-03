# HAProxy and Web containers with Docker compose
# http://www.inanzzz.com/index.php/post/w14j/creating-a-single-haproxy-and-two-apache-containers-with-docker-compose
#
# official base image
FROM haproxy:2.0.7-alpine

# Make rsyslog to stdout
# https://ops.tips/gists/haproxy-docker-container-logs/
# https://github.com/mminks/haproxy-docker-logging
RUN set -ex	\
  && apk update \
  && apk add --no-cache rsyslog keepalived dumb-init \
  && rm -rf /var/cache/apk/* \
  && touch /var/log/haproxy.log \
  # here's the catch: by creating a soft-link that
  # links /var/log/haproxy.log to /dev/stdout whatever
  # rsyslogd writes to the file will endup being
  # propagated to the standard output of the container
  && ln -sf /dev/stdout /var/log/haproxy.log

# Configurations
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY rsyslog.conf /etc/rsyslog.conf
COPY keepalived.master.conf /etc/keepalived/keepalived.master.conf
COPY keepalived.backup.conf /etc/keepalived/keepalived.backup.conf

# Include our custom entrypoint that will the the job of lifting
# rsyslog alongside haproxy.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Set our custom entrypoint as the image's default entrypoint
ENTRYPOINT ["dumb-init", "entrypoint.sh"]

# Make haproxy use the default configuration file
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]

