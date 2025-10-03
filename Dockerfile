# Utiliser l'image officielle Dolibarr
FROM dolibarr/dolibarr:22

# Copy your custom entrypoint script
COPY render-entrypoint.sh /render-entrypoint.sh
RUN chmod +x /render-entrypoint.sh

# Rename original script and set entrypoint
RUN mv /usr/local/bin/docker-run.sh /usr/local/bin/docker-run.sh.original

# Définir le dossier de travail
WORKDIR /var/www/html

# Exposer le port web
EXPOSE 80

# Use your custom entrypoint
ENTRYPOINT ["/render-entrypoint.sh"]