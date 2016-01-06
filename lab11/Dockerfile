FROM bradjc/emoncms

# For event plugin
RUN sudo sh -c 'echo "extension=mcrypt.so" > /etc/php5/fpm/conf.d/20-mcrypt.ini'

# Configure settings
RUN sed -i 's/$enable_multi_user = false;/$enable_multi_user = true;/g' /var/www/emoncms/settings.php
RUN sed -i 's/$max_node_id_limit = 32;/$max_node_id_limit = 32000;/g' /var/www/emoncms/settings.php

RUN git clone https://github.com/lab11/emoncms-wattsup /var/www/emoncms/Modules/wattsup
RUN git clone https://github.com/lab11/emoncms-ted /var/www/emoncms/Modules/ted
RUN git clone https://github.com/emoncms/event /var/www/emoncms/Modules/event
