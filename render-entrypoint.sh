#!/bin/sh
set -e

echo "🚀 Starting custom entrypoint for Render + Aiven..."

# 1️⃣ Vérifier que la variable MYSQL_SSL_CA existe
if [ -n "$MYSQL_SSL_CA" ]; then
    echo "📜 Writing SSL certificate to /ca.pem ..."
    echo "$MYSQL_SSL_CA" | base64 -d > /ca.pem
    # Définir les droits sécurisés pour que seul Apache puisse lire le fichier
    chown www-data:www-data /ca.pem
    chmod 600 /ca.pem
    echo "✅ SSL certificate setup complete"
else
    echo "⚠️ No SSL certificate found in MYSQL_SSL_CA"
fi

# 2️⃣ Ensure database connection variables are set
if [ -z "$DOLI_DB_HOST" ]; then
    echo "❌ DOLI_DB_HOST is not set"
    exit 1
fi

if [ -z "$DOLI_DB_USER" ]; then
    echo "❌ DOLI_DB_USER is not set"
    exit 1
fi

if [ -z "$DOLI_DB_PASS" ]; then
    echo "❌ DOLI_DB_PASSWORD is not set"
    exit 1
fi

if [ -z "$DOLI_DB_NAME" ]; then
    echo "❌ DOLI_DB_NAME is not set"
    exit 1
fi

echo "✅ Database configuration check passed"

# 3️⃣ Call the original Dolibarr entrypoint
echo "📦 Starting original Dolibarr entrypoint..."
exec /usr/local/bin/docker-run.sh "$@"