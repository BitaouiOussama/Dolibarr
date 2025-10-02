# Utiliser l'image officielle Dolibarr
FROM dolibarr/dolibarr:22

# Définir le dossier de travail
WORKDIR /var/www/html

# Exposer le port web
EXPOSE 80

# ENTRYPOINT et CMD sont déjà définis correctement dans l'image officielle
# Pas besoin de surcharger
