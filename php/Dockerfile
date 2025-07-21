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
    supervisor \
    autoconf \
    make \
    gcc \
    pkg-config

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

# Instala Redis desde código fuente
RUN git clone https://github.com/phpredis/phpredis.git /usr/src/php/ext/redis && \
    docker-php-ext-install redis

# Copia configuración personalizada de PHP
COPY php/php.ini /usr/local/etc/php/

# Copia Composer desde la imagen oficial
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ✅ Copia el código fuente ya descomprimido de GLPI al contenedor
COPY glpi /var/www/html

# Establece el directorio de trabajo
WORKDIR /var/www/html

# 🔍 Debug antes de ejecutar composer
RUN echo "📂 Listando contenido de /var/www/html" && \
    ls -l /var/www/html && \
    if [ ! -f composer.json ]; then echo "❌ composer.json NO encontrado en /var/www/html" && exit 1; fi

# Instala dependencias de GLPI y compila locales
RUN composer install --no-dev --optimize-autoloader --no-scripts || (echo "❌ composer install falló" && exit 1)

# 📥 Descarga archivos necesarios para inventory_format
RUN mkdir -p vendor/glpi-project/inventory_format/lib && \
    mkdir -p vendor/glpi-project/inventory_format/source_files && \
    echo "📥 Descargando archivos de hardware..." && \
    curl -o vendor/glpi-project/inventory_format/lib/pci.ids https://pci-ids.ucw.cz/v2.2/pci.ids && \
    curl -o vendor/glpi-project/inventory_format/lib/usb.ids http://www.linux-usb.org/usb.ids && \
    curl -o vendor/glpi-project/inventory_format/lib/oui.txt https://standards-oui.ieee.org/oui/oui.txt && \
    curl -o vendor/glpi-project/inventory_format/lib/iftype.csv https://www.iana.org/assignments/smi-numbers/smi-numbers-5.csv && \
    cp vendor/glpi-project/inventory_format/lib/pci.ids vendor/glpi-project/inventory_format/source_files/ && \
    cp vendor/glpi-project/inventory_format/lib/usb.ids vendor/glpi-project/inventory_format/source_files/ && \
    cp vendor/glpi-project/inventory_format/lib/oui.txt vendor/glpi-project/inventory_format/source_files/ && \
    cp vendor/glpi-project/inventory_format/lib/iftype.csv vendor/glpi-project/inventory_format/source_files/ && \
    echo "✅ Archivos de hardware descargados correctamente"

# 🏗️ Ejecuta build_hw_jsons ahora que tenemos los archivos
RUN php -f vendor/bin/build_hw_jsons || echo "⚠️ Ignorando fallo en build_hw_jsons"

# ⚠️ El siguiente comando es opcional: puede fallar por falta de entornos/hardware
RUN php bin/console dependencies install || echo "⚠️ Ignorando fallo en dependencies install"
RUN php bin/console locales:compile || echo "⚠️ Ignorando fallo en locales:compile"

RUN chown -R www-data:www-data /var/www/html

# Copia el entrypoint
COPY php/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]