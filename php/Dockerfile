FROM php:8.2-fpm

# Instala Node.js 20 y dependencias del sistema
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && apt-get install -y \
    nodejs \
    gettext \
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
    supervisor

# Instala extensiones PHP necesarias
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

# Instala Redis
RUN pecl install redis && docker-php-ext-enable redis

# Copia configuración personalizada de PHP
COPY php.ini /usr/local/etc/php/

# Copia Composer desde la imagen oficial
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copia el código de GLPI al contenedor
COPY glpi /var/www/html

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Instala dependencias de GLPI y compila locales
RUN composer install --no-dev --optimize-autoloader --no-scripts && \
    php bin/console dependencies install && \
    php bin/console locales:compile && \	
    chown -R www-data:www-data /var/www/html

# 🔐 Copia el entrypoint para eliminar install.php si GLPI ya está instalado
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Usa el entrypoint en lugar de CMD
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]