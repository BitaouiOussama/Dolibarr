# Use the official Dolibarr image
FROM dolibarr/dolibarr:20

# Install mysql-client for connection testing
RUN apt-get update && \
    apt-get install -y default-mysql-client && \
    rm -rf /var/lib/apt/lists/*

# Copy your custom entrypoint script
COPY render-entrypoint.sh /render-entrypoint.sh
RUN chmod +x /render-entrypoint.sh

# Set the working directory
WORKDIR /var/www/html

# Expose port 80
EXPOSE 80

# Use your custom entrypoint
ENTRYPOINT ["/render-entrypoint.sh"]
CMD []