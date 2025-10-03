#!/bin/bash
set -e

echo "🚀 Quick start - skipping database tests"

# Just handle SSL and start
if [ -n "$MYSQL_SSL_CA" ]; then
    echo "$MYSQL_SSL_CA" | base64 -d > /ca.pem
    chown www-data:www-data /ca.pem
    chmod 600 /ca.pem
    export DOLI_DB_SSL=true
fi

# Set your credentials
export DOLI_DB_HOST="${DOLI_DB_HOST}"
export DOLI_DB_USER="${DOLI_DB_USER}" 
export DOLI_DB_PASS="${DOLI_DB_PASS}"
export DOLI_DB_NAME="${DOLI_DB_NAME}"
export DOLI_DB_HOST_PORT="${DOLI_DB_PORT:-3306}"
export DOLI_DB_TYPE="${DOLI_DB_TYPE:-mysqli}"
export DOLI_INSTALL_AUTO=1

echo "Starting Dolibarr now..."
exec /usr/local/bin/docker-run.sh "$@"