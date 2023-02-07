#!/usr/bin/env bash
chown www-data: /config

if [ ! -d /config/httpd/ssl ]; then
    install --directory /config/httpd/ssl
    ln --symbolic --force /etc/ssl/certs/ssl-cert-snakeoil.pem /config/httpd/ssl/luckpermsweb.crt
    ln --symbolic --force /etc/ssl/private/ssl-cert-snakeoil.key /config/httpd/ssl/luckpermsweb.key
fi

pidfile=/var/run/apache2/apache2.pid

if [ -f ${pidfile} ]; then
    pid=$(cat ${pidfile})

    if [ ! -d /proc/${pid} ] || [ -d /proc/${pid} -a $(basename $(readlink /proc/${pid}/exe)) != 'apache2' ]; then
        rm ${pidfile}
    fi
fi

exec $(which apache2ctl) \
    -D FOREGROUND \
    -D ${HTTPD_SSL:-SSL} \
    -D ${HTTPD_REDIRECT:-REDIRECT}
