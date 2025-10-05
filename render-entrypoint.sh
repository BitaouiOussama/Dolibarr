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

    # Copy to PHP conf directory for MySQL SSL
    mkdir -p /usr/local/etc/php/conf.d
    cp /ca.pem /usr/local/etc/php/conf.d/ca.pem

    cat > /usr/local/etc/php/conf.d/mysql-ssl.ini << 'EOF'
; MySQL SSL Configuration for Aiven
mysqli.ssl_ca = "/ca.pem"
mysqli.ssl_verify_server_cert = Off
pdo_mysql.default_socket = ""
EOF
fi

# 2️⃣ Set environment variables for Dolibarr
export DOLI_DB_TYPE="${DOLI_DB_TYPE:-mysqli}"
export DOLI_DB_PORT="${DOLI_DB_PORT:-17031}"
export DOLI_INSTALL_AUTO="${DOLI_INSTALL_AUTO:-1}"
export DOLI_PROD="${DOLI_PROD:-1}"
export DOLI_URL_ROOT="${DOLI_URL_ROOT:- https://dolibarr-68ch.onrender.com}"

# 3️⃣ Prepare directories
echo "📁 Preparing Dolibarr directories..."
mkdir -p /var/www/html/conf
mkdir -p /var/www/documents

chown -R www-data:www-data /var/www/html
chown -R www-data:www-data /var/www/documents
chmod -R 777 /var/www/html/conf
chmod -R 777 /var/www/documents

# 4️⃣ Generate Dolibarr conf.php dynamically
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

echo "✅ conf.php created successfully:"
ls -l /var/www/html/conf/conf.php

# 5️⃣ Start Apache
echo "🌐 Starting Apache web server..."
apache2-foreground & 
APACHE_PID=$!

sleep 5
echo "✅ Apache is running (PID: $APACHE_PID)"

# 6️⃣ Test database connection (non-blocking)
(
    echo "🔍 Testing MySQL connectivity to Aiven..."
    if command -v mysql &> /dev/null; then
        if [ -f "/ca.pem" ]; then
            echo "🧪 Testing SSL connection..."
            timeout 15 mysql \
                --host="$DOLI_DB_HOST" \
                --port="$DOLI_DB_PORT" \
                --user="$DOLI_DB_USER" \
                --password="$DOLI_DB_PASS" \
                --ssl-ca=/ca.pem \
                --ssl-mode=REQUIRED \
                --connect-timeout=10 \
                --execute="SELECT 'SSL Connection SUCCESS' AS status; USE $DOLI_DB_NAME;" 2>&1 && \
            echo "✅ Database connection successful (SSL)" || \
            echo "❌ Database SSL connection failed"
        else
            echo "🧪 Testing non-SSL connection..."
            timeout 15 mysql \
                --host="$DOLI_DB_HOST" \
                --port="$DOLI_DB_PORT" \
                --user="$DOLI_DB_USER" \
                --password="$DOLI_DB_PASS" \
                --connect-timeout=10 \
                --execute="SELECT 'Connection SUCCESS' AS status; USE $DOLI_DB_NAME;" 2>&1 && \
            echo "✅ Database connection successful (non-SSL)" || \
            echo "❌ Database connection failed"
        fi
    fi
) &

# 7️⃣ Wait for Apache (keep container alive)
echo "🎯 Dolibarr is ready on $DOLI_URL_ROOT"
wait $APACHE_PID
