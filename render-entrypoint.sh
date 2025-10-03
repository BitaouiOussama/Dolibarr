#!/bin/sh
set -e

# 1️⃣ Vérifier que la variable MYSQL_SSL_CA existe
if [ -n "$MYSQL_SSL_CA" ]; then
    echo "📜 Writing SSL certificate to /ca.pem ..."
    echo "$MYSQL_SSL_CA" | base64 -d > /ca.pem
    # Définir les droits sécurisés pour que seul Apache puisse lire le fichier
    chown www-data:www-data /ca.pem
    chmod 600 /ca.pem
else
    echo "⚠️ No SSL certificate found in MYSQL_SSL_CA"
fi

# 2️⃣ Lancer Apache en premier plan (comme dans l'image officielle Dolibarr)
exec apache2-foreground
