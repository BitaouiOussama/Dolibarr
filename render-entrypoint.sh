#!/bin/sh

# Si la variable MYSQL_SSL_CA existe, créer le fichier /ca.pem
if [ -n "$MYSQL_SSL_CA" ]; then
    echo "📜 Writing SSL certificate to /ca.pem ..."
    echo "$MYSQL_SSL_CA" | base64 -d > /ca.pem
    chown www-data:www-data /ca.pem
    chmod 600 /ca.pem
else
    echo "⚠️ No SSL certificate found in MYSQL_SSL_CA"
fi

# Lancer Apache en premier plan
exec apache2-foreground
