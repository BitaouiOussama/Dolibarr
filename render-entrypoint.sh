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
    export DOLI_DB_SSL=true
fi

# 2️⃣ Set your Aiven database credentials
export DOLI_DB_HOST="${DOLI_DB_HOST}"
export DOLI_DB_USER="${DOLI_DB_USER}" 
export DOLI_DB_PASS="${DOLI_DB_PASS}"
export DOLI_DB_NAME="${DOLI_DB_NAME}"
export DOLI_DB_HOST_PORT="${DOLI_DB_PORT:-3306}"
export DOLI_DB_TYPE="${DOLI_DB_TYPE:-mysqli}"
export DOLI_INSTALL_AUTO=1
export DOLI_PROD=1

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

# 4️⃣ Test database connection with more details
echo "🔍 Testing database connectivity..."
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
            --execute="SELECT 'SSL Connection: SUCCESS' AS status;" 2>&1 || {
            echo "❌ SSL Connection failed, testing without SSL..."
            # Test without SSL as fallback
            timeout 15 mysql \
                --host="$DOLI_DB_HOST" \
                --user="$DOLI_DB_USER" \
                --password="$DOLI_DB_PASS" \
                --port="$DOLI_DB_HOST_PORT" \
                --connect-timeout=10 \
                --execute="SELECT 'Non-SSL Connection: SUCCESS' AS status;" 2>&1 || {
                echo "❌ Both SSL and non-SSL connections failed"
                echo "💡 Please check:"
                echo "   - Database host: $DOLI_DB_HOST"
                echo "   - Database port: $DOLI_DB_HOST_PORT" 
                echo "   - Username: $DOLI_DB_USER"
                echo "   - Password: [set]"
                echo "   - Database exists: $DOLI_DB_NAME"
                echo "   - Network connectivity from Render to Aiven"
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
            --execute="SELECT 'Connection: SUCCESS' AS status;" 2>&1 || {
            echo "❌ Database connection failed"
        }
    fi
fi

# 5️⃣ Create manual Dolibarr configuration to force SSL
echo "📄 Creating Dolibarr configuration..."
mkdir -p /var/www/html/htdocs/conf

# Create a basic conf.php that Dolibarr can modify
if [ ! -f "/var/www/html/htdocs/conf/conf.php" ]; then
    cat > /var/www/html/htdocs/conf/conf.php << 'EOF'
<?php
// Dolibarr configuration file
// This file will be completed by Dolibarr install process
EOF
    chown www-data:www-data /var/www/html/htdocs/conf/conf.php
    chmod 666 /var/www/html/htdocs/conf/conf.php
fi

echo "🎯 Starting Dolibarr application..."
exec /usr/local/bin/docker-run.sh "$@"