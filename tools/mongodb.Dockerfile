# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for MongoDB
# Website: https://www.mongodb.com/
# Repository: https://github.com/mongodb/mongo
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Production-ready MongoDB database server with security hardening
# · DESIGN PHILOSOPHY: Self-contained with security configurations
# · COMBINATION: Use standalone for MongoDB database containers
# · SECURITY: Authentication, encryption, network security
# · BEST PRACTICES: Resource limits, backup configurations, monitoring
# · OFFICIAL SOURCES: MongoDB documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Choose appropriate base image based on your needs:

# Option 1: Official MongoDB with Alpine (smallest)
FROM mongo:7.0

# Option 2: MongoDB with Debian
# FROM mongo:7.0-debian

# Option 3: Specific version with SHA
# FROM mongo:7.0@sha256:abc123...

# Option 4: MongoDB Community Edition
# FROM mongo:7.0-community

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG MONGO_VERSION=7.0
ARG MONGO_INITDB_ROOT_USERNAME=admin
# SECURITY: MONGO_INITDB_ROOT_PASSWORD must be set via environment variable or build argument
# Example: --build-arg MONGO_INITDB_ROOT_PASSWORD=your_secure_password_here
ARG MONGO_INITDB_DATABASE=admin

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV MONGO_VERSION=${MONGO_VERSION} \
  MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME} \
  MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD} \
  MONGO_INITDB_DATABASE=${MONGO_INITDB_DATABASE} \
  TZ=UTC \
  LANG=C.UTF-8

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create custom MongoDB configuration with security hardening
RUN mkdir -p /etc/mongod && \
  echo "# Security Configuration" > /etc/mongod/custom.conf && \
  echo "security:" >> /etc/mongod/custom.conf && \
  echo "  authorization: enabled" >> /etc/mongod/custom.conf && \
  echo "" >> /etc/mongod/custom.conf && \
  echo "# Network Configuration" >> /etc/mongod/custom.conf && \
  echo "net:" >> /etc/mongod/custom.conf && \
  echo "  bindIp: 0.0.0.0" >> /etc/mongod/custom.conf && \
  echo "  port: 27017" >> /etc/mongod/custom.conf && \
  echo "" >> /etc/mongod/custom.conf && \
  echo "# Storage Configuration" >> /etc/mongod/custom.conf && \
  echo "storage:" >> /etc/mongod/custom.conf && \
  echo "  dbPath: /data/db" >> /etc/mongod/custom.conf && \
  echo "  journal:" >> /etc/mongod/custom.conf && \
  echo "    enabled: true" >> /etc/mongod/custom.conf && \
  echo "" >> /etc/mongod/custom.conf && \
  echo "# Operation Profiling" >> /etc/mongod/custom.conf && \
  echo "operationProfiling:" >> /etc/mongod/custom.conf && \
  echo "  mode: slowOp" >> /etc/mongod/custom.conf && \
  echo "  slowOpThresholdMs: 100" >> /etc/mongod/custom.conf

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INITIALIZATION SCRIPTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create initialization scripts directory
RUN mkdir -p /docker-entrypoint-initdb.d

# Create initialization script for custom database setup
COPY docker/mongodb/init.js /docker-entrypoint-initdb.d/01-init.js
COPY docker/mongodb/users.js /docker-entrypoint-initdb.d/02-users.js

# Set proper permissions for initialization scripts
RUN chmod 644 /docker-entrypoint-initdb.d/*.js

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DATA DIRECTORY SETUP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create data directory with proper permissions
RUN mkdir -p /data/db && \
  chown -R mongodb:mongodb /data/db && \
  chmod 750 /data/db

# Create logs directory
RUN mkdir -p /var/log/mongodb && \
  chown -R mongodb:mongodb /var/log/mongodb && \
  chmod 750 /var/log/mongodb

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Declare persistent data volume
VOLUME /data/db

# Expose MongoDB ports
EXPOSE 27017  # Default MongoDB port
EXPOSE 27018  # Sharded cluster port
EXPOSE 27019  # Config server port

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD mongosh --eval "db.adminCommand('ping')" || exit 1

# Use MongoDB's default entrypoint with custom configuration
USER mongodb
ENTRYPOINT ["mongod", "--config", "/etc/mongod/custom.conf"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BACKUP CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create backup directory
RUN mkdir -p /backup && \
  chown -R mongodb:mongodb /backup && \
  chmod 750 /backup

# Install mongodump/mongorestore utilities (already included in official image)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MONITORING CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Enable MongoDB free monitoring (optional)
# RUN echo "# Free Monitoring" >> /etc/mongod/custom.conf && \
#   echo "cloud:" >> /etc/mongod/custom.conf && \
#   echo "  monitoring:" >> /etc/mongod/custom.conf && \
#   echo "    free:" >> /etc/mongod/custom.conf && \
#   echo "      state: runtime" >> /etc/mongod/custom.conf

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# REPLICA SET CONFIGURATION (OPTIONAL)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# For replica set configuration, uncomment and modify:
# RUN echo "# Replication Configuration" >> /etc/mongod/custom.conf && \
#   echo "replication:" >> /etc/mongod/custom.conf && \
#   echo "  replSetName: rs0" >> /etc/mongod/custom.conf && \
#   echo "  oplogSizeMB: 1024" >> /etc/mongod/custom.conf

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Additional security configurations
RUN echo "# Additional Security" >> /etc/mongod/custom.conf && \
  echo "setParameter:" >> /etc/mongod/custom.conf && \
  echo "  enableLocalhostAuthBypass: false" >> /etc/mongod/custom.conf && \
  echo "  tlsMode: requireTLS" >> /etc/mongod/custom.conf

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Run MongoDB container with authentication
# docker run -d \
#   --name mongodb-server \
#   -e MONGO_INITDB_ROOT_USERNAME=admin \
#   -e MONGO_INITDB_ROOT_PASSWORD=secure_password \
#   -p 27017:27017 \
#   -v mongodb_data:/data/db \
#   mongo:7.0

# Example 2: Run with custom configuration
# docker run -d \
#   --name mongodb-server \
#   -e MONGO_INITDB_ROOT_USERNAME=admin \
#   -e MONGO_INITDB_ROOT_PASSWORD=secure_password \
#   -p 27017:27017 \
#   -v ./custom.conf:/etc/mongod/custom.conf \
#   -v mongodb_data:/data/db \
#   mongo:7.0

# Example 3: Run with initialization scripts
# docker run -d \
#   --name mongodb-server \
#   -e MONGO_INITDB_ROOT_USERNAME=admin \
#   -e MONGO_INITDB_ROOT_PASSWORD=secure_password \
#   -p 27017:27017 \
#   -v ./init-scripts:/docker-entrypoint-initdb.d \
#   -v mongodb_data:/data/db \
#   mongo:7.0

# Example 4: Run with resource limits
# docker run -d \
#   --name mongodb-server \
#   --memory="2g" \
#   --memory-swap="2g" \
#   --cpus="2" \
#   -e MONGO_INITDB_ROOT_USERNAME=admin \
#   -e MONGO_INITDB_ROOT_PASSWORD=secure_password \
#   -p 27017:27017 \
#   -v mongodb_data:/data/db \
#   mongo:7.0

# Example 5: Run replica set (multiple containers)
# docker run -d \
#   --name mongodb-primary \
#   -e MONGO_INITDB_ROOT_USERNAME=admin \
#   -e MONGO_INITDB_ROOT_PASSWORD=secure_password \
#   --network mongodb-cluster \
#   mongo:7.0 --replSet rs0

# Best Practices:
# 1. Always enable authentication in production
# 2. Use strong passwords for admin and application users
# 3. Use volumes for persistent data storage
# 4. Set appropriate resource limits (memory, CPU)
# 5. Enable slow operation logging for performance monitoring
# 6. Regular backups using mongodump
# 7. Use network segmentation to limit database access
# 8. Enable TLS/SSL for encrypted connections in production
# 9. Consider using replica sets for high availability

# Customization Notes:
# 1. Adjust storage engine settings based on workload
# 2. Configure WiredTiger cache size based on available memory
# 3. Set appropriate oplog size for replication
# 4. Configure journaling for data durability
# 5. Enable compression for storage efficiency
