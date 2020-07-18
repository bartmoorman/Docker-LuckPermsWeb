FROM bmoorman/ubuntu:bionic AS builder

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /opt/LuckPermsWeb

RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
    git \
    jq \
    npm \
 && npm install -g npm@latest && hash -r \
 && git clone --recursive https://github.com/lucko/LuckPermsWeb.git . \
 && tmp=$(mktemp) && jq '.selfHosted = true' config.json > ${tmp} && mv ${tmp} config.json \
 && npm install && npm run build \
 && apt-get autoremove --yes --purge \
 && apt-get clean \
 && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM bmoorman/ubuntu:bionic

ARG DEBIAN_FRONTEND=noninteractive

ENV HTTPD_SERVERNAME=localhost \
    HTTPD_PORT=3703

RUN echo 'deb http://ppa.launchpad.net/certbot/certbot/ubuntu bionic main' > /etc/apt/sources.list.d/certbot.list \
 && echo 'deb-src http://ppa.launchpad.net/certbot/certbot/ubuntu bionic main' >> /etc/apt/sources.list.d/certbot.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8C47BE8E75BCA694 \
 && apt-get update \
 && apt-get install --yes --no-install-recommends \
    apache2 \
    certbot \
    curl \
    ssl-cert \
 && a2enmod \
    remoteip \
    rewrite \
    ssl \
 && sed --in-place --regexp-extended \
    --expression 's/^(Include\s+ports\.conf)$/#\1/' \
    /etc/apache2/apache2.conf \
 && apt-get autoremove --yes --purge \
 && apt-get clean \
 && rm --recursive --force /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /opt/LuckPermsWeb/dist/ /var/www/html/
COPY apache2/ /etc/apache2/

VOLUME /config

EXPOSE ${HTTPD_PORT}

CMD ["/etc/apache2/start.sh"]

HEALTHCHECK --interval=60s --timeout=5s CMD /etc/apache2/healthcheck.sh || exit 1
