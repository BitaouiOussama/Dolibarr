# Use the official Dolibarr image
FROM dolibarr/dolibarr:20

# Copy your custom entrypoint script
COPY render-entrypoint.sh /render-entrypoint.sh
RUN chmod +x /render-entrypoint.sh

# Set the working directory
WORKDIR /var/www/html

# Expose port 80
EXPOSE 80

# Use your custom entrypoint
ENTRYPOINT ["/render-entrypoint.sh"]