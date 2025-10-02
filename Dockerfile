# Base image Dolibarr
FROM dolibarr/dolibarr:22

# Variables d'environnement pour la connexion MySQL
ENV DOLI_DB_HOST=dolibarr-dolibarr-1010.k.aivencloud.com
ENV DOLI_DB_PORT=17031
ENV DOLI_DB_NAME=defaultdb
ENV DOLI_DB_USER=avnadmin
ENV DOLI_DB_PASSWORD=
ENV APACHE_DOCUMENT_ROOT=/var/www/html/htdocs

# Expose le port 80 pour le service web
EXPOSE 80
