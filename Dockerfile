FROM php:7.2-cli-stretch

ENV BUILD_DEPS wget unzip gcc make autoconf
RUN apt-get update \
    && mkdir -p /usr/share/man/man1 /usr/share/man/man7 \
    && apt-get install -y $BUILD_DEPS python postgresql-client mariadb-client libpq-dev zlib1g-dev git

RUN mkdir /tmp/wait-for-it \
    && wget https://github.com/vishnubob/wait-for-it/archive/54d1f0bfeb6557adf8a3204455389d0901652242.zip -O wait-for-it.zip \
    && unzip wait-for-it.zip \
    && mv wait-for-it-54d1f0bfeb6557adf8a3204455389d0901652242/wait-for-it.sh /bin/wait-for-it \
    && rm -r /tmp/wait-for-it \
    && chmod a+x /bin/wait-for-it

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

RUN apt-get autoremove -y $BUILD_DEPS

VOLUME ["/app"]