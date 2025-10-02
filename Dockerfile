# # Base image Dolibarr
# FROM dolibarr/dolibarr:22

# # Copier le script d'entrypoint
# COPY render-entrypoint.sh /render-entrypoint.sh

# # Donner les droits d'exécution
# RUN chmod +x /render-entrypoint.sh

# # Définir le script comme entrypoint
# ENTRYPOINT ["/render-entrypoint.sh"]

# # Exposer le port 80
# EXPOSE 80


###########################################################################


# Utilise l’image officielle Dolibarr
FROM dolibarr/dolibarr:22

# Copier le script d'initialisation
COPY render-entrypoint.sh /usr/local/bin/render-entrypoint.sh

# Donner les droits d'exécution
RUN chmod +x /usr/local/bin/render-entrypoint.sh

# Définir le dossier de travail
WORKDIR /var/www/html

# Exposer le port web
EXPOSE 80

# Variables par défaut (modifiable depuis Render)
ENV DOLI_DB_TYPE=mysqli \
    DOLI_DB_SSL=1 \
    DOLI_URL_ROOT=https://dolibarr-68ch.onrender.com \
    DOLI_AUTH=dolibarr \
    DOLI_INSTALL_AUTO=1 \
    DOLI_PROD=1 \
    DOLI_ADMIN_USER=admin \
    DOLI_ADMIN_PASS=admin123 \
    DOLI_ADMIN_MAIL=admin@example.com

# Entrypoint personnalisé
ENTRYPOINT ["/usr/local/bin/render-entrypoint.sh"]

# CMD par défaut
CMD ["apache2-foreground"]
