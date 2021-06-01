FROM node AS builder

ARG DEBIAN_FRONTEND=noninteractive \
    BYTEBIN_URL \
    SELFHOSTED=true

WORKDIR /opt/LuckPermsWeb

RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
    jq \
    moreutils \
 && git clone --recursive https://github.com/lucko/LuckPermsWeb.git . \
 && if [ ${BYTEBIN_URL} ]; then jq --arg bytebin_url ${BYTEBIN_URL} '.bytebin_url = $bytebin_url' config.json | sponge config.json; fi \
 && jq --argjson selfhosted ${SELFHOSTED} '.selfHosted = $selfhosted' config.json | sponge config.json \
 && npm install && npm run build \
 && apt-get autoremove --yes --purge \
 && apt-get clean \
 && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM bmoorman/ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive

ENV HTTPD_SERVERNAME=localhost \
    HTTPD_PORT=3703

RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
    apache2 \
    certbot \
    ssl-cert \
 && a2enmod \
    remoteip \
    rewrite \
    ssl \
 && a2dissite \
    000-default \
 && sed --in-place --regexp-extended \
    --expression 's|^(Include\s+ports\.conf)$|#\1|' \
    /etc/apache2/apache2.conf \
 && ln --symbolic --force /dev/stderr /var/log/apache2/error.log \
 && ln --symbolic --force /dev/stdout /var/log/apache2/access.log \
 && ln --symbolic --force /dev/stdout /var/log/apache2/other_vhosts_access.log \
 && apt-get autoremove --yes --purge \
 && apt-get clean \
 && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /opt/LuckPermsWeb/dist/ /var/www/html/
COPY apache2/ /etc/apache2/

VOLUME /config

EXPOSE ${HTTPD_PORT}

CMD ["/etc/apache2/start.sh"]

HEALTHCHECK --interval=60s --timeout=5s CMD /etc/apache2/healthcheck.sh || exit 1
