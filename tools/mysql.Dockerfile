# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for MySQL
# Website: https://www.mysql.com/
# Repository: https://github.com/mysql/mysql-server
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Production-ready MySQL database server with security hardening
# · DESIGN PHILOSOPHY: Self-contained with security configurations
# · COMBINATION: Use standalone for MySQL database containers
# · SECURITY: Secure defaults, non-root operations, encrypted connections
# · BEST PRACTICES: Resource limits, backup configurations, monitoring
# · OFFICIAL SOURCES: MySQL documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Choose appropriate base image based on your needs:

# Option 1: Official MySQL with Alpine (smallest)
FROM mysql:8.0

# Option 2: MySQL with Debian
# FROM mysql:8.0-debian

# Option 3: Specific version with SHA
# FROM mysql:8.0@sha256:abc123...

# Option 4: Percona Server (MySQL compatible)
# FROM percona:8.0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG MYSQL_VERSION=8.0
ARG MYSQL_DATABASE=app_db
ARG MYSQL_USER=app_user
# SECURITY: MYSQL_PASSWORD must be set via environment variable or build argument
# Example: --build-arg MYSQL_PASSWORD=your_secure_password_here
# SECURITY: MYSQL_ROOT_PASSWORD must be set via environment variable or build argument
# Example: --build-arg MYSQL_ROOT_PASSWORD=your_secure_root_password_here

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV MYSQL_VERSION=${MYSQL_VERSION} \
  MYSQL_DATABASE=${MYSQL_DATABASE} \
  MYSQL_USER=${MYSQL_USER} \
  MYSQL_PASSWORD=${MYSQL_PASSWORD} \
  MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
  MYSQL_ALLOW_EMPTY_PASSWORD=no \
  MYSQL_INITDB_SKIP_TZINFO=1 \
  TZ=UTC \
  LANG=C.UTF-8

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create custom MySQL configuration with security hardening
RUN mkdir -p /etc/mysql/conf.d && \
  echo "[mysqld]" > /etc/mysql/conf.d/custom.cnf && \
  echo "bind-address = 0.0.0.0" >> /etc/mysql/conf.d/custom.cnf && \
  echo "max_connections = 1000" >> /etc/mysql/conf.d/custom.cnf && \
  echo "max_allowed_packet = 256M" >> /etc/mysql/conf.d/custom.cnf && \
  echo "innodb_buffer_pool_size = 1G" >> /etc/mysql/conf.d/custom.cnf && \
  echo "innodb_log_file_size = 256M" >> /etc/mysql/conf.d/custom.cnf && \
  echo "innodb_flush_log_at_trx_commit = 2" >> /etc/mysql/conf.d/custom.cnf && \
  echo "skip-name-resolve" >> /etc/mysql/conf.d/custom.cnf && \
  echo "character-set-server = utf8mb4" >> /etc/mysql/conf.d/custom.cnf && \
  echo "collation-server = utf8mb4_unicode_ci" >> /etc/mysql/conf.d/custom.cnf && \
  echo "default-authentication-plugin = mysql_native_password" >> /etc/mysql/conf.d/custom.cnf

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INITIALIZATION SCRIPTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create initialization scripts directory
RUN mkdir -p /docker-entrypoint-initdb.d

# Create initialization script for custom database setup
COPY docker/mysql/init.sql /docker-entrypoint-initdb.d/01-init.sql
COPY docker/mysql/grants.sql /docker-entrypoint-initdb.d/02-grants.sql

# Set proper permissions for initialization scripts
RUN chmod 644 /docker-entrypoint-initdb.d/*.sql

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DATA DIRECTORY SETUP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create data directory with proper permissions
RUN mkdir -p /var/lib/mysql && \
  chown -R mysql:mysql /var/lib/mysql && \
  chmod 750 /var/lib/mysql

# Create logs directory
RUN mkdir -p /var/log/mysql && \
  chown -R mysql:mysql /var/log/mysql && \
  chmod 750 /var/log/mysql

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Declare persistent data volume
VOLUME /var/lib/mysql

# Expose MySQL port
EXPOSE 3306
EXPOSE 33060  # MySQL X Protocol port

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD mysqladmin ping -h localhost -u root -p${MYSQL_ROOT_PASSWORD} || exit 1

# Use MySQL's default entrypoint
# The official MySQL image already has an optimized entrypoint

USER mysql

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BACKUP CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create backup directory
RUN mkdir -p /backup && \
  chown -R mysql:mysql /backup && \
  chmod 750 /backup

# Install backup utilities (optional)
# RUN apt-get update && apt-get install -y --no-install-recommends \
#   pv \
#   pigz \
#   && rm -rf /var/lib/apt/lists/*

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MONITORING CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Enable performance schema (already enabled by default in MySQL 8.0)
# Enable slow query log
RUN echo "slow_query_log = 1" >> /etc/mysql/conf.d/custom.cnf && \
  echo "slow_query_log_file = /var/log/mysql/mysql-slow.log" >> /etc/mysql/conf.d/custom.cnf && \
  echo "long_query_time = 2" >> /etc/mysql/conf.d/custom.cnf

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Additional security configurations
RUN echo "secure-file-priv = /tmp" >> /etc/mysql/conf.d/custom.cnf && \
  echo "local-infile = 0" >> /etc/mysql/conf.d/custom.cnf && \
  echo "sql_mode = STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" >> /etc/mysql/conf.d/custom.cnf

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Run MySQL container with custom passwords:
#    docker run -d \
#      --name mysql-server \
#      -e MYSQL_ROOT_PASSWORD=secure_root_password \
#      -e MYSQL_DATABASE=myapp \
#      -e MYSQL_USER=myapp_user \
#      -e MYSQL_PASSWORD=secure_user_password \
#      -p 3306:3306 \
#      -v mysql_data:/var/lib/mysql \
#      mysql:8.0
#
# 2. Run with custom configuration:
#    docker run -d \
#      --name mysql-server \
#      -e MYSQL_ROOT_PASSWORD=secure_password \
#      -p 3306:3306 \
#      -v ./my-custom.cnf:/etc/mysql/conf.d/custom.cnf \
#      -v mysql_data:/var/lib/mysql \
#      mysql:8.0
#
# 3. Run with initialization scripts:
#    docker run -d \
#      --name mysql-server \
#      -e MYSQL_ROOT_PASSWORD=secure_password \
#      -p 3306:3306 \
#      -v ./init-scripts:/docker-entrypoint-initdb.d \
#      -v mysql_data:/var/lib/mysql \
#      mysql:8.0
#
# 4. Run with resource limits:
#    docker run -d \
#      --name mysql-server \
#      --memory="2g" \
#      --memory-swap="2g" \
#      --cpus="2" \
#      -e MYSQL_ROOT_PASSWORD=secure_password \
#      -p 3306:3306 \
#      -v mysql_data:/var/lib/mysql \
#      mysql:8.0
#
# 5. Build custom MySQL image:
#    docker build -t my-mysql-server .
#
# 6. Run with health check monitoring:
#    docker run -d \
#      --name mysql-server \
#      -e MYSQL_ROOT_PASSWORD=secure_password \
#      --health-cmd="mysqladmin ping -h localhost -u root -p$$MYSQL_ROOT_PASSWORD" \
#      -p 3306:3306 \
#      mysql:8.0
#
# 7. Connect to MySQL from application:
#    docker run -d \
#      --name mysql-server \
#      -e MYSQL_ROOT_PASSWORD=secure_password \
#      --network=my-network \
#      mysql:8.0
#
# 8. Backup MySQL database:
#    docker exec mysql-server mysqldump -u root -psecure_password myapp > backup.sql

# BEST PRACTICES
# ==============
# • PASSWORD SECURITY: Always use strong, unique passwords for root and application users
# • DATA PERSISTENCE: Use Docker volumes for persistent data storage
# • RESOURCE MANAGEMENT: Set appropriate memory and CPU limits based on workload
# • PERFORMANCE MONITORING: Enable slow query logging and performance schema
# • REGULAR BACKUPS: Implement automated backup strategies for data protection
# • NETWORK SECURITY: Use network segmentation to limit database access
# • CONNECTION MANAGEMENT: Configure appropriate connection limits and timeouts
# • ENCRYPTION: Enable SSL/TLS for encrypted connections in production environments

# MYSQL-SPECIFIC CONSIDERATIONS
# • BUFFER POOL SIZING: Adjust innodb_buffer_pool_size based on available memory
# • CONNECTION LIMITS: Configure max_connections based on application requirements
# • TIMEZONE CONFIGURATION: Set appropriate timezone for your application needs
# • CHARACTER SETS: Use utf8mb4 for full Unicode support and emoji compatibility
# • STORAGE ENGINE: Prefer InnoDB for ACID compliance and transaction support
# • REPLICATION: Consider master-slave replication for high availability

# SECURITY CONSIDERATIONS
# • NON-ROOT OPERATIONS: Run MySQL processes with dedicated mysql user
# • FILE PERMISSIONS: Set strict permissions on configuration and data directories
# • NETWORK BINDING: Bind to specific interfaces or use internal networks
# • AUTHENTICATION: Use mysql_native_password or caching_sha2_password plugins
# • AUDIT LOGGING: Enable audit plugin for security compliance requirements

# COMBINATION PATTERNS
# • Combine with patterns/monitoring.Dockerfile for comprehensive monitoring
# • Combine with patterns/security-hardened.Dockerfile for enhanced security
# • Combine with frameworks/laravel.Dockerfile for PHP applications
# • Combine with frameworks/spring-boot.Dockerfile for Java applications
# • Combine with tools/phpmyadmin.Dockerfile for administration interface
