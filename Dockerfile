FROM ubuntu
MAINTAINER https://github.com/mdef

ENV DEBIAN_FRONTEND noninteractive

# Install needed packages
RUN apt-get update
RUN apt-get install -y mysql-server mysql-client php5-fpm php5-mysql php5-curl \
    php-pear php5-dev php5-mcrypt php5-json git-core redis-server build-essential \
    ufw ntp nginx supervisor vim pwgen

# Install dependencies for PHP/emoncms
RUN pear channel-discover pear.swiftmailer.org
RUN pecl install channel://pecl.php.net/dio-0.0.6 redis swift/swift
RUN sh -c 'echo "extension=dio.so" > /etc/php5/cli/conf.d/20-dio.ini'
RUN sh -c 'echo "extension=redis.so" > /etc/php5/cli/conf.d/20-redis.ini'
RUN sh -c 'echo "extension=redis.so" > /etc/php5/fpm/conf.d/20-redis.ini'

# Configure directories for emoncms
RUN mkdir /var/lib/{phpfiwa,phpfina,phptimeseries}
RUN chown www-data:root /var/lib/{phpfiwa,phpfina,phptimeseries}
RUN mkdir -p /var/www/emoncms
RUN chown www-data:www-data /var/www/emoncms
RUN mkdir /var/lib/php5/sessions
RUN chown www-data:www-data /var/lib/php5/sessions


# Get latest source of emoncms. Also install a plugin which should be
# default.
RUN git clone https://github.com/emoncms/emoncms.git /var/www/emoncms
RUN git clone https://github.com/emoncms/app.git /var/www/emoncms/Modules/app

# Create the settings.php file and enable redis
RUN cp /var/www/emoncms/default.settings.php /var/www/emoncms/settings.php
RUN sed -i 's/$redis_enabled = false;/$redis_enabled = true;/g' /var/www/emoncms/settings.php

# Configure where to store PHP sessions
RUN sed -i 's/;session.save_path = "\/var\/lib\/php5"/session.save_path = "\/var\/lib\/php5\/sessions"/g' /etc/php5/fpm/php.ini

# Configure nginx webserver
ADD ./emoncms.conf /etc/nginx/conf.d/emoncms.conf

# Add setup script that configures things like the MySQL database
ADD setup.sh /setup.sh
RUN chmod 755 /setup.sh

# Add supervisor configurations
ADD supervisor/mysql.conf /etc/supervisor/conf.d/mysql.conf
ADD supervisor/nginx.conf /etc/supervisor/conf.d/nginx.conf
ADD supervisor/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf
ADD supervisor/redis.conf /etc/supervisor/conf.d/redis.conf

# Expose these volumes so they can be mounted on the host. This lets
# them be persistent.
VOLUME ["/var/lib/mysql"]
VOLUME ["/var/www/emoncms"]
VOLUME ["/var/lib/phpfiwa"]
VOLUME ["/var/lib/phpfina"]
VOLUME ["/var/lib/phptimeseries"]

# We want to go with the setup script when the docker image starts.
# This will call supervisor to get things going when it finishes.
CMD ["/setup.sh"]
