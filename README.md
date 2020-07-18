### Docker Run
```
docker run \
--detach \
--name luckpermsweb \
--restart unless-stopped \
--publish 3703:3703 \
--volume luckpermsweb-config:/config \
bmoorman/luckpermsweb:latest
```

### Docker Compose
```
version: "3.7"
services:
  luckpermsweb:
    image: bmoorman/luckpermsweb:latest
    container_name: luckpermsweb
    restart: unless-stopped
    ports:
      - "3703:3703"
    volumes:
      - luckpermsweb-config:/config

volumes:
  luckpermsweb-config:
```

### Environment Variables
|Variable|Description|Default|
|--------|-----------|-------|
|TZ|Sets the timezone|`America/Denver`|
|HTTPD_SERVERNAME|Sets the vhost servername|`localhost`|
|HTTPD_PORT|Sets the vhost port|`3703`|
|HTTPD_SSL|Set to anything other than `SSL` (e.g. `NO_SSL`) to disable SSL|`SSL`|
|HTTPD_REDIRECT|Set to anything other than `REDIRECT` (e.g. `NO_REDIRECT`) to disable SSL redirect|`REDIRECT`|
