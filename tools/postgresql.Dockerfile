# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for PostgreSQL
# Website: https://www.postgresql.org/
# Repository: https://github.com/postgres/postgres
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Production-ready PostgreSQL database configuration
# · DESIGN PHILOSOPHY: Self-contained with security hardening and best practices
# · COMBINATION: Use standalone for PostgreSQL database containers
# · SECURITY: Non-root user, secure defaults, health monitoring
# · BEST PRACTICES: Volume persistence, backup configuration, resource limits
# · OFFICIAL SOURCES: PostgreSQL documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM postgres:15-alpine

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG POSTGRES_VERSION=15
ARG BUILD_ID=unknown

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV POSTGRES_VERSION=${POSTGRES_VERSION} \
  BUILD_ID=${BUILD_ID} \
  POSTGRES_DB=appdb \
  POSTGRES_USER=appuser \
  # POSTGRES_PASSWORD must be set via environment variable for security
  # Example: -e POSTGRES_PASSWORD=your_secure_password_here
  POSTGRES_SHARED_BUFFERS=128MB \
  POSTGRES_EFFECTIVE_CACHE_SIZE=1GB \
  POSTGRES_MAINTENANCE_WORK_MEM=64MB \
  POSTGRES_WORK_MEM=4MB \
  POSTGRES_HOST_AUTH_METHOD=scram-sha-256 \
  LANG=en_US.utf8 \
  LC_ALL=en_US.utf8

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CRITICAL: Security-hardened configuration for production database

# Create data directory with proper permissions
RUN mkdir -p /var/lib/postgresql/data && \
  chown -R postgres:postgres /var/lib/postgresql/data && \
  chmod 700 /var/lib/postgresql/data

# Create backup directory
RUN mkdir -p /backups && \
  chown -R postgres:postgres /backups && \
  chmod 750 /backups

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CUSTOM CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Copy custom PostgreSQL configuration
COPY postgresql.conf /etc/postgresql/postgresql.conf
COPY pg_hba.conf /etc/postgresql/pg_hba.conf

# Apply custom configuration
RUN chown postgres:postgres /etc/postgresql/postgresql.conf /etc/postgresql/pg_hba.conf && \
  chmod 640 /etc/postgresql/postgresql.conf /etc/postgresql/pg_hba.conf

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INITIALIZATION SCRIPTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Copy initialization scripts
COPY docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/

# Set proper permissions for initialization scripts
RUN chown -R postgres:postgres /docker-entrypoint-initdb.d/ && \
  chmod -R 750 /docker-entrypoint-initdb.d/

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECK
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB} || exit 1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VOLUME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Define volume for persistent data
VOLUME /var/lib/postgresql/data

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EXPOSE PORTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Expose PostgreSQL port
EXPOSE 5432

USER postgres

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Build PostgreSQL image
# docker build -t my-postgres:15 .

# Example 2: Run PostgreSQL container
# docker run -d \
#   --name postgres-db \
#   -p 5432:5432 \
#   -e POSTGRES_PASSWORD=securepassword \
#   -e POSTGRES_USER=myapp \
#   -e POSTGRES_DB=mydatabase \
#   -v postgres-data:/var/lib/postgresql/data \
#   my-postgres:15

# Example 3: Run with custom configuration
# docker run -d \
#   --name postgres-db \
#   -p 5432:5432 \
#   -e POSTGRES_PASSWORD=securepassword \
#   -v $(pwd)/postgresql.conf:/etc/postgresql/postgresql.conf \
#   -v postgres-data:/var/lib/postgresql/data \
#   my-postgres:15

# Example 4: Run with resource limits
# docker run -d \
#   --name postgres-db \
#   --memory=2g \
#   --cpus=2 \
#   -p 5432:5432 \
#   -e POSTGRES_PASSWORD=securepassword \
#   -v postgres-data:/var/lib/postgresql/data \
#   my-postgres:15

# Example 5: Backup and restore
# docker exec postgres-db pg_dump -U appuser appdb > backup.sql
# docker exec -i postgres-db psql -U appuser appdb < backup.sql

# Best Practices:
# 1. Always use strong passwords for POSTGRES_PASSWORD
# 2. Use volumes for persistent data storage
# 3. Set appropriate resource limits (memory, CPU)
# 4. Regularly backup the database
# 5. Monitor database health and performance
# 6. Use .pgpass for password management in production
# 7. Enable SSL/TLS for network connections
# 8. Regularly update PostgreSQL to latest security patches

# Customization Notes:
# 1. Adjust POSTGRES_SHARED_BUFFERS based on available memory
# 2. Modify POSTGRES_EFFECTIVE_CACHE_SIZE for your workload
# 3. Add custom extensions in initialization scripts
# 4. Configure replication for high availability
# 5. Set up automated backups
# 6. Configure connection pooling if needed

# Security Recommendations:
# 1. Change default PostgreSQL password immediately
# 2. Use SCRAM-SHA-256 authentication method
# 3. Restrict network access to trusted hosts
# 4. Enable SSL/TLS encryption
# 5. Regularly audit database permissions
# 6. Use separate users for different applications
# 7. Implement connection rate limiting
