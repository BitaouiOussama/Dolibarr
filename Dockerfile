# Utiliser l'image officielle Dolibarr
FROM dolibarr/dolibarr:22

COPY render-entrypoint.sh /render-entrypoint.sh
RUN chmod +x /render-entrypoint.sh

WORKDIR /var/www/html
EXPOSE 80
ENTRYPOINT ["/render-entrypoint.sh"]