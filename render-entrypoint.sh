#!/bin/sh
set -e

echo "🚀 Starting custom entrypoint for Render + Aiven..."

# 1️⃣ Handle SSL certificate
if [ -n "$MYSQL_SSL_CA" ]; then
    echo "📜 Writing SSL certificate to /ca.pem ..."
    echo "$MYSQL_SSL_CA" | base64 -d > /ca.pem
    chown www-data:www-data /ca.pem
    chmod 600 /ca.pem
    echo "✅ SSL certificate setup complete"
    
    # Set environment variable to use SSL for MySQL connections
    export DOLI_DB_SSL=true
fi

# 2️⃣ Call the original Dolibarr entrypoint
echo "📦 Starting original Dolibarr entrypoint: docker-run.sh"
exec /usr/local/bin/docker-run.sh "$@"