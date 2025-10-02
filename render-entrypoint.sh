#!/bin/sh
set -e

# 📜 Écriture du certificat SSL si la variable MYSQL_SSL_CA est définie
if [ -n "$MYSQL_SSL_CA" ]; then
    echo "📜 Writing SSL certificate to /ca.pem ..."
    echo "$MYSQL_SSL_CA" | base64 -d > /ca.pem
else
    echo "⚠️ No SSL certificate found in MYSQL_SSL_CA"
fi

# 🚀 Lancer Apache (serveur web) — Dolibarr gérera l'installation via /install
exec apache2-foreground
