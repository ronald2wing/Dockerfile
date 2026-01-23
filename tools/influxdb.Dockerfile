# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for InfluxDB
# Website: https://www.influxdata.com/
# Repository: https://github.com/influxdata/influxdb
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Time series database for metrics, events, and analytics
# · DESIGN PHILOSOPHY: High-performance time series data storage and querying
# · COMBINATION: Use with monitoring systems and IoT applications
# · SECURITY: Authentication, authorization, TLS encryption
# · BEST PRACTICES: Retention policies, continuous queries, downsampling
# · OFFICIAL SOURCES: InfluxDB documentation and performance guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE - InfluxDB
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM influxdb:2.7-alpine

# Build arguments for environment configuration
ARG INFLUXDB_VERSION=2.7
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
# SECURITY: INFLUXDB_USER must be set via environment variable or build argument
# Example: --build-arg INFLUXDB_USER=your_username_here
ARG INFLUXDB_USER=admin
# SECURITY: INFLUXDB_PASSWORD must be set via environment variable or build argument
# Example: --build-arg INFLUXDB_PASSWORD=your_secure_password_here
ARG INFLUXDB_PASSWORD=
ARG INFLUXDB_ORG=myorg
ARG INFLUXDB_BUCKET=mybucket
ARG INFLUXDB_RETENTION=30d

# Environment variables for runtime
ENV INFLUXDB_VERSION=${INFLUXDB_VERSION} \
    BUILD_ID=${BUILD_ID} \
    COMMIT_SHA=${COMMIT_SHA} \
    INFLUXDB_USER=${INFLUXDB_USER} \
    INFLUXDB_PASSWORD=${INFLUXDB_PASSWORD} \
    INFLUXDB_ORG=${INFLUXDB_ORG} \
    INFLUXDB_BUCKET=${INFLUXDB_BUCKET} \
    INFLUXDB_RETENTION=${INFLUXDB_RETENTION} \
    INFLUXDB_HTTP_BIND_ADDRESS=:8086 \
    INFLUXDB_HTTP_AUTH_ENABLED=true \
    INFLUXDB_REPORTING_DISABLED=true

# Security configuration
ARG APP_USER=influxuser
ARG APP_GROUP=influxgroup
ARG APP_UID=1001
ARG APP_GID=1001

# Create non-root user and group
RUN addgroup -g ${APP_GID} -S ${APP_GROUP} && \
    adduser -S -u ${APP_UID} -G ${APP_GROUP} ${APP_USER}

# Create data directory with proper permissions
RUN mkdir -p /var/lib/influxdb2 && \
    chown -R ${APP_USER}:${APP_GROUP} /var/lib/influxdb2 && \
    chmod -R 750 /var/lib/influxdb2

# Create configuration directory
RUN mkdir -p /etc/influxdb2 && \
    chown -R ${APP_USER}:${APP_GROUP} /etc/influxdb2 && \
    chmod -R 750 /etc/influxdb2

WORKDIR /influxdb

# Copy custom configuration if any
COPY --chown=${APP_USER}:${APP_GROUP} config/ /etc/influxdb2/config/

# Set permissions
RUN chown -R ${APP_USER}:${APP_GROUP} /influxdb && \
    chmod -R 750 /influxdb

# Declare persistent data volume
VOLUME /var/lib/influxdb

# Switch to non-root user
USER ${APP_USER}

# Expose InfluxDB ports
EXPOSE 8086

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8086/health || exit 1

# Application entrypoint
ENTRYPOINT ["influxd"]

# Default command (can be overridden)
CMD ["run", "--config", "/etc/influxdb2/config/influx-config.yml"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Basic InfluxDB deployment:
#    docker build -t influxdb-server -f influxdb.Dockerfile .
#    docker run -p 8086:8086 -v influxdb-data:/var/lib/influxdb2 --name influxdb influxdb-server
#
# 2. Production deployment with resource limits:
#    docker run -d -p 8086:8086 -v influxdb-data:/var/lib/influxdb2 \
#      --restart unless-stopped --memory 2g --cpus 2 --name influxdb-prod influxdb-server
#
# 3. Development with custom configuration:
#    docker run -it --rm -p 8086:8086 -v $(pwd)/config:/etc/influxdb2/config \
#      -v influxdb-dev-data:/var/lib/influxdb2 --name influxdb-dev influxdb-server
#
# 4. Initial setup and configuration:
#    docker exec -it influxdb influx setup \
#      --username admin --password securepassword \
#      --org myorganization --bucket mybucket --retention 30d --force
#
# 5. TLS-enabled deployment:
#    docker run -d -p 8086:8086 -v influxdb-data:/var/lib/influxdb2 \
#      -v /path/to/certs:/etc/influxdb2/certs --name influxdb-tls influxdb-server
#
# 6. Multi-node cluster (simplified):
#    # Node 1
#    docker run -d -p 8086:8086 --name influxdb-node1 influxdb-server
#    # Node 2
#    docker run -d -p 8087:8086 --name influxdb-node2 influxdb-server
#
# 7. Monitoring stack integration:
#    cat tools/influxdb.Dockerfile tools/grafana.Dockerfile > Dockerfile
#    docker build -t monitoring-stack .
#
# 8. Backup and restore operations:
#    # Backup
#    docker exec influxdb influx backup /var/lib/influxdb2/backup
#    # Restore
#    docker exec influxdb influx restore /var/lib/influxdb2/backup

# BEST PRACTICES
# ==============
# • Security & Compliance:
#   - Always set secure passwords via environment variables or build arguments
#   - Enable TLS encryption for network communication in production
#   - Use tokens for application authentication instead of username/password
#   - Regularly update InfluxDB versions for security patches
#
# • Performance & Optimization:
#   - Configure appropriate retention policies based on data requirements
#   - Use continuous queries for real-time data aggregation
#   - Implement downsampling strategies for long-term data storage
#   - Monitor disk I/O performance for time-series data workloads
#
# • Development & Operations:
#   - Use named volumes for persistent data storage
#   - Implement proper health checks for container orchestration
#   - Configure resource limits (CPU, memory) based on workload
#   - Set up monitoring and alerting for database performance
#
# • InfluxDB-Specific Considerations:
#   - Understand InfluxDB's data model (measurements, tags, fields, timestamps)
#   - Design schema for efficient query performance
#   - Use appropriate precision for timestamp data
#   - Implement proper data retention and archiving strategies
#
# • Combination Patterns:
#   - Combine with tools/grafana.Dockerfile for visualization and dashboards
#   - Use with tools/telegraf.Dockerfile for metrics collection
#   - Integrate with patterns/monitoring.Dockerfile for comprehensive monitoring
#   - Combine with patterns/security-hardened.Dockerfile for enhanced security
#   - Use with patterns/docker-compose.Dockerfile for multi-service deployments
