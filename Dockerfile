FROM php:7.2-cli-stretch

RUN apt-get update \
    && mkdir -p /usr/share/man/man1 /usr/share/man/man7 \
    && apt-get install -y wget gcc cmake g++ make autoconf build-essential python postgresql-client mariadb-client libpq-dev zlib1g-dev git unzip

VOLUME ["/monitor"]
COPY monitor-wait /bin/monitor-wait
COPY monitor-notify /bin/monitor-notify
RUN chmod a+x /bin/monitor-wait /bin/monitor-notify

COPY wait-for-it /bin/wait-for-it
RUN chmod a+x /bin/wait-for-it

RUN docker-php-ext-install bcmath pdo_pgsql pdo_mysql sockets zip

RUN pecl install xdebug \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable xdebug

RUN pecl install igbinary \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable igbinary

RUN mkdir -p /tmp/pear \
    && cd /tmp/pear \
    && pecl bundle redis \
    && cd redis \
    && phpize . \
    && ./configure --enable-redis-igbinary \
    && make \
    && make install \
    && cd ~ \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

RUN cd /tmp \
	&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');" \
    && chmod a+x /usr/local/bin/composer

VOLUME ["/app"]