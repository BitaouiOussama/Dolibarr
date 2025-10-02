#!/bin/sh
set -e

# Vérifier que la variable contenant le certificat existe
if [ -n "$MYSQL_SSL_CA" ]; then
    echo "📜 Writing SSL certificate to /ca.pem ..."
    echo "$MYSQL_SSL_CA" | base64 -d > /ca.pem
else
    echo "⚠️ No SSL certificate found in MYSQL_SSL_CA"
fi

# Exporter la variable pour Dolibarr
export DOLI_DB_SSL_CA=/ca.pem

# Exécuter l’entrypoint original de Dolibarr
exec /entrypoint.sh apache2-foreground
