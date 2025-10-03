#!/bin/bash
set -e

# Handle SSL first
if [ -n "$MYSQL_SSL_CA" ]; then
    echo "📜 Writing Aiven SSL certificate..."
    echo "$MYSQL_SSL_CA" | base64 -d > /ca.pem
    chown www-data:www-data /ca.pem
    chmod 600 /ca.pem
    export DOLI_DB_SSL=true
fi

# Force use of your Aiven database settings
export DOLI_DB_HOST="${DOLI_DB_HOST}"
export DOLI_DB_USER="${DOLI_DB_USER}" 
export DOLI_DB_PASSWORD="${DOLI_DB_PASS}"
export DOLI_DB_NAME="${DOLI_DB_NAME}"
export DOLI_DB_PORT="${DOLI_DB_PORT:-3306}"
export DOLI_DB_TYPE="${DOLI_DB_TYPE:-mysqli}"
export DOLI_INSTALL_AUTO=1

# Call original script
exec /usr/local/bin/docker-run.sh.original "$@"