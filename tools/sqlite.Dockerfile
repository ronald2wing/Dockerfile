# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for SQLite
# Website: https://www.sqlite.org/
# Repository: https://github.com/sqlite/sqlite
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: SQLite database with utilities and security hardening
# · DESIGN PHILOSOPHY: Lightweight, embedded database with tools
# · COMBINATION: Use standalone or with application containers
# · SECURITY: File permissions, backup strategies
# · BEST PRACTICES: Regular backups, proper file permissions, WAL mode
# · OFFICIAL SOURCES: SQLite documentation and Docker best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM alpine:3.19

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG SQLITE_VERSION=3.45.1
ARG BUILD_ID=unknown

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV SQLITE_VERSION=${SQLITE_VERSION} \
  BUILD_ID=${BUILD_ID} \
  SQLITE_USER=sqlite \
  SQLITE_GROUP=sqlite \
  SQLITE_DATA_DIR=/data \
  SQLITE_BACKUP_DIR=/backups \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INSTALL SQLITE AND UTILITIES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RUN apk add --no-cache \
  sqlite \
  sqlite-dev \
  sqlite-analyzer \
  sqlite-doc \
  bash \
  tzdata \
  ca-certificates \


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create non-root user and group
RUN addgroup -g 1000 -S ${SQLITE_GROUP} && \
    adduser -S -D -H -u 1000 -h ${SQLITE_DATA_DIR} -s /bin/bash -G ${SQLITE_GROUP} ${SQLITE_USER}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DIRECTORY SETUP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create data and backup directories
RUN mkdir -p ${SQLITE_DATA_DIR} ${SQLITE_BACKUP_DIR} && \
    chown -R ${SQLITE_USER}:${SQLITE_GROUP} ${SQLITE_DATA_DIR} ${SQLITE_BACKUP_DIR} && \
    chmod 750 ${SQLITE_DATA_DIR} ${SQLITE_BACKUP_DIR}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# UTILITY SCRIPTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Copy utility scripts
COPY scripts/ /usr/local/bin/

# Set executable permissions
RUN chmod +x /usr/local/bin/*.sh && \
    chown ${SQLITE_USER}:${SQLITE_GROUP} /usr/local/bin/*.sh

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECK
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Health check for SQLite
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD sqlite3 --version || exit 1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WORKDIR ${SQLITE_DATA_DIR}

# Switch to non-root user
USER ${SQLITE_USER}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VOLUME DECLARATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Declare volumes for data persistence
VOLUME ["${SQLITE_DATA_DIR}", "${SQLITE_BACKUP_DIR}"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT & COMMAND
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Default entrypoint
ENTRYPOINT ["sqlite3"]

# Default command (interactive shell)
CMD []

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Build SQLite image
# docker build -t my-sqlite:prod .

# Example 2: Run SQLite interactive shell
# docker run -it --rm my-sqlite:prod

# Example 3: Run with data volume
# docker run -it --rm \
#   -v $(pwd)/data:/data \
#   -v $(pwd)/backups:/backups \
#   my-sqlite:prod

# Example 4: Execute SQL script
# docker run --rm \
#   -v $(pwd)/data:/data \
#   my-sqlite:prod /data/init.sql

# Example 5: Backup database
# docker run --rm \
#   -v $(pwd)/data:/data \
#   -v $(pwd)/backups:/backups \
#   my-sqlite:prod .backup /backups/db_backup_$(date +%Y%m%d).db

# Example 6: Run with Docker Compose
# version: '3.8'
# services:
#   sqlite:
#     build: .
#     volumes:
#       - ./data:/data
#       - ./backups:/backups
#     restart: unless-stopped

# Best Practices:
# 1. Always backup SQLite databases regularly
# 2. Use WAL (Write-Ahead Logging) mode for better concurrency
# 3. Set proper file permissions on database files
# 4. Monitor database size and performance
# 5. Use transactions for data integrity

# Customization Notes:
# 1. Adjust data and backup directory paths as needed
# 2. Add custom SQL scripts for database initialization
# 3. Configure automatic backup schedules
# 4. Add monitoring and alerting for database health

# Utility Scripts:
# Create the following scripts in a scripts/ directory:

# backup.sh - Backup database
# #!/bin/bash
# # Backup SQLite database
# BACKUP_FILE="${SQLITE_BACKUP_DIR}/db_backup_$(date +%Y%m%d_%H%M%S).db"
# sqlite3 "${SQLITE_DATA_DIR}/database.db" ".backup '${BACKUP_FILE}'"
# echo "Backup created: ${BACKUP_FILE}"

# restore.sh - Restore database
# #!/bin/bash
# # Restore SQLite database from backup
# if [ -z "$1" ]; then
#   echo "Usage: $0 <backup_file>"
#   exit 1
# fi
# sqlite3 "${SQLITE_DATA_DIR}/database.db" ".restore '$1'"
# echo "Database restored from: $1"

# optimize.sh - Optimize database
# #!/bin/bash
# # Optimize SQLite database
# sqlite3 "${SQLITE_DATA_DIR}/database.db" "VACUUM;"
# sqlite3 "${SQLITE_DATA_DIR}/database.db" "ANALYZE;"
# echo "Database optimized"

# check.sh - Check database integrity
# #!/bin/bash
# # Check SQLite database integrity
# sqlite3 "${SQLITE_DATA_DIR}/database.db" "PRAGMA integrity_check;"

# SQLite Features:
# This template includes:
# - SQLite command-line interface
# - SQLite analyzer for database statistics
# - Timezone data for date/time functions
# - SSL certificates for secure connections

# Database Modes:
# Enable WAL mode for better concurrency:
# PRAGMA journal_mode=WAL;

# Enable foreign key constraints:
# PRAGMA foreign_keys=ON;

# Set synchronous mode for durability:
# PRAGMA synchronous=NORMAL;

# Performance Tuning:
# Adjust cache size for better performance:
# PRAGMA cache_size=-2000;  # 2MB cache

# Set page size for optimal performance:
# PRAGMA page_size=4096;

# Monitoring:
# Check database statistics:
# sqlite3_analyzer database.db

# Get database schema:
# sqlite3 database.db .schema

# Get table information:
# sqlite3 database.db ".tables"
# sqlite3 database.db "PRAGMA table_info(table_name);"
