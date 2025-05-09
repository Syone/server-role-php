ARG PHP_VERSION=fpm
FROM php:${PHP_VERSION}

ARG PHP_EXTENSIONS="pdo_mysql exif gmp zip opcache mysqli intl"

RUN apt-get update && apt-get install -y \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
		libwebp-dev \
		libgmp-dev \
		libzip-dev \
		libicu-dev \
		libxml2-dev \
		imagemagick \
		pngquant \
		sendmail \
		libmemcached-dev libssl-dev \
		zlib1g-dev \
	&& pecl install memcached \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
	&& docker-php-ext-install -j$(nproc) gd ${PHP_EXTENSIONS} \
	&& docker-php-ext-enable memcached

RUN echo "sendmail_path=/usr/sbin/sendmail -t -i" >> /usr/local/etc/php/conf.d/sendmail.ini

RUN sed -i '/#!\/bin\/sh/aservice sendmail restart' /usr/local/bin/docker-php-entrypoint

RUN sed -i '/#!\/bin\/sh/aecho "$(hostname -i)\t$(hostname) $(hostname).localhost" >> /etc/hosts' /usr/local/bin/docker-php-entrypoint

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
