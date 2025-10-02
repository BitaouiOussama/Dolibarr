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


# Base image officielle Dolibarr
FROM dolibarr/dolibarr:22

RUN mkdir -p /var/www/html/htdocs/conf \
    && chown www-data:www-data /var/www/html/htdocs/conf \
    && chmod 750 /var/www/html/htdocs/conf

# Copier le fichier de configuration Dolibarr
COPY conf.php /var/www/html/htdocs/conf/conf.php

# Définir le propriétaire et les permissions pour Apache
RUN chown www-data:www-data /var/www/html/htdocs/conf/conf.php \
    && chmod 640 /var/www/html/htdocs/conf/conf.php

# Copier le certificat SSL (déjà en base64 dans l'environnement Render)
COPY render-entrypoint.sh /render-entrypoint.sh
RUN chmod +x /render-entrypoint.sh

# Définir le dossier de travail
WORKDIR /var/www/html

# Exposer le port web
EXPOSE 80

# Entrypoint personnalisé pour gérer le certificat SSL
ENTRYPOINT ["/render-entrypoint.sh"]
