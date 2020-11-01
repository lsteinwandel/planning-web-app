FROM php:7.4-fpm-alpine

##############
### Basics ###
##############

WORKDIR /var/www
RUN rmdir /var/www/html
RUN chown www-data:www-data /var/www

# Install timezone change utils
RUN apk add --no-cache tzdata

# Tools to change the uid on run
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories && \
    apk add --no-cache shadow su-exec

# download composer in the latest stable release, create cache folder and gitve it to www-data
RUN curl -o composer-installer.php https://getcomposer.org/installer && \
    php composer-installer.php --version=1.10.17 --quiet --install-dir="/usr/local/bin" && \
    ln -s /usr/local/bin/composer.phar /usr/local/bin/composer && \
    rm composer-installer.php && \
    mkdir -p /home/www-data/.composer/cache && \
    chown -R www-data:www-data /home/www-data/.composer
ENV PATH="${PATH}:/home/www-data/.composer/vendor/bin"
VOLUME /home/www-data/.composer/cache

######################
### PHP Extensions ###
######################

# ext-xdebug
# Disable xdebug by default and add a script to reactivate
# Just add a COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini.bak in your project
RUN apk add --no-cache --virtual .build-deps autoconf g++ make && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    apk del .build-deps && \
    rm -rf /tmp/*
COPY xdebug.sh /
RUN mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.bak

# ext-mysql
RUN docker-php-ext-install pdo_mysql

# ext-apcu
#RUN apk add --no-cache --virtual .build-deps autoconf g++ make && \
#    pecl install apcu && \
#    docker-php-ext-enable apcu && \
#    apk del .build-deps && \
#    rm -rf /tmp/*

# ext-gmp
#RUN apk add --no-cache gmp && \
#    apk add --no-cache --virtual .build-deps gmp-dev && \
#    docker-php-ext-install gmp && \
#    apk del .build-deps && \
#    rm -rf /tmp/*

# ext-intl
RUN apk add --no-cache icu && \
    apk add --no-cache --virtual .build-deps icu-dev && \
    docker-php-ext-install intl  && \
    apk del .build-deps && \
    rm -rf /tmp/*

# ext-readline
#RUN apk add --no-cache --virtual .build-deps libedit-dev && \
#    docker-php-ext-install readline && \
#    apk del .build-deps && \
#    rm -rf /tmp/*

# ext-postgres
#RUN apk add --no-cache postgresql-dev && \
#    docker-php-ext-install pdo_pgsql && \
#    rm -rf /tmp/*

# ext-gd
RUN apk add --no-cache libpng && \
    apk add --no-cache --virtual .build-deps libpng-dev && \
    docker-php-ext-configure gd && \
    docker-php-ext-install gd && \
    apk del .build-deps && \
    rm -rf /tmp/*

# ext-zip
#RUN apk add --no-cache --virtual .build-deps zlib-dev && \
#    docker-php-ext-install zip && \
#    apk del .build-deps && \
#    rm -rf /tmp/*

# ext-imagick
#RUN apk add --no-cache --virtual .build-deps autoconf g++ make imagemagick-dev && \
#    apk add --no-cache imagemagick &&\
#    pecl install imagick && \
#    docker-php-ext-enable imagick &&\
#    apk del .build-deps && \
#    rm -rf /tmp/*

# ext-xsl
RUN apk add --no-cache libxslt && \
    apk add --no-cache --virtual .build-deps libxslt-dev && \
    docker-php-ext-install xsl  && \
    apk del .build-deps && \
    rm -rf /tmp/*

##############
### Extras ###
##############

# Prestissimo speeds up composer install
RUN su-exec www-data composer global require hirak/prestissimo

################################
### Config files and scripts ###
################################

# Default configuration for fpm
# Project-specific ini can be added with COPY ./php-ini-overrides.ini /usr/local/etc/php/conf.d/
COPY ./zz-fpm.conf /usr/local/etc/php-fpm.d/

# Script to wait for db
COPY wait-for /usr/local/bin

COPY entrypoint-chuid /usr/local/bin

# Project-specific ini settings
COPY ./php-ini-overrides.ini /usr/local/etc/php/conf.d/

# Project-specific xdebug settings
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini.bak

# Create folder for volumes
RUN mkdir -p /var/www/var
RUN mkdir -p /var/www/vendor
RUN chown -R www-data:www-data /var/www

ENTRYPOINT ["entrypoint-chuid"]
CMD ["php-fpm"]
