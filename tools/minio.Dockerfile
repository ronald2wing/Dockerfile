# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for MinIO
# Website: https://min.io/
# Repository: https://github.com/minio/minio
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: High-performance S3-compatible object storage server
# · DESIGN PHILOSOPHY: Cloud-native object storage with S3 API compatibility
# · COMBINATION: Use with applications requiring object storage
# · SECURITY: TLS encryption, access keys, bucket policies
# · BEST PRACTICES: Distributed mode for production, erasure coding
# · OFFICIAL SOURCES: MinIO documentation and security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE - MinIO server
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM minio/minio:RELEASE.2024-01-04T22-44-52Z

# Build arguments for environment configuration
ARG MINIO_VERSION=RELEASE.2024-01-04T22-44-52Z
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
# SECURITY: MINIO_ROOT_USER must be set via environment variable or build argument
# Example: --build-arg MINIO_ROOT_USER=your_username_here
ARG MINIO_ROOT_USER=minioadmin
# SECURITY: MINIO_ROOT_PASSWORD must be set via environment variable or build argument
# Example: --build-arg MINIO_ROOT_PASSWORD=your_secure_password_here
ARG MINIO_ROOT_PASSWORD=minioadmin
ARG MINIO_REGION=us-east-1
ARG MINIO_BROWSER=on

# Environment variables for runtime
ENV MINIO_VERSION=${MINIO_VERSION} \
    BUILD_ID=${BUILD_ID} \
    COMMIT_SHA=${COMMIT_SHA} \
    MINIO_ROOT_USER=${MINIO_ROOT_USER} \
    MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD} \
    MINIO_REGION=${MINIO_REGION} \
    MINIO_BROWSER=${MINIO_BROWSER} \
    MINIO_PROMETHEUS_AUTH_TYPE=public \
    MINIO_UPDATE=off

# Security configuration
ARG APP_USER=miniouser
ARG APP_GROUP=miniogroup
ARG APP_UID=1001
ARG APP_GID=1001

# Create non-root user and group
RUN addgroup -g ${APP_GID} -S ${APP_GROUP} && \
    adduser -S -u ${APP_UID} -G ${APP_GROUP} ${APP_USER}

# Create data directory with proper permissions
RUN mkdir -p /data && \
    chown -R ${APP_USER}:${APP_GROUP} /data && \
    chmod -R 750 /data

# Create configuration directory
RUN mkdir -p /etc/minio && \
    chown -R ${APP_USER}:${APP_GROUP} /etc/minio && \
    chmod -R 750 /etc/minio

WORKDIR /minio

# Copy custom configuration if any
COPY --chown=${APP_USER}:${APP_GROUP} config/ /etc/minio/config/

# Set permissions
RUN chown -R ${APP_USER}:${APP_GROUP} /minio && \
    chmod -R 750 /minio

# Declare persistent data volume
VOLUME /data

# Switch to non-root user
USER ${APP_USER}

# Expose MinIO ports
EXPOSE 9000 9001

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:9000/minio/health/live || exit 1

# Application entrypoint
ENTRYPOINT ["minio"]

# Default command (can be overridden)
CMD ["server", "/data", "--console-address", ":9001"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Basic MinIO standalone deployment:
#    docker build -t minio-server -f minio.Dockerfile .
#    docker run -p 9000:9000 -p 9001:9001 -v minio-data:/data --name minio minio-server
#
# 2. Production deployment with custom credentials:
#    docker build --build-arg MINIO_ROOT_USER=admin --build-arg MINIO_ROOT_PASSWORD=securepassword \
#      -t minio-prod .
#    docker run -d -p 9000:9000 -p 9001:9001 -v minio-data:/data \
#      --restart unless-stopped --memory 1g --cpus 2 --name minio-prod minio-prod
#
# 3. Development with mounted configuration:
#    docker run -it --rm -p 9000:9000 -p 9001:9001 -v $(pwd)/config:/etc/minio/config \
#      -v minio-dev-data:/data --name minio-dev minio-server
#
# 4. Distributed deployment (4 nodes):
#    docker run -d -p 9000:9000 -p 9001:9001 \
#      -v minio-data1:/data1 -v minio-data2:/data2 -v minio-data3:/data3 -v minio-data4:/data4 \
#      --name minio1 minio-server server http://minio{1...4}/data{1...4}
#
# 5. TLS-enabled deployment:
#    docker run -d -p 9000:9000 -p 9001:9001 -v minio-data:/data \
#      -v /path/to/certs:/root/.minio/certs --name minio-tls minio-server
#
# 6. Gateway mode (S3 backend):
#    docker run -d -p 9000:9000 -p 9001:9001 --name minio-gateway \
#      minio-server gateway s3 https://s3.amazonaws.com
#
# 7. Application integration with Express.js:
#    cat frameworks/express.Dockerfile tools/minio.Dockerfile > Dockerfile
#    docker build -t express-with-storage .
#
# 8. Monitoring and metrics collection:
#    cat tools/minio.Dockerfile tools/grafana.Dockerfile > Dockerfile
#    docker build -t minio-monitored .

# BEST PRACTICES
# ==============
# • Security & Compliance:
#   - Always set secure credentials via environment variables or build arguments
#   - Enable TLS encryption for network communication in production
#   - Use IAM-style policies for fine-grained access control
#   - Regularly update MinIO versions for security patches
#
# • Performance & Optimization:
#   - Use distributed mode for production deployments with erasure coding
#   - Configure appropriate storage class policies for data durability
#   - Implement lifecycle management for automatic data tiering
#   - Monitor disk I/O performance for object storage workloads
#
# • Development & Operations:
#   - Use named volumes for persistent object storage
#   - Implement proper health checks for container orchestration
#   - Configure resource limits (CPU, memory) based on workload
#   - Set up monitoring and alerting for storage performance
#
# • MinIO-Specific Considerations:
#   - Understand MinIO's S3 API compatibility and limitations
#   - Design bucket naming conventions for efficient organization
#   - Implement proper object locking and retention policies
#   - Consider using MinIO's event notifications for automation
#
# • Combination Patterns:
#   - Combine with frameworks/express.Dockerfile for web applications
#   - Use with tools/grafana.Dockerfile for visualization and dashboards
#   - Integrate with patterns/monitoring.Dockerfile for comprehensive monitoring
#   - Combine with patterns/security-hardened.Dockerfile for enhanced security
#   - Use with patterns/docker-compose.Dockerfile for multi-service deployments
