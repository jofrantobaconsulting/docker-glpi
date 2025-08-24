FROM php:8.2-fpm

# Instala dependencias del sistema
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    libxml2-dev \
    libldap2-dev \
    libicu-dev \
    zlib1g-dev \
    libcurl4-openssl-dev \
    supervisor \
    autoconf \
    make \
    gcc \
    pkg-config

# Instala extensiones PHP
RUN docker-php-ext-install \
    pdo_mysql \
    mysqli \
    mbstring \
    zip \
    xml \
    gd \
    ldap \
    exif \
    opcache \
    intl

# Instala Redis desde fuente
RUN git clone https://github.com/phpredis/phpredis.git /usr/src/php/ext/redis && \
    docker-php-ext-install redis

# Copia configuración PHP
COPY php/php.ini /usr/local/etc/php/

# Copia Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Define versión de GLPI
ENV GLPI_VERSION=10.0.19

# Descarga y descomprime GLPI
RUN mkdir -p /var/www/glpi && \
    curl -sSL https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz | \
    tar xz -C /var/www/glpi --strip-components=1

# 🔗 Enlaces simbólicos necesarios para acceso desde public/
RUN ln -s /var/www/glpi/front /var/www/glpi/public/front && \
    ln -s /var/www/glpi/ajax  /var/www/glpi/public/ajax

# Establece permisos
RUN chown -R www-data:www-data /var/www/glpi

# Copia script de inicio
COPY php/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/glpi

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]