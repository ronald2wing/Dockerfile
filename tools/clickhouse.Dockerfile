# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for ClickHouse
# Website: https://clickhouse.com/
# Repository: https://github.com/ClickHouse/ClickHouse
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Production-ready ClickHouse column-oriented database
# · DESIGN PHILOSOPHY: High-performance analytics with security hardening
# · COMBINATION: Use standalone for ClickHouse database containers
# · SECURITY: Non-root user, secure defaults, network isolation
# · BEST PRACTICES: Volume persistence, query optimization, resource limits
# · OFFICIAL SOURCES: ClickHouse documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM clickhouse/clickhouse-server:23.8-alpine

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG CLICKHOUSE_VERSION=23.8
ARG BUILD_ID=unknown

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV CLICKHOUSE_VERSION=${CLICKHOUSE_VERSION} \
  BUILD_ID=${BUILD_ID} \
  CLICKHOUSE_DB=analytics \
  CLICKHOUSE_USER=analyst \
  # CLICKHOUSE_PASSWORD must be set via environment variable for security
  # Example: -e CLICKHOUSE_PASSWORD=your_secure_password_here
  CLICKHOUSE_DEFAULT_ACCESS_MANAGEMENT=1 \
  CLICKHOUSE_KEEPER_STARTUP_TIMEOUT=30 \
  CLICKHOUSE_MAX_CONCURRENT_QUERIES=100 \
  CLICKHOUSE_MAX_MEMORY_USAGE=10737418240 \
  CLICKHOUSE_MAX_QUERY_SIZE=1048576 \
  CLICKHOUSE_MAX_AST_DEPTH=1000 \
  CLICKHOUSE_MAX_EXECUTION_TIME=300 \
  CLICKHOUSE_TIMEOUT_BEFORE_CHECKING_EXECUTION_SPEED=15 \
  TZ=UTC

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create non-root user for ClickHouse processes
RUN addgroup -g 1001 -S clickhouse && \
  adduser -S clickhouse -u 1001 -G clickhouse

# Set proper permissions for ClickHouse directories
RUN chown -R clickhouse:clickhouse /var/lib/clickhouse && \
  chown -R clickhouse:clickhouse /var/log/clickhouse-server && \
  chown -R clickhouse:clickhouse /etc/clickhouse-server

# Switch to non-root user
USER clickhouse

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURATION FILES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Copy custom configuration files (if needed)
# COPY config.xml /etc/clickhouse-server/config.d/
# COPY users.xml /etc/clickhouse-server/users.d/

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VOLUME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Persistent data volume
VOLUME ["/var/lib/clickhouse"]

# Configuration volume
VOLUME ["/etc/clickhouse-server"]

# Log volume
VOLUME ["/var/log/clickhouse-server"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECK
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD clickhouse-client --query "SELECT 1" || exit 1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PORTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HTTP interface (default: 8123)
EXPOSE 8123

# Native TCP interface (default: 9000)
EXPOSE 9000

# Interserver HTTP interface (default: 9009)
EXPOSE 9009

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT AND COMMAND
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENTRYPOINT ["/entrypoint.sh"]
CMD ["clickhouse-server", "--config-file=/etc/clickhouse-server/config.xml"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES
# ==============
# 1. Basic ClickHouse container:
#    docker run -d --name clickhouse \
#      -p 8123:8123 -p 9000:9000 \
#      -e CLICKHOUSE_PASSWORD=securepassword \
#      clickhouse/clickhouse-server:23.8-alpine
#
# 2. With persistent volumes:
#    docker run -d --name clickhouse \
#      -p 8123:8123 -p 9000:9000 \
#      -v clickhouse_data:/var/lib/clickhouse \
#      -v clickhouse_config:/etc/clickhouse-server \
#      -v clickhouse_logs:/var/log/clickhouse-server \
#      -e CLICKHOUSE_PASSWORD=securepassword \
#      clickhouse/clickhouse-server:23.8-alpine
#
# 3. With custom configuration:
#    docker run -d --name clickhouse \
#      -p 8123:8123 -p 9000:9000 \
#      -v ./config.xml:/etc/clickhouse-server/config.d/config.xml \
#      -v ./users.xml:/etc/clickhouse-server/users.d/users.xml \
#      -e CLICKHOUSE_PASSWORD=securepassword \
#      clickhouse/clickhouse-server:23.8-alpine
#
# 4. With resource limits:
#    docker run -d --name clickhouse \
#      -p 8123:8123 -p 9000:9000 \
#      --memory=4g --cpus=2 \
#      -e CLICKHOUSE_MAX_MEMORY_USAGE=3221225472 \
#      -e CLICKHOUSE_PASSWORD=securepassword \
#      clickhouse/clickhouse-server:23.8-alpine
#
# 5. Health check verification:
#    docker run -d --name clickhouse-test \
#      -p 8123:8123 \
#      -e CLICKHOUSE_PASSWORD=testpass \
#      clickhouse/clickhouse-server:23.8-alpine
#    docker inspect --format='{{.State.Health.Status}}' clickhouse-test
#
# 6. Connect via clickhouse-client:
#    docker exec -it clickhouse clickhouse-client --password securepassword
#
# 7. Load sample data:
#    echo "CREATE TABLE test (id Int32, value String) ENGINE = MergeTree() ORDER BY id;" | \
#    docker exec -i clickhouse clickhouse-client --password securepassword
#
# 8. Backup and restore:
#    # Backup
#    docker exec clickhouse clickhouse-client --password securepassword \
#      --query="BACKUP DATABASE analytics TO Disk('backup', 'analytics_backup')"
#
#    # Restore
#    docker exec clickhouse clickhouse-client --password securepassword \
#      --query="RESTORE DATABASE analytics FROM Disk('backup', 'analytics_backup')"

# BEST PRACTICES
# ==============
# Security:
# • Always use strong passwords for ClickHouse users
# • Enable TLS for network connections in production
# • Use network policies to restrict access
# • Regularly update ClickHouse versions for security patches

# Performance:
# • Allocate sufficient memory for ClickHouse operations
# • Use SSD storage for better I/O performance
# • Configure appropriate merge tree settings for your data
# • Monitor query performance and optimize indexes

# Data Management:
# • Use appropriate table engines (MergeTree family for analytics)
# • Implement data retention policies
# • Regular backups of critical data
# • Monitor disk usage and plan for growth

# Operations:
# • Health checks ensure database availability
# • Resource limits prevent memory exhaustion
# • Logging configured for troubleshooting
# • Monitoring for query performance and errors

# Maintenance:
# • Regular vacuuming of old data
# • Update statistics for query optimization
# • Monitor system tables for performance insights
# • Regular testing of backup and restore procedures

# Combination Patterns:
# • Combine with frameworks/*.Dockerfile for application integration
# • Combine with patterns/monitoring.Dockerfile for observability
# • Combine with tools/grafana.Dockerfile for visualization
# • Combine with patterns/microservices.Dockerfile for distributed analytics

# ClickHouse-Specific Considerations:
# • Column-oriented storage optimized for analytics queries
# • MergeTree engine family for time-series and analytics data
# • Materialized views for real-time aggregations
# • Replicated tables for high availability
# • Consider sharding for large datasets
