#!/bin/sh

# 1️⃣ Écrire le certificat SSL si fourni
if [ -n "$MYSQL_SSL_CA" ]; then
    echo "📜 Writing SSL certificate to /ca.pem ..."
    echo "$MYSQL_SSL_CA" | base64 -d > /ca.pem
    chown www-data:www-data /ca.pem
    chmod 600 /ca.pem
else
    echo "⚠️ No SSL certificate found in MYSQL_SSL_CA"
fi

# 2️⃣ Créer conf.php dynamiquement
CONF_FILE="/var/www/html/htdocs/conf/conf.php"
mkdir -p "$(dirname "$CONF_FILE")"
cat > "$CONF_FILE" <<EOL
<?php
\$dolibarr_main_url_root = 'https://dolibarr-68ch.onrender.com';
\$dolibarr_main_document_root = '/var/www/html/htdocs';
\$dolibarr_main_data_root = '/var/www/html/documents';
\$dolibarr_main_db_host = '$DOLI_DB_HOST';
\$dolibarr_main_db_port = '$DOLI_DB_PORT';
\$dolibarr_main_db_name = '$DOLI_DB_NAME';
\$dolibarr_main_db_user = '$DOLI_DB_USER';
\$dolibarr_main_db_pass = '$DOLI_DB_PASS';
\$dolibarr_main_db_type = 'mysqli';
\$dolibarr_main_db_ssl = 1;
\$dolibarr_main_db_ssl_ca = '/ca.pem';
\$dolibarr_main_authentication = 'dolibarr';
\$dolibarr_main_force_install = 1;
EOL

chown www-data:www-data "$CONF_FILE"
chmod 640 "$CONF_FILE"

# 3️⃣ Lancer Apache
exec apache2-foreground
