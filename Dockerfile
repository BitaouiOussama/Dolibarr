# Base image Dolibarr
FROM dolibarr/dolibarr:22

# Copier le script d'entrypoint
COPY render-entrypoint.sh /render-entrypoint.sh

# Donner les droits d'exécution
RUN chmod +x /render-entrypoint.sh

# Définir le script comme entrypoint
ENTRYPOINT ["/render-entrypoint.sh"]

# Exposer le port 80
EXPOSE 80
