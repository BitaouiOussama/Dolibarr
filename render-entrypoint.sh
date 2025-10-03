#!/bin/bash
set -e

echo "🚀 Starting Dolibarr with Aiven database..."

# 1️⃣ Handle SSL certificate for Aiven
if [ -n "$MYSQL_SSL_CA" ]; then
    echo "📜 Writing Aiven SSL certificate to /ca.pem..."
    echo "$MYSQL_SSL_CA" | base64 -d > /ca.pem
    chown www-data:www-data /ca.pem
    chmod 600 /ca.pem
    echo "✅ SSL certificate setup complete"
    
    # Also copy to PHP certs directory
    mkdir -p /usr/local/etc/php/conf.d
    cp /ca.pem /usr/local/etc/php/conf.d/ca.pem
fi

# 2️⃣ Set your Aiven database credentials
export DOLI_DB_HOST="${DOLI_DB_HOST}"
export DOLI_DB_USER="${DOLI_DB_USER}" 
export DOLI_DB_PASS="${DOLI_DB_PASS}"
export DOLI_DB_NAME="${DOLI_DB_NAME}"
export DOLI_DB_HOST_PORT="${DOLI_DB_PORT:-17031}"
export DOLI_DB_TYPE="${DOLI_DB_TYPE:-mysqli}"
export DOLI_INSTALL_AUTO="${DOLI_INSTALL_AUTO:-1}"
export DOLI_PROD="${DOLI_PROD:-1}"

# 3️⃣ Create a custom PHP configuration for MySQL SSL
if [ -f "/ca.pem" ]; then
    echo "🔧 Configuring PHP for MySQL SSL..."
    cat > /usr/local/etc/php/conf.d/mysql-ssl.ini << 'EOF'
; MySQL SSL Configuration for Aiven
mysqli.ssl_ca = "/ca.pem"
mysqli.ssl_verify_server_cert = Off
pdo_mysql.default_socket = ""
EOF
fi

# 4️⃣ Créer la configuration Dolibarr en avance avec les bonnes permissions
echo "📄 Creating Dolibarr configuration directory..."
mkdir -p /var/www/html/htdocs/conf

# Créer le fichier conf.php avec les bonnes permissions
touch /var/www/html/htdocs/conf/conf.php
chown -R www-data:www-data /var/www/html/htdocs/conf
chmod 775 /var/www/html/htdocs/conf
chmod 666 /var/www/html/htdocs/conf/conf.php

# Créer aussi le répertoire documents
mkdir -p /var/www/documents
chown -R www-data:www-data /var/www/documents
chmod 775 /var/www/documents

echo "✅ Directories and permissions configured"

# 5️⃣ Option pour forcer la création du fichier conf.php avec du contenu initial
if [ "$DOLI_INSTALL_FORCE_CREATE_CONF" = "1" ]; then
    echo "🔧 Force creating conf.php with initial configuration..."
    cat > /var/www/html/htdocs/conf/conf.php << EOF
<?php
// Dolibarr configuration file
// This file will be completed by Dolibarr install process
\$dolibarr_main_url_root='${DOLI_URL_ROOT:-https://dolibarr-68ch.onrender.com}';
\$dolibarr_main_document_root='/var/www/html/htdocs';
\$dolibarr_main_data_root='/var/www/documents';
EOF
    chown www-data:www-data /var/www/html/htdocs/conf/conf.php
    chmod 666 /var/www/html/htdocs/conf/conf.php
    echo "✅ conf.php created with initial content"
fi

# 6️⃣ DÉMARRER APACHE IMMÉDIATEMENT (avant le test de connexion)
echo "🌐 Starting Apache web server..."
apache2-foreground &
APACHE_PID=$!

# Attendre qu'Apache soit prêt
sleep 3
echo "✅ Apache is starting (PID: $APACHE_PID)..."

# 7️⃣ Test database connection en arrière-plan (ne bloque pas Apache)
(
    echo "🔍 Testing database connectivity in background..."
    sleep 5  # Donner le temps à Apache de bien démarrer
    
    if command -v mysql &> /dev/null && [ -n "$DOLI_DB_HOST" ]; then
        echo "Testing connection to: $DOLI_DB_HOST:$DOLI_DB_HOST_PORT"
        
        if [ -f "/ca.pem" ]; then
            # Test with SSL
            timeout 15 mysql \
                --host="$DOLI_DB_HOST" \
                --user="$DOLI_DB_USER" \
                --password="$DOLI_DB_PASS" \
                --port="$DOLI_DB_HOST_PORT" \
                --ssl-ca=/ca.pem \
                --ssl-mode=REQUIRED \
                --connect-timeout=10 \
                --execute="SELECT 'SSL Connection: SUCCESS' AS status; USE $DOLI_DB_NAME;" 2>&1 && {
                echo "✅ Database connection successful with SSL"
            } || {
                echo "⚠️ SSL Connection failed, trying without SSL..."
                timeout 15 mysql \
                    --host="$DOLI_DB_HOST" \
                    --user="$DOLI_DB_USER" \
                    --password="$DOLI_DB_PASS" \
                    --port="$DOLI_DB_HOST_PORT" \
                    --connect-timeout=10 \
                    --execute="SELECT 'Non-SSL Connection: SUCCESS' AS status; USE $DOLI_DB_NAME;" 2>&1 && {
                    echo "✅ Database connection successful without SSL"
                } || {
                    echo "❌ Database connection failed"
                    echo "💡 Check your Aiven database credentials and firewall rules"
                }
            }
        else
            # Test without SSL
            timeout 15 mysql \
                --host="$DOLI_DB_HOST" \
                --user="$DOLI_DB_USER" \
                --password="$DOLI_DB_PASS" \
                --port="$DOLI_DB_HOST_PORT" \
                --connect-timeout=10 \
                --execute="SELECT 'Connection: SUCCESS' AS status; USE $DOLI_DB_NAME;" 2>&1 && {
                echo "✅ Database connection successful"
            } || {
                echo "❌ Database connection failed"
            }
        fi
    fi
) &

# 8️⃣ Attendre Apache (processus principal)
echo "🎯 Dolibarr is ready! Waiting for Apache..."
wait $APACHE_PID