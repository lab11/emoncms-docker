#!/usr/bin/env bash

PREFIX=/opt/emoncms;

docker run --rm -v $PREFIX:/host yourname/emoncms cp -rp {/var/www/emoncms,/var/lib/mysql,/var/lib/phpfina,/var/lib/phpfiwa,/var/lib/phptimeseries} /host/
