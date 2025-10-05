# Use the official Dolibarr image as base
FROM dolibarr/dolibarr:21

# Install mysql-client (for connection testing)
RUN apt-get update && \
    apt-get install -y default-mysql-client && \
    rm -rf /var/lib/apt/lists/*

# Copy your custom entrypoint script
COPY render-entrypoint.sh /render-entrypoint.sh
RUN chmod +x /render-entrypoint.sh

# Set working directory
WORKDIR /var/www/html

# Expose HTTP port
EXPOSE 80

# Use your custom entrypoint (replaces Dolibarr’s default)
ENTRYPOINT ["/render-entrypoint.sh"]
