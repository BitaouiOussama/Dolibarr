#!/bin/sh
set -e

# --- 1. Écrire le certificat SSL dans /ca.pem si défini ---
if [ -n "$MYSQL_SSL_CA" ]; then
    echo "📜 Writing SSL certificate to /ca.pem ..."
    echo "$MYSQL_SSL_CA" | base64 -d > /ca.pem
else
    echo "⚠️ No SSL certificate found in MYSQL_SSL_CA"
fi

# --- 2. Créer le fichier de configuration Dolibarr conf.php ---
CONF_PATH="/var/www/html/htdocs/conf/conf.php"
echo "📜 Generating Dolibarr configuration at $CONF_PATH ..."

mkdir -p /var/www/html/htdocs/conf
cat <<EOF > $CONF_PATH
<?php
// Dolibarr configuration generated at runtime

\$dolibarr_main_url_root='https://${RENDER_EXTERNAL_URL}';
\$dolibarr_main_document_root='/var/www/html/htdocs';
\$dolibarr_main_data_root='/var/www/html/documents';

\$dolibarr_main_db_host='${DOLI_DB_HOST}';
\$dolibarr_main_db_port='${DOLI_DB_PORT}';
\$dolibarr_main_db_name='${DOLI_DB_NAME}';
\$dolibarr_main_db_user='${DOLI_DB_USER}';
\$dolibarr_main_db_pass='${DOLI_DB_PASSWORD}';
\$dolibarr_main_db_type='mysqli';

\$dolibarr_main_db_ssl=1;
\$dolibarr_main_db_ssl_ca='/ca.pem';

\$dolibarr_main_authentication='dolibarr';
\$dolibarr_main_force_install=1;
EOF

# Donner les droits d'écriture au serveur web (Apache)
chown -R www-data:www-data /var/www/html/htdocs/conf
chmod 640 /var/www/html/htdocs/conf/conf.php

# --- 3. Lancer le serveur Apache et Dolibarr ---
echo "🚀 Starting Apache ..."
exec  apache2-foreground
