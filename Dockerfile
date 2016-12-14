FROM ubuntu:14.04
MAINTAINER Sanjay Rohila (@crazyrohila)

RUN apt-get update && apt-get install -y git apache2 php5 libapache2-mod-php5 php5-mysql php5-cli php5-gd php5-curl curl && apt-get clean && rm -rf /var/lib/apt/lists/*

# Apache envvars
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid

# Setup apache
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN a2enmod rewrite

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

#Install Drupal
RUN rm -rf /var/www/html
RUN cd /var/www && \
  git clone --branch 8.2.x https://git.drupal.org/project/drupal.git html
RUN mkdir -p /var/www/html/sites/default/files && \
  chmod a+w /var/www/html/sites/default -R && \
  mkdir /var/www/html/sites/all/modules/contrib -p && \
  mkdir /var/www/html/sites/all/modules/custom && \
  mkdir /var/www/html/sites/all/themes/contrib -p && \
  mkdir /var/www/html/sites/all/themes/custom && \
  cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php && \
  cp /var/www/html/sites/default/default.services.yml /var/www/html/sites/default/services.yml && \
  chmod 0664 /var/www/html/sites/default/settings.php && \
  chmod 0664 /var/www/html/sites/default/services.yml && \
  chown -R www-data:www-data /var/www/html/

# Install dependency
RUN cd /var/www/html && composer install

EXPOSE 80

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
