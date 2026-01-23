# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for TimescaleDB
# Website: https://www.timescale.com/
# Repository: https://github.com/timescale/timescaledb
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Time-series database built on PostgreSQL
# · DESIGN PHILOSOPHY: SQL for time-series with PostgreSQL compatibility
# · COMBINATION: Use for time-series data with relational queries
# · SECURITY: PostgreSQL security model, TLS, authentication
# · BEST PRACTICES: Hypertables, compression, continuous aggregates
# · OFFICIAL SOURCES: TimescaleDB documentation and PostgreSQL guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE - TimescaleDB (PostgreSQL extension)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM timescale/timescaledb:2.14-pg15

# Build arguments for environment configuration
ARG TIMESCALEDB_VERSION=2.14
ARG POSTGRES_VERSION=15
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG POSTGRES_USER=timescale
ARG POSTGRES_PASSWORD=timescale123
ARG POSTGRES_DB=timeseries
ARG POSTGRES_INITDB_ARGS="--data-checksums"

# Environment variables for runtime
ENV TIMESCALEDB_VERSION=${TIMESCALEDB_VERSION} \
    POSTGRES_VERSION=${POSTGRES_VERSION} \
    BUILD_ID=${BUILD_ID} \
    COMMIT_SHA=${COMMIT_SHA} \
    POSTGRES_USER=${POSTGRES_USER} \
    POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
    POSTGRES_DB=${POSTGRES_DB} \
    POSTGRES_INITDB_ARGS=${POSTGRES_INITDB_ARGS} \
    PGDATA=/var/lib/postgresql/data \
    POSTGRES_HOST_AUTH_METHOD=scram-sha-256

# Security configuration
ARG APP_USER=postgres
ARG APP_GROUP=postgres
ARG APP_UID=999
ARG APP_GID=999

# Create data directory with proper permissions
RUN mkdir -p ${PGDATA} && \
    chown -R ${APP_USER}:${APP_GROUP} ${PGDATA} && \
    chmod -R 750 ${PGDATA}

# Create configuration directory
RUN mkdir -p /etc/timescaledb && \
    chown -R ${APP_USER}:${APP_GROUP} /etc/timescaledb && \
    chmod -R 750 /etc/timescaledb

WORKDIR /timescaledb

# Copy custom configuration if any
COPY --chown=${APP_USER}:${APP_GROUP} config/ /etc/timescaledb/config/

# Copy initialization scripts
COPY --chown=${APP_USER}:${APP_GROUP} docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/

# Set permissions
RUN chown -R ${APP_USER}:${APP_GROUP} /timescaledb && \
    chmod -R 750 /timescaledb

# Declare persistent data volume
VOLUME /var/lib/postgresql/data

# Switch to postgres user (already non-root)
USER ${APP_USER}

# Expose PostgreSQL port
EXPOSE 5432

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB} || exit 1

# Application entrypoint (inherited from parent image)
# Default command: postgres with TimescaleDB extension

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Basic TimescaleDB deployment:
#    docker build -t timescaledb-server -f timescaledb.Dockerfile .
#    docker run -p 5432:5432 -v timescaledb-data:/var/lib/postgresql/data --name timescaledb timescaledb-server
#
# 2. Production deployment with custom credentials:
#    docker build --build-arg POSTGRES_PASSWORD=securepassword -t timescaledb-prod .
#    docker run -d -p 5432:5432 -v timescaledb-data:/var/lib/postgresql/data \
#      --restart unless-stopped --memory 4g --cpus 2 --shm-size 256mb --name timescaledb-prod timescaledb-prod
#
# 3. Development with mounted configuration:
#    docker run -it --rm -p 5432:5432 -v $(pwd)/config:/etc/timescaledb/config \
#      -v timescaledb-dev-data:/var/lib/postgresql/data --name timescaledb-dev timescaledb-server
#
# 4. TLS-enabled deployment:
#    docker run -d -p 5432:5432 -v timescaledb-data:/var/lib/postgresql/data \
#      -v /path/to/certs:/etc/ssl/certs --name timescaledb-tls timescaledb-server
#
# 5. High-performance analytics deployment:
#    docker run -d -p 5432:5432 -v timescaledb-data:/var/lib/postgresql/data \
#      --restart unless-stopped --memory 8g --cpus 4 --shm-size 512mb --name timescaledb-analytics timescaledb-server
#
# 6. Monitoring stack with Prometheus and Grafana:
#    cat tools/timescaledb.Dockerfile tools/prometheus.Dockerfile tools/grafana.Dockerfile > Dockerfile
#    docker build -t timeseries-monitoring .
#
# 7. Time-series data pipeline:
#    cat tools/timescaledb.Dockerfile languages/python.Dockerfile > Dockerfile
#    docker build -t timeseries-pipeline .
#
# 8. Complete time-series solution:
#    cat tools/timescaledb.Dockerfile patterns/monitoring.Dockerfile > Dockerfile
#    docker build -t comprehensive-timeseries .

# BEST PRACTICES
# ==============
# • Security & Compliance:
#   - Always change default credentials in production deployments
#   - Enable TLS/SSL encryption for network communication
#   - Use SCRAM-SHA-256 authentication for enhanced security
#   - Implement network policies to restrict database access
#   - Regularly update TimescaleDB and PostgreSQL for security patches
#
# • Performance & Optimization:
#   - Configure appropriate memory settings (shared_buffers, work_mem)
#   - Use hypertables for automatic time-based partitioning
#   - Enable compression for significant storage reduction (up to 20x)
#   - Implement continuous aggregates for fast query performance
#   - Set appropriate data retention policies based on business needs
#
# • Development & Operations:
#   - Use named volumes for persistent time-series data storage
#   - Implement proper health checks for container orchestration
#   - Configure resource limits (CPU, memory, shared memory) based on workload
#   - Set up monitoring for database performance metrics and resource usage
#
# • TimescaleDB-Specific Considerations:
#   - Understand TimescaleDB's time-series optimization features
#   - Design efficient hypertable schemas with appropriate partitioning
#   - Use compression policies for older time-series data
#   - Implement continuous aggregates for frequently queried time ranges
#   - Consider distributed hypertables for horizontal scaling needs
#
# • PostgreSQL Compatibility Features:
#   - Leverage full SQL support for complex queries
#   - Use JSON/JSONB support for semi-structured time-series data
#   - Implement foreign data wrappers for data integration
#   - Utilize PostgreSQL extensions alongside TimescaleDB
#
# • Combination Patterns:
#   - Combine with tools/prometheus.Dockerfile for metrics storage
#   - Use with tools/grafana.Dockerfile for time-series visualization
#   - Integrate with patterns/monitoring.Dockerfile for comprehensive monitoring
#   - Combine with patterns/security-hardened.Dockerfile for enhanced security
#   - Use with patterns/docker-compose.Dockerfile for multi-service deployments
