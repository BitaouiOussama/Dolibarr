# Utiliser l'image officielle Dolibarr
FROM dolibarr/dolibarr:22

COPY render-entrypoint.sh /render-entrypoint.sh
RUN chmod +x /render-entrypoint.sh


# Définir le dossier de travail
WORKDIR /var/www/html

# Exposer le port web
EXPOSE 80
ENTRYPOINT ["/render-entrypoint.sh"]


# ENTRYPOINT et CMD sont déjà définis correctement dans l'image officielle
# Pas besoin de surcharger
