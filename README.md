# HAProxy (with rsyslogd) and Keepalived in Docker

## Quick start
```bash
# Start 5 web servers with 2 proxy servers
docker-compose up -d --scale web=5 --scale proxy=2
# show logs of the proxy container
docker-compose logs -f proxy
```

```bash
# Access the virtual IP specified in docker-compose.yml
curl -v 172.18.0.101
# Access Statistics Report
curl -v 172.18.0.101:8080
```

## Testing
```bash
# Stop the proxy container in MASTER state
docker stop docker-haproxy_proxy_1
curl -v 172.18.0.101

# Then start it again
#   The priority in keepalived.conf is a random integer so that
#   the container might enter MASTER or BACKUP state which depends
#   on the priority is higher or lower than the priority in another
#   proxy container
docker start docker-haproxy_proxy_1
curl -v 172.18.0.101
```

## Environment
```bash
$ cat /etc/redhat-release
CentOS Linux release 7.6.1810

$ docker --version
Docker version 1.13.1, build 7f2769b/1.13.1

$ docker-compose --version
docker-compose version 1.24.1, build 4667896b

$ docker images --format "{{.Repository}}:{{.Tag}}"
docker.io/nginx:1.17.3-alpine
docker.io/haproxy:2.0.7-alpine
```

## Details
- rsyslogd
  - install - [`apk add rsyslog`](https://github.com/jbobos/docker-haproxy/blob/master/proxy/Dockerfile#L12)
  - config - [`rsyslog.conf`](https://github.com/jbobos/docker-haproxy/blob/master/proxy/rsyslog.conf)
  - define [`local0`](https://github.com/jbobos/docker-haproxy/blob/master/proxy/rsyslog.conf#L18) which we will refer in the haproxy.cfg to haproxy.log
  - link haproxy.log to [`stdout`](https://github.com/jbobos/docker-haproxy/blob/master/proxy/Dockerfile#L19)

- HAProxy
  - log to [`local0`](https://github.com/jbobos/docker-haproxy/blob/master/proxy/haproxy.cfg#L11) (i.e., stdout)
  - use [`docker dns resolver`](https://github.com/jbobos/docker-haproxy/blob/master/proxy/haproxy.cfg#L25)
  - response header [`X-Server`](https://github.com/jbobos/docker-haproxy/blob/master/proxy/haproxy.cfg#L43) to indicate which server was chosen
  - use [`server-template`](https://github.com/jbobos/docker-haproxy/blob/master/proxy/haproxy.cfg#L45) to initialize multiple servers
  - if haproxy stats access permission denied - https://stackoverflow.com/questions/26420729/haproxy-health-check-permission-denied

- Keepalived
  - install - [`apk add keepalived`](https://github.com/jbobos/docker-haproxy/blob/master/proxy/Dockerfile#L12)
  - config - [`keepalived.conf`](https://github.com/jbobos/docker-haproxy/blob/master/proxy/keepalived.conf)
  - automatically determine master/backup by [`random priority`](https://github.com/jbobos/docker-haproxy/blob/master/proxy/keepalived.conf#L7)
  - automatically [figure out](https://github.com/jbobos/docker-haproxy/blob/master/proxy/entrypoint.sh#L19) [`multicast source ip`](https://github.com/jbobos/docker-haproxy/blob/master/proxy/keepalived.conf#L9)
  - use official [`entrypoint script`](https://github.com/jbobos/docker-haproxy/blob/master/proxy/entrypoint.sh#L40)
  - according [`arc-ts' prerequisites`](https://github.com/arc-ts/keepalived#prerequisites)
    - should do `sysctl net.ipv4.ip_nonlocal_bind=1`, but seems not necessary to me
    - host networking parameter `--net=host` can be [`configured in docker-compose.yml`](https://github.com/jbobos/docker-haproxy/blob/master/docker-compose.yml#L24)

## Reference
- https://github.com/arc-ts/keepalived
- https://docs.docker.com/v17.09/compose/compose-file/#host-or-none
