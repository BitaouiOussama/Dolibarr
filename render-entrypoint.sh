#!/bin/bash
set -e

echo "🚀 Starting Dolibarr with Aiven MySQL database..."

# 1️⃣ Handle SSL certificate for Aiven
if [ -n "$MYSQL_SSL_CA" ]; then
    echo "📜 Writing Aiven SSL certificate to /ca.pem..."
    echo "$MYSQL_SSL_CA" | base64 -d > /ca.pem
    chown www-data:www-data /ca.pem
    chmod 600 /ca.pem
    echo "✅ SSL certificate setup complete"

    mkdir -p /usr/local/etc/php/conf.d
    cp /ca.pem /usr/local/etc/php/conf.d/ca.pem

    cat > /usr/local/etc/php/conf.d/mysql-ssl.ini << 'EOF'
; MySQL SSL Configuration for Aiven
mysqli.ssl_ca = "/ca.pem"
mysqli.ssl_verify_server_cert = Off
pdo_mysql.default_socket = ""
EOF
fi

# 2️⃣ Dolibarr environment variables
export DOLI_DB_TYPE="${DOLI_DB_TYPE:-mysqli}"
export DOLI_DB_PORT="${DOLI_DB_PORT:-17031}"
export DOLI_INSTALL_AUTO="${DOLI_INSTALL_AUTO:-1}"
export DOLI_PROD="${DOLI_PROD:-1}"
export DOLI_URL_ROOT="${DOLI_URL_ROOT:-https://dolibarr-68ch.onrender.com}"

# 3️⃣ Prepare Dolibarr directories
echo "📁 Preparing Dolibarr directories..."
mkdir -p /var/www/html/conf
mkdir -p /var/www/documents
chown -R www-data:www-data /var/www/html /var/www/documents
chmod -R 777 /var/www/html/conf /var/www/documents

# 4️⃣ Generate conf.php dynamically
echo "🛠️ Generating /var/www/html/conf/conf.php..."
cat > /var/www/html/conf/conf.php << EOF
<?php
\$dolibarr_main_url_root='${DOLI_URL_ROOT}';
\$dolibarr_main_document_root='/var/www/html';
\$dolibarr_main_url_root_alt='/custom';
\$dolibarr_main_document_root_alt='/var/www/html/custom';
\$dolibarr_main_data_root='/var/www/documents';
\$dolibarr_main_db_host='${DOLI_DB_HOST}';
\$dolibarr_main_db_port='${DOLI_DB_PORT}';
\$dolibarr_main_db_name='${DOLI_DB_NAME}';
\$dolibarr_main_db_user='${DOLI_DB_USER}';
\$dolibarr_main_db_pass='${DOLI_DB_PASS}';
\$dolibarr_main_db_type='${DOLI_DB_TYPE}';
\$dolibarr_main_db_prefix='llx_';
\$dolibarr_main_authentication='dolibarr';
\$dolibarr_main_prod=1;
\$dolibarr_main_instance_unique_id='myinstanceuniquekey';
EOF

chown www-data:www-data /var/www/html/conf/conf.php
chmod 666 /var/www/html/conf/conf.php
echo "✅ conf.php created successfully."

# 5️⃣ Start Apache in background
echo "🌐 Starting Apache web server..."
apache2-foreground & 
APACHE_PID=$!
sleep 5
echo "✅ Apache is running (PID: $APACHE_PID)"

# 6️⃣ Check if Dolibarr database is initialized
echo "🔍 Checking if Dolibarr DB is empty..."
TABLE_COUNT=$(mysql --host="$DOLI_DB_HOST" \
                    --port="$DOLI_DB_PORT" \
                    --user="$DOLI_DB_USER" \
                    --password="$DOLI_DB_PASS" \
                    --silent --skip-column-names \
                    -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${DOLI_DB_NAME}';" || echo "0")

if [ "$TABLE_COUNT" = "0" ]; then
    echo "⚙️ Database is empty — running Dolibarr CLI installer..."
    php /var/www/html/htdocs/install/cli_install.php \
        --db_host="$DOLI_DB_HOST" \
        --db_port="$DOLI_DB_PORT" \
        --db_user="$DOLI_DB_USER" \
        --db_pass="$DOLI_DB_PASS" \
        --db_name="$DOLI_DB_NAME" \
        --admin_login="admin" \
        --admin_pass="admin" \
        --force_install=1 \
        --noremove=1 \
        --disable_utf8mb4=0 || echo "⚠️ Dolibarr installer may have already run."
    echo "✅ Dolibarr initialized (admin/admin)"
else
    echo "✅ Database already contains $TABLE_COUNT tables — skipping installation."
fi

# 7️⃣ Keep container alive
echo "🎯 Dolibarr is ready at $DOLI_URL_ROOT"
wait $APACHE_PID
