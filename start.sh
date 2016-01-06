#!/usr/bin/env bash

PREFIX=/opt/emoncms

docker run -d -p 80:80 -p 443:443 -v $PREFIX/emoncms:/var/www/emoncms -v $PREFIX/mysql:/var/lib/mysql -v $PREFIX/phpfiwa:/var/lib/phpfiwa -v $PREFIX/phpfina:/var/lib/phpfina -v $PREFIX/phptimeseries:/var/lib/phptimeseries -v $PREFIX/sessions:/var/lib/php5/sessions yourname/emoncms
