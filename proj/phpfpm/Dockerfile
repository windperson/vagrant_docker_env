FROM php:5-fpm
RUN apt-get update && apt-get -y install g++
RUN apt-get update && apt-get -y install libicu-dev php5-mysql php5-redis zlib1g-dev

RUN docker-php-ext-install intl mbstring zip mysqli pdo pdo_mysql

RUN pecl install -o -f redis xdebug \
    && rm -rf /tmp/pear \
    && echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini \
    && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/xdebug.so" > /usr/local/etc/php/conf.d/xdebug.ini \

COPY config/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY config/php.ini /usr/local/etc/php/php.ini
VOLUME /var/www/html
CMD ["php-fpm"]
