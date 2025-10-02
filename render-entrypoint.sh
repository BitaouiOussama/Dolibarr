#!/bin/sh
set -e

# Écrire le certificat SSL si défini
if [ -n "$MYSQL_SSL_CA" ]; then
    echo "📜 Writing SSL certificate to /ca.pem ..."
    echo "$MYSQL_SSL_CA" | base64 -d > /ca.pem
fi

# Créer conf.php si nécessaire
CONF_FILE="/var/www/html/htdocs/conf/conf.php"
if [ ! -f "$CONF_FILE" ]; then
    echo "⚠️ conf.php not found, creating auto-install config..."
    mkdir -p /var/www/html/htdocs/conf
    cat > "$CONF_FILE" <<EOL
<?php
\$dolibarr_main_url_root='${DOLI_URL_ROOT}';
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
\$dolibarr_main_admin_user='${DOLI_ADMIN_USER}';
\$dolibarr_main_admin_pass='${DOLI_ADMIN_PASS}';
\$dolibarr_main_admin_mail='${DOLI_ADMIN_MAIL}';
EOL
    chmod 777 "$CONF_FILE"
fi

# Créer dossier documents
mkdir -p /var/www/html/documents
chmod 777 /var/www/html/documents

# Lancer Apache
exec apache2-foreground
