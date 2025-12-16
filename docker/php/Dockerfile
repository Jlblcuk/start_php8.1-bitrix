FROM php:8.1-fpm

# Зависимости
RUN apt-get update && apt-get install -y \
    curl \
    git \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libwebp-dev \
    libxpm-dev \
    libldb-dev \
    libldap2-dev \
    libldap-common \
    libicu-dev \
    pkg-config \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
        --with-xpm \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo_mysql \
        mysqli \
        mbstring \
        exif \
        pcntl \
        bcmath \
        zip \
        soap \
        intl \
        opcache \
        calendar \
        ldap \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Установка Composer (для будущих модулей через Packagist, если понадобится)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Настройки PHP для Bitrix
RUN { \
        echo 'opcache.enable=1'; \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'realpath_cache_size=4096K'; \
        echo 'realpath_cache_ttl=600'; \
        echo 'memory_limit=512M'; \
        echo 'post_max_size=100M'; \
        echo 'upload_max_filesize=100M'; \
        echo 'max_execution_time=300'; \
        echo 'date.timezone=Europe/Moscow'; \
    } > /usr/local/etc/php/conf.d/bitrix.ini

# Set working directory
WORKDIR /var/www
