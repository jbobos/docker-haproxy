# Dockerizing HAProxy (rsyslogd) with Keepalived

## Quick start
### Start containers
```bash
# scale to 5 web servers with 2 proxy
docker-compose up -d --scale web=5 --scale proxy=2
# show logs of the proxy container
docker logs -f proxy
```

### Access the virtual IP
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

