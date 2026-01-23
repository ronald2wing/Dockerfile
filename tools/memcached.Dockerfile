# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for Memcached
# Website: https://memcached.org/
# Repository: https://github.com/memcached/memcached
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Production-ready Memcached caching server
# · DESIGN PHILOSOPHY: Security-hardened with performance optimization
# · COMBINATION: Combine with application frameworks for caching
# · SECURITY: Non-root user, minimal base image, network security
# · BEST PRACTICES: Memory limits, connection limits, monitoring
# · OFFICIAL SOURCES: Memcached documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PRODUCTION STAGE - Optimized Memcached server
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM memcached:1.6-alpine

# Build arguments for configuration
ARG MEMCACHED_USER=nobody
ARG MEMCACHED_GROUP=nogroup
ARG MEMCACHED_MEMORY=64
ARG MEMCACHED_CONNECTIONS=1024
ARG MEMCACHED_THREADS=4
ARG MEMCACHED_PORT=11211

# Environment variables for runtime
ENV MEMCACHED_USER=${MEMCACHED_USER} \
    MEMCACHED_GROUP=${MEMCACHED_GROUP} \
    MEMCACHED_MEMORY=${MEMCACHED_MEMORY} \
    MEMCACHED_CONNECTIONS=${MEMCACHED_CONNECTIONS} \
    MEMCACHED_THREADS=${MEMCACHED_THREADS} \
    MEMCACHED_PORT=${MEMCACHED_PORT}

# Labels for container metadata
LABEL maintainer="Dockerfile.io" \
      description="Memcached caching server" \
      version="1.6" \
      source="https://github.com/ronald2wing/Dockerfile"

# Create dedicated user for Memcached (already exists in base image)
# The memcached base image already runs as non-root

# Declare persistent data volume
VOLUME /cache

# Expose Memcached port
EXPOSE ${MEMCACHED_PORT}/tcp
EXPOSE ${MEMCACHED_PORT}/udp

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD echo "stats" | nc localhost ${MEMCACHED_PORT} | grep -q "STAT"

# Run as non-root user
USER memcached

# Default command with security and performance optimizations
CMD ["memcached", \
    "-u", "${MEMCACHED_USER}", \
    "-m", "${MEMCACHED_MEMORY}", \
    "-c", "${MEMCACHED_CONNECTIONS}", \
    "-t", "${MEMCACHED_THREADS}", \
    "-l", "127.0.0.1", \
    "-v"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY HARDENED STAGE - Enhanced security configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM memcached:1.6-alpine AS security-hardened

# Build arguments for security configuration
ARG MEMCACHED_USER=nobody
ARG MEMCACHED_GROUP=nogroup
ARG MEMCACHED_MEMORY=64
ARG MEMCACHED_CONNECTIONS=1024
ARG MEMCACHED_THREADS=4
ARG MEMCACHED_PORT=11211
ARG MEMCACHED_MAX_ITEM_SIZE=1m

# Environment variables for runtime
ENV MEMCACHED_USER=${MEMCACHED_USER} \
    MEMCACHED_GROUP=${MEMCACHED_GROUP} \
    MEMCACHED_MEMORY=${MEMCACHED_MEMORY} \
    MEMCACHED_CONNECTIONS=${MEMCACHED_CONNECTIONS} \
    MEMCACHED_THREADS=${MEMCACHED_THREADS} \
    MEMCACHED_PORT=${MEMCACHED_PORT} \
    MEMCACHED_MAX_ITEM_SIZE=${MEMCACHED_MAX_ITEM_SIZE}

# Labels for container metadata
LABEL maintainer="Dockerfile.io" \
      description="Security-hardened Memcached caching server" \
      version="1.6" \
      source="https://github.com/ronald2wing/Dockerfile"

# Declare persistent data volume
VOLUME /cache

# Expose Memcached port
EXPOSE ${MEMCACHED_PORT}/tcp
EXPOSE ${MEMCACHED_PORT}/udp

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD echo "stats" | nc localhost ${MEMCACHED_PORT} | grep -q "STAT"

# Run as non-root user
USER memcached

# Security-hardened command with additional protections
CMD ["memcached", \
    "-u", "${MEMCACHED_USER}", \
    "-m", "${MEMCACHED_MEMORY}", \
    "-c", "${MEMCACHED_CONNECTIONS}", \
    "-t", "${MEMCACHED_THREADS}", \
    "-l", "127.0.0.1", \
    "-I", "${MEMCACHED_MAX_ITEM_SIZE}", \
    "-o", "modern", \
    "-v"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Basic Memcached deployment:
#    docker build -t memcached-server -f memcached.Dockerfile .
#    docker run -p 11211:11211 --name memcached memcached-server
#
# 2. Production deployment with custom memory allocation:
#    docker build --build-arg MEMCACHED_MEMORY=256 -t memcached-prod .
#    docker run -d -p 11211:11211 --restart unless-stopped --name memcached-prod memcached-prod
#
# 3. Development with mounted configuration:
#    docker run -it --rm -p 11211:11211 -v $(pwd)/config:/etc/memcached \
#      --name memcached-dev memcached-server
#
# 4. High-performance configuration:
#    docker build --build-arg MEMCACHED_MEMORY=512 --build-arg MEMCACHED_CONNECTIONS=4096 \
#      -t memcached-highperf .
#    docker run -d -p 11211:11211 --name memcached-highperf memcached-highperf
#
# 5. Multi-instance deployment:
#    # Instance 1
#    docker run -d -p 11211:11211 --name memcached-1 memcached-server
#    # Instance 2
#    docker run -d -p 11212:11211 --name memcached-2 memcached-server
#
# 6. Security-hardened deployment:
#    docker build --target security-hardened -t memcached-secure .
#    docker run -d -p 11211:11211 --name memcached-secure memcached-secure
#
# 7. Application integration with Express.js:
#    cat frameworks/express.Dockerfile tools/memcached.Dockerfile > Dockerfile
#    docker build -t express-with-cache .
#
# 8. Monitoring and metrics collection:
#    cat tools/memcached.Dockerfile patterns/monitoring.Dockerfile > Dockerfile
#    docker build -t memcached-monitored .

# BEST PRACTICES
# ==============
# • Security & Compliance:
#   - Run Memcached as non-root user to minimize security risks
#   - Use network segmentation to restrict access to trusted clients
#   - Implement proper firewall rules for Memcached port (11211)
#   - Regularly update Memcached versions for security patches
#
# • Performance & Optimization:
#   - Configure appropriate memory allocation based on workload requirements
#   - Optimize connection limits for concurrent client access
#   - Implement proper eviction policies for cache management
#   - Monitor cache hit/miss ratios for performance tuning
#
# • Development & Operations:
#   - Use named volumes for persistent configuration when needed
#   - Implement proper health checks for container orchestration
#   - Configure resource limits (CPU, memory) based on workload
#   - Set up monitoring and alerting for cache performance
#
# • Memcached-Specific Considerations:
#   - Understand Memcached's LRU (Least Recently Used) eviction policy
#   - Design key naming conventions for efficient cache organization
#   - Implement proper cache invalidation strategies
#   - Consider using consistent hashing for distributed cache deployments
#
# • Combination Patterns:
#   - Combine with frameworks/express.Dockerfile for Node.js applications
#   - Use with frameworks/django.Dockerfile for Python applications
#   - Integrate with patterns/monitoring.Dockerfile for performance monitoring
#   - Combine with patterns/security-hardened.Dockerfile for enhanced security
#   - Use with patterns/docker-compose.Dockerfile for multi-service deployments
