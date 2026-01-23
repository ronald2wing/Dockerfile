# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for Redis
# Website: https://redis.io/
# Repository: https://github.com/redis/redis
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Production-ready Redis server with security hardening
# · DESIGN PHILOSOPHY: Self-contained with security configurations
# · COMBINATION: Use standalone for Redis cache/queue containers
# · SECURITY: Authentication, network security, memory limits
# · BEST PRACTICES: Resource limits, persistence configurations, monitoring
# · OFFICIAL SOURCES: Redis documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Choose appropriate base image based on your needs:

# Option 1: Official Redis with Alpine (smallest)
FROM redis:7.2-alpine

# Option 2: Redis with Debian
# FROM redis:7.2

# Option 3: Specific version with SHA
# FROM redis:7.2-alpine@sha256:abc123...

# Option 4: Redis Stack (includes RedisJSON, RedisSearch, etc.)
# FROM redis/redis-stack:7.2

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG REDIS_VERSION=7.2
# SECURITY: REDIS_PASSWORD must be set via environment variable or build argument
# Example: --build-arg REDIS_PASSWORD=your_secure_password_here
ARG REDIS_PASSWORD=change_me_123
ARG REDIS_PORT=6379

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV REDIS_VERSION=${REDIS_VERSION} \
  REDIS_PASSWORD=${REDIS_PASSWORD} \
  REDIS_PORT=${REDIS_PORT} \
  REDIS_DATABASES=16 \
  REDIS_MAXMEMORY=256mb \
  REDIS_MAXMEMORY_POLICY=allkeys-lru \
  TZ=UTC \
  LANG=C.UTF-8

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create custom Redis configuration with security hardening
RUN mkdir -p /usr/local/etc/redis && \
  echo "# Security Configuration" > /usr/local/etc/redis/redis.conf && \
  echo "requirepass ${REDIS_PASSWORD}" >> /usr/local/etc/redis/redis.conf && \
  echo "rename-command FLUSHALL \"\"" >> /usr/local/etc/redis/redis.conf && \
  echo "rename-command FLUSHDB \"\"" >> /usr/local/etc/redis/redis.conf && \
  echo "rename-command CONFIG \"\"" >> /usr/local/etc/redis/redis.conf && \
  echo "rename-command SHUTDOWN \"\"" >> /usr/local/etc/redis/redis.conf && \
  echo "" >> /usr/local/etc/redis/redis.conf && \
  echo "# Network Configuration" >> /usr/local/etc/redis/redis.conf && \
  echo "bind 0.0.0.0" >> /usr/local/etc/redis/redis.conf && \
  echo "port ${REDIS_PORT}" >> /usr/local/etc/redis/redis.conf && \
  echo "protected-mode yes" >> /usr/local/etc/redis/redis.conf && \
  echo "" >> /usr/local/etc/redis/redis.conf && \
  echo "# Memory Management" >> /usr/local/etc/redis/redis.conf && \
  echo "maxmemory ${REDIS_MAXMEMORY}" >> /usr/local/etc/redis/redis.conf && \
  echo "maxmemory-policy ${REDIS_MAXMEMORY_POLICY}" >> /usr/local/etc/redis/redis.conf && \
  echo "maxmemory-samples 5" >> /usr/local/etc/redis/redis.conf && \
  echo "" >> /usr/local/etc/redis/redis.conf && \
  echo "# Persistence" >> /usr/local/etc/redis/redis.conf && \
  echo "save 900 1" >> /usr/local/etc/redis/redis.conf && \
  echo "save 300 10" >> /usr/local/etc/redis/redis.conf && \
  echo "save 60 10000" >> /usr/local/etc/redis/redis.conf && \
  echo "stop-writes-on-bgsave-error yes" >> /usr/local/etc/redis/redis.conf && \
  echo "rdbcompression yes" >> /usr/local/etc/redis/redis.conf && \
  echo "rdbchecksum yes" >> /usr/local/etc/redis/redis.conf && \
  echo "dbfilename dump.rdb" >> /usr/local/etc/redis/redis.conf && \
  echo "dir /data" >> /usr/local/etc/redis/redis.conf && \
  echo "" >> /usr/local/etc/redis/redis.conf && \
  echo "# Logging" >> /usr/local/etc/redis/redis.conf && \
  echo "loglevel notice" >> /usr/local/etc/redis/redis.conf && \
  echo "logfile /var/log/redis/redis-server.log" >> /usr/local/etc/redis/redis.conf && \
  echo "" >> /usr/local/etc/redis/redis.conf && \
  echo "# Performance" >> /usr/local/etc/redis/redis.conf && \
  echo "timeout 0" >> /usr/local/etc/redis/redis.conf && \
  echo "tcp-keepalive 300" >> /usr/local/etc/redis/redis.conf && \
  echo "tcp-backlog 511" >> /usr/local/etc/redis/redis.conf

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DATA DIRECTORY SETUP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create data directory with proper permissions
RUN mkdir -p /data && \
  chown -R redis:redis /data && \
  chmod 750 /data

# Create logs directory
RUN mkdir -p /var/log/redis && \
  chown -R redis:redis /var/log/redis && \
  chmod 750 /var/log/redis

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Declare persistent data volume
VOLUME /data

# Expose Redis port
EXPOSE ${REDIS_PORT}

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD redis-cli --no-auth-warning -a $${REDIS_PASSWORD} ping | grep -q PONG || exit 1

# Use Redis with custom configuration
USER redis
CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CLUSTER CONFIGURATION (OPTIONAL)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# For Redis Cluster configuration, uncomment and modify:
# RUN echo "# Cluster Configuration" >> /usr/local/etc/redis/redis.conf && \
#   echo "cluster-enabled yes" >> /usr/local/etc/redis/redis.conf && \
#   echo "cluster-config-file nodes.conf" >> /usr/local/etc/redis/redis.conf && \
#   echo "cluster-node-timeout 5000" >> /usr/local/etc/redis/redis.conf && \
#   echo "cluster-require-full-coverage no" >> /usr/local/etc/redis/redis.conf

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# REPLICATION CONFIGURATION (OPTIONAL)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# For master-replica configuration, uncomment and modify:
# RUN echo "# Replication Configuration" >> /usr/local/etc/redis/redis.conf && \
#   echo "replica-read-only yes" >> /usr/local/etc/redis/redis.conf && \
#   echo "replica-priority 100" >> /usr/local/etc/redis/redis.conf

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Additional security configurations
RUN echo "# Additional Security" >> /usr/local/etc/redis/redis.conf && \
  echo "aclfile /usr/local/etc/redis/users.acl" >> /usr/local/etc/redis/redis.conf

# Create ACL file for user management
RUN echo "user default on >${REDIS_PASSWORD} ~* &* +@all" > /usr/local/etc/redis/users.acl && \
  chown redis:redis /usr/local/etc/redis/users.acl && \
  chmod 640 /usr/local/etc/redis/users.acl

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MONITORING CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Enable Redis monitoring
RUN echo "# Monitoring" >> /usr/local/etc/redis/redis.conf && \
  echo "latency-monitor-threshold 100" >> /usr/local/etc/redis/redis.conf && \
  echo "slowlog-log-slower-than 10000" >> /usr/local/etc/redis/redis.conf && \
  echo "slowlog-max-len 128" >> /usr/local/etc/redis/redis.conf

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Run Redis container with password
# docker run -d \
#   --name redis-server \
#   -e REDIS_PASSWORD=secure_password \
#   -p 6379:6379 \
#   -v redis_data:/data \
#   redis:7.2-alpine

# Example 2: Run with custom configuration
# docker run -d \
#   --name redis-server \
#   -e REDIS_PASSWORD=secure_password \
#   -p 6379:6379 \
#   -v ./redis.conf:/usr/local/etc/redis/redis.conf \
#   -v redis_data:/data \
#   redis:7.2-alpine

# Example 3: Run with resource limits
# docker run -d \
#   --name redis-server \
#   --memory="512m" \
#   --memory-swap="512m" \
#   --cpus="1" \
#   -e REDIS_PASSWORD=secure_password \
#   -e REDIS_MAXMEMORY=256mb \
#   -p 6379:6379 \
#   -v redis_data:/data \
#   redis:7.2-alpine

# Example 4: Run Redis Cluster (multiple containers)
# docker run -d \
#   --name redis-node-1 \
#   -e REDIS_PASSWORD=secure_password \
#   --network redis-cluster \
#   redis:7.2-alpine redis-server --cluster-enabled yes

# Example 5: Run with persistence
# docker run -d \
#   --name redis-server \
#   -e REDIS_PASSWORD=secure_password \
#   -p 6379:6379 \
#   -v redis_data:/data \
#   -v redis_logs:/var/log/redis \
#   redis:7.2-alpine

# Best Practices:
# 1. Always set a strong password for Redis
# 2. Disable dangerous commands (FLUSHALL, CONFIG, etc.)
# 3. Use volumes for persistent data storage
# 4. Set appropriate memory limits to prevent OOM
# 5. Enable persistence (RDB/AOF) for data durability
# 6. Use network segmentation to limit Redis access
# 7. Monitor Redis performance and memory usage
# 8. Consider using Redis Sentinel for high availability
# 9. Enable slow log for performance monitoring

# Customization Notes:
# 1. Adjust maxmemory based on available container memory
# 2. Choose appropriate eviction policy for your use case
# 3. Configure persistence settings based on data criticality
# 4. Set appropriate timeout values for your application
# 5. Consider enabling Redis ACL for fine-grained access control
