#!/bin/bash
set -e

echo "Starting Dolibarr with Aiven database..."

#Handle SSL certificate for Aiven
if [ -n "$MYSQL_SSL_CA" ]; then
    echo "📜 Writing Aiven SSL certificate to /ca.pem..."
    echo "$MYSQL_SSL_CA" | base64 -d > /ca.pem
    chown www-data:www-data /ca.pem
    chmod 600 /ca.pem
    echo "SSL certificate setup complete"
    
    # Enable SSL for database connections
    export DOLI_DB_SSL=true
fi

# 2️⃣ Override Dolibarr environment variables with your Aiven credentials
export DOLI_DB_HOST="${DOLI_DB_HOST}"
export DOLI_DB_USER="${DOLI_DB_USER}"           # Your Aiven username
export DOLI_DB_PASSW="${DOLI_DB_PASS}"   # Your Aiven password
export DOLI_DB_NAME="${DOLI_DB_NAME}"           # Your Aiven database name
export DOLI_DB_HOST_PORT="${DOLI_DB_PORT:-3306}" # Your Aiven port
export DOLI_DB_TYPE="${DOLI_DB_TYPE:-mysqli}"   # Database type
export DOLI_INSTALL_AUTO=1                      # Enable auto-install
export DOLI_PROD=1                              # Production mode

# 3️⃣ Wait for Aiven database to be ready (optional but recommended)
if [ -n "$MYSQL_SSL_CA" ]; then
    echo "⏳ Testing Aiven database connection with SSL..."
    for i in {1..30}; do
        if mysql \
            --host="$DOLI_DB_HOST" \
            --user="$DOLI_DB_USER" \
            --password="$DOLI_DB_PASS" \
            --port="${DOLI_DB_PORT:-3306}" \
            --ssl-ca=/ca.pem \
            --execute="SELECT 1;" > /dev/null 2>&1; then
            echo "✅ Database connection successful"
            break
        else
            echo "⏱️ Database not ready (attempt $i/30)..."
            sleep 5
        fi
    done
fi

echo "🔧 Starting Dolibarr with your Aiven database configuration..."
echo "   Database Host: $DOLI_DB_HOST"
echo "   Database Name: $DOLI_DB_NAME"
echo "   Database User: $DOLI_DB_USER"

# 4️⃣ Call the original Dolibarr entrypoint script
exec /usr/local/bin/docker-run.sh "$@"