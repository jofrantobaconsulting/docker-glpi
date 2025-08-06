FROM php:8.2-fpm

# Instala solo las dependencias necesarias del sistema
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    libxml2-dev \
    libldap2-dev \
    libicu-dev \
    unzip \
    git \
    curl \
    libcurl4-openssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Instala extensiones PHP requeridas por GLPI
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

# Instala la extensión Redis desde código fuente
RUN git clone https://github.com/phpredis/phpredis.git /usr/src/php/ext/redis && \
    docker-php-ext-install redis

# Copia el archivo de configuración PHP
COPY php/php.ini /usr/local/etc/php/

# Define la versión de GLPI a instalar
ENV GLPI_VERSION=10.0.19

# Descarga y descomprime GLPI desde el release oficial
RUN curl -sSL https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz -o /tmp/glpi.tgz && \
    mkdir -p /var/www/html && \
    tar -xzf /tmp/glpi.tgz -C /var/www/html --strip-components=1 && \
    rm -rf /tmp/glpi.tgz

# Asigna permisos a www-data
RUN chown -R www-data:www-data /var/www/html

# Copia el entrypoint del contenedor
COPY php/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Define el directorio de trabajo y el entrypoint
WORKDIR /var/www/html
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]