#!/bin/bash

# ✅ Si GLPI ya está instalado, elimina el instalador por seguridad
if [ -f /var/www/html/config/config_db.php ]; then
    echo "GLPI ya está instalado, eliminando install.php..."
    rm -f /var/www/html/install/install.php
else
    echo "GLPI no está instalado, conservando install.php."
fi

# ▶️ Ejecuta PHP-FPM en primer plano
exec php-fpm -F
