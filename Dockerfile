# Utiliser l'image officielle Dolibarr
FROM dolibarr/dolibarr:22

# Copy your custom entrypoint
COPY render-entrypoint.sh /render-entrypoint.sh
RUN chmod +x /render-entrypoint.sh

# Définir le dossier de travail
WORKDIR /var/www/html

# Exposer le port web
EXPOSE 80

# Use your custom entrypoint that will call the original one
ENTRYPOINT ["/render-entrypoint.sh"]