# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for MariaDB
# Website: https://mariadb.org/
# Repository: https://github.com/MariaDB/server
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: MariaDB relational database with production configuration
# · DESIGN PHILOSOPHY: MySQL-compatible database with enhanced features
# · COMBINATION: Use for MariaDB database deployments
# · SECURITY: Authentication, encryption, secure defaults
# · BEST PRACTICES: Performance tuning, replication, backup strategies
# · OFFICIAL SOURCES: MariaDB documentation and Docker best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MARIADB DATABASE CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM mariadb:11.3

# Build arguments for configuration
ARG MARIADB_VERSION=11.3
ARG MARIADB_ROOT_PASSWORD=
ARG MARIADB_DATABASE=
ARG MARIADB_USER=mysql
ARG MARIADB_PASSWORD=
ARG MARIADB_CHARACTER_SET=utf8mb4
ARG MARIADB_COLLATION=utf8mb4_unicode_ci
ARG MARIADB_USERNAME=mysql
ARG MARIADB_GROUP=mysql
ARG MARIADB_UID=1001
ARG MARIADB_GID=1001

# Environment variables for MariaDB configuration
ENV MARIADB_VERSION=${MARIADB_VERSION} \
    MARIADB_ROOT_PASSWORD=${MARIADB_ROOT_PASSWORD} \
    MARIADB_DATABASE=${MARIADB_DATABASE} \
    MARIADB_USER=${MARIADB_USER} \
    MARIADB_PASSWORD=${MARIADB_PASSWORD} \
    MARIADB_CHARACTER_SET=${MARIADB_CHARACTER_SET} \
    MARIADB_COLLATION=${MARIADB_COLLATION} \
    MARIADB_USERNAME=${MARIADB_USERNAME} \
    MARIADB_GROUP=${MARIADB_GROUP} \
    MARIADB_UID=${MARIADB_UID} \
    MARIADB_GID=${MARIADB_GID} \
    MYSQL_INITDB_SKIP_TZINFO=1

# Create custom user and group if they don't exist
RUN if ! getent group ${MARIADB_GID} > /dev/null; then \
        groupadd -g ${MARIADB_GID} ${MARIADB_GROUP}; \
    fi && \
    if ! getent passwd ${MARIADB_UID} > /dev/null; then \
        useradd -u ${MARIADB_UID} -g ${MARIADB_GID} ${MARIADB_USER}; \
    fi

# Create data directories with proper permissions
RUN mkdir -p /var/lib/mysql && \
    chown -R ${MARIADB_USER}:${MARIADB_GROUP} /var/lib/mysql && \
    chmod -R 750 /var/lib/mysql

# Copy custom configuration
COPY <<'EOF' /etc/mysql/conf.d/custom.cnf
# MariaDB custom configuration
[mysqld]
# Security settings
skip-name-resolve
local-infile=0
symbolic-links=0
secure-file-priv=/var/lib/mysql-files

# Character set and collation
character-set-server=${MARIADB_CHARACTER_SET}
collation-server=${MARIADB_COLLATION}

# Performance settings
innodb_buffer_pool_size=256M
innodb_log_file_size=48M
innodb_flush_log_at_trx_commit=1
innodb_flush_method=O_DIRECT
innodb_file_per_table=1
innodb_buffer_pool_instances=1

# Query cache (disabled by default in MariaDB 10.1.7+)
query_cache_type=0
query_cache_size=0

# Connection settings
max_connections=100
max_connect_errors=10
wait_timeout=600
interactive_timeout=600

# Logging
slow_query_log=1
slow_query_log_file=/var/log/mysql/slow.log
long_query_time=2
log_queries_not_using_indexes=1
log_error=/var/log/mysql/error.log

# Binary logging (for replication)
server-id=1
log_bin=/var/log/mysql/mariadb-bin
expire_logs_days=7
max_binlog_size=100M
binlog_format=ROW

# MyISAM settings (if used)
key_buffer_size=16M
myisam_sort_buffer_size=8M
read_buffer_size=256K
read_rnd_buffer_size=512K
sort_buffer_size=512K

# Other settings
tmp_table_size=32M
max_heap_table_size=32M
thread_cache_size=8
table_open_cache=2000
table_definition_cache=1000
open_files_limit=65535

[mysqld_safe]
log-error=/var/log/mysql/error.log
pid-file=/var/run/mysqld/mysqld.pid

[client]
default-character-set=${MARIADB_CHARACTER_SET}

[mysql]
default-character-set=${MARIADB_CHARACTER_SET}
EOF

# Create log directory with proper permissions
RUN mkdir -p /var/log/mysql && \
    chown -R ${MARIADB_USER}:${MARIADB_GROUP} /var/log/mysql && \
    chmod -R 750 /var/log/mysql

# Declare persistent data volume
VOLUME /var/lib/mysql

# Switch to non-root user
USER ${MARIADB_USER}

# Expose MariaDB port
EXPOSE 3306

# Health check for MariaDB
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD mysqladmin ping -h localhost || exit 1

# Start MariaDB (inherits default CMD from parent image)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Basic MariaDB deployment
# docker build -t mariadb-server:prod .

# Example 2: Run with default configuration
# docker run -d \
#   -p 3306:3306 \
#   --name mariadb-server \
#   mariadb-server:prod

# Example 3: Custom configuration
# docker build \
#   --build-arg MARIADB_ROOT_PASSWORD=securepassword \
#   --build-arg MARIADB_DATABASE=myapp \
#   -t mariadb-server:custom .

# Example 4: Persistent storage
# docker run -d \
#   -p 3306:3306 \
#   -v mariadb-data:/var/lib/mysql \
#   --name mariadb-server \
#   mariadb-server:prod

# Example 5: Resource limits
# docker run -d \
#   --name mariadb-server \
#   --memory=2g \
#   --cpus=2 \
#   -p 3306:3306 \
#   mariadb-server:prod

# Example 6: Docker Compose integration
# services:
#   mariadb:
#     build: .
#     ports:
#       - "3306:3306"
#     environment:
#       - MARIADB_ROOT_PASSWORD=securepassword
#       - MARIADB_DATABASE=myapp
#     volumes:
#       - mariadb-data:/var/lib/mysql

# Example 7: Combine with application
# cat frameworks/laravel.Dockerfile \
#     tools/mariadb.Dockerfile > Dockerfile

# Example 8: Production deployment
# docker run -d \
#   --name mariadb-server \
#   --restart unless-stopped \
#   --memory=4g \
#   --cpus=2 \
#   -p 3306:3306 \
#   -v mariadb-data:/var/lib/mysql \
#   mariadb-server:prod

# BEST PRACTICES
# ==============

# 1. Always use strong passwords for MARIADB_ROOT_PASSWORD
# 2. Use volumes for persistent data storage (/var/lib/mysql)
# 3. Set appropriate resource limits (memory, CPU) for database workload
# 4. Regularly backup the database using mysqldump or mariadb-dump
# 5. Monitor database health and performance metrics
# 6. Use .my.cnf or environment variables for password management
# 7. Enable SSL/TLS for network connections
# 8. Regularly update MariaDB to latest security patches

# Security Recommendations:
# 1. Change default MariaDB passwords immediately
# 2. Use encryption for network connections (SSL/TLS)
# 3. Restrict network access to trusted hosts only
# 4. Regularly audit database permissions and access
# 5. Use separate database users for different applications
# 6. Implement connection rate limiting
# 7. Scan for vulnerabilities regularly
# 8. Use secrets management for sensitive database credentials

# Performance Optimization:
# 1. Configure buffer pool size (innodb_buffer_pool_size) appropriately
# 2. Optimize query cache settings for your workload
# 3. Use appropriate storage engines (InnoDB for transactions)
# 4. Monitor and tune performance regularly
# 5. Implement connection pooling for application connections

# MariaDB-Specific Configuration:
# • Adjust character set and collation for your application needs
# • Configure replication for high availability
# • Set up automated backups with point-in-time recovery
# • Implement query logging for debugging and optimization
# • Configure connection limits based on expected workload

# Operations and Maintenance:
# 1. Establish regular backup procedures (daily/weekly)
# 2. Implement monitoring and alerting for database health
# 3. Document configuration changes and version upgrades
# 4. Test disaster recovery procedures regularly
# 5. Keep documentation updated with current configurations

# Customization Notes:
# 1. Adjust MARIADB_CHARACTER_SET and MARIADB_COLLATION for your locale
# 2. Modify buffer pool size based on available memory
# 3. Add custom SQL scripts in /docker-entrypoint-initdb.d/
# 4. Configure replication for high availability setups
# 5. Set up automated maintenance procedures (optimize, analyze)
