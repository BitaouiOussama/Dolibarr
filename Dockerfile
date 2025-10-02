# Base image Dolibarr
FROM dolibarr/dolibarr:22

# Variables d'environnement pour la connexion MySQL
ENV DOLI_DB_HOST=db4free.net
ENV DOLI_DB_PORT=3306
ENV DOLI_DB_NAME=dolibarr
ENV DOLI_DB_USER=dolibarruser
ENV DOLI_DB_PASSWORD=
ENV APACHE_DOCUMENT_ROOT=/var/www/html/htdocs

# Expose le port 80 pour le service web
EXPOSE 80
