#!/bin/sh

# Vérifier que la variable contenant le certificat existe
if [ -n "$MYSQL_SSL_CA" ]; then
    echo "📜 Writing SSL certificate to /ca.pem ..."
    echo "$MYSQL_SSL_CA" | base64 -d > /ca.pem
else
    echo "⚠️ No SSL certificate found in MYSQL_SSL_CA"
fi

# Lancer Apache (comme le ferait l’image officielle)
exec apache2-foreground
