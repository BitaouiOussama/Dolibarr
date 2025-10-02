# Utilise l’image officielle Dolibarr
FROM dolibarr/dolibarr:22

# Copie notre script d’entrypoint personnalisé
COPY render-entrypoint.sh /render-entrypoint.sh

# Donner les permissions d’exécution
RUN chmod +x /render-entrypoint.sh

# Dossier de travail
WORKDIR /var/www/html

# Lance le script au démarrage
# ENTRYPOINT ["/render-entrypoint.sh"]
ENTRYPOINT ["/render-entrypoint.sh"]

