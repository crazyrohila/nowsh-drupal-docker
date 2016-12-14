FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive
LABEL name "my-docker-deployment"
RUN apt-get update && apt-get install -y vim git apache2 php5 libapache2-mod-php5 php5-mysql php5-cli php5-gd php5-curl curl unzip cron && apt-get clean

# Setup PHP.
RUN sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/apache2/php.ini
RUN sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/cli/php.ini

# Setup Apache.
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www/' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's/VirtualHost \*:80/VirtualHost \*:\*/' /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

#Install Drupal
RUN rm -rf /var/www
RUN cd /var && \
  git clone --branch 8.2.x https://git.drupal.org/project/drupal.git && \
  mv /var/drupal* /var/www
RUN mkdir -p /var/www/sites/default/files && \
  chmod a+w /var/www/sites/default -R && \
  mkdir /var/www/sites/all/modules/contrib -p && \
  mkdir /var/www/sites/all/modules/custom && \
  mkdir /var/www/sites/all/themes/contrib -p && \
  mkdir /var/www/sites/all/themes/custom && \
  cp /var/www/sites/default/default.settings.php /var/www/sites/default/settings.php && \
  cp /var/www/sites/default/default.services.yml /var/www/sites/default/services.yml && \
  chmod 0664 /var/www/sites/default/settings.php && \
  chmod 0664 /var/www/sites/default/services.yml && \
  chown -R www-data:www-data /var/www/
COPY test.php /var/www
RUN cd /var/www && composer install
EXPOSE 80
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
