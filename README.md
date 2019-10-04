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
```
