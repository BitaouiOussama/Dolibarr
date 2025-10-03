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

# 4️⃣ Créer la configuration Dolibarr en avance
echo "📄 Creating Dolibarr configuration directory..."
mkdir -p /var/www/html/htdocs/conf
chown -R www-data:www-data /var/www/html/htdocs/conf
chmod 755 /var/www/html/htdocs/conf

# 5️⃣ DÉMARRER APACHE IMMÉDIATEMENT (avant le test de connexion)
echo "🌐 Starting Apache web server..."
apache2-foreground &
APACHE_PID=$!

# Attendre qu'Apache soit prêt
sleep 3
echo "✅ Apache is starting (PID: $APACHE_PID)..."

# 6️⃣ Test database connection en arrière-plan (ne bloque pas Apache)
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

# 7️⃣ Attendre Apache (processus principal)
echo "🎯 Dolibarr is ready! Waiting for Apache..."
wait $APACHE_PID