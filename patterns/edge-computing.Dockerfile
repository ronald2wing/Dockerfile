# ==============================================================================
# Created by https://Dockerfile.io/
# Pattern TEMPLATE for Edge Computing
# Website: https://dockerfile.io/
# Repository: https://github.com/ronald2wing/Dockerfile
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Pattern
# · PURPOSE: Optimizations for edge computing and IoT deployments
# · DESIGN PHILOSOPHY: Minimal resource usage, ARM compatibility, offline operation
# · COMBINATION: Combine with language templates for edge applications
# · SECURITY: Minimal attack surface, read-only filesystem, secure updates
# · BEST PRACTICES: Small base images, ARM multi-arch support, resource constraints
# · OFFICIAL SOURCES: Docker multi-arch builds, edge computing best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EDGE COMPUTING OPTIMIZATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# This template provides optimizations for edge computing applications.
# Combine with language templates to create edge-ready containers.

# Edge computing environment variables
ENV EDGE_MODE=true \
    RESOURCE_CONSTRAINED=true \
    OFFLINE_CAPABLE=true \
    ARM_COMPATIBLE=true \
    MEMORY_LIMIT=256m \
    CPU_LIMIT=0.5

# Multi-architecture support labels
LABEL architecture="multi-arch" \
      platforms="linux/amd64,linux/arm64,linux/arm/v7" \
      io.edge.optimized="true" \
      io.edge.resource-constrained="true"

# Resource limits for edge devices
# Note: These are example limits - adjust based on your edge device capabilities
# RUN echo "memory: 256m" >> /etc/container-limits.conf && \
#     echo "cpu: 0.5" >> /etc/container-limits.conf

# Health check optimized for edge environments with intermittent connectivity
HEALTHCHECK --interval=60s --timeout=10s --start-period=120s --retries=5 \
    CMD [ "sh", "-c", "test -f /tmp/healthy || exit 1" ]

# Example edge application startup (override in your Dockerfile)
# CMD ["/usr/local/bin/edge-app"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Basic edge computing application:
#    cat patterns/edge-computing.Dockerfile > Dockerfile
#    docker build -t edge-app .
#
# 2. Multi-architecture build for ARM devices:
#    docker buildx build --platform linux/arm64,linux/amd64 -t edge-app .
#
# 3. Edge deployment with resource constraints:
#    docker run -d --memory=256m --cpus=0.5 --name edge-app edge-app
#
# 4. Development with mounted source code:
#    docker run -it --rm -v $(pwd):/app -p 8080:8080 edge-app
#
# 5. Production edge deployment:
#    docker run -d --restart unless-stopped --memory=256m --cpus=0.5 --name edge-prod edge-app
#
# 6. Edge device with intermittent connectivity:
#    docker run -d --network host --name edge-device edge-app
#
# 7. Combining with language templates:
#    cat languages/python.Dockerfile patterns/edge-computing.Dockerfile > Dockerfile
#    docker build -t python-edge-app .
#
# 8. Edge monitoring and logging:
#    docker run -d --log-driver=json-file --log-opt max-size=10m --name edge-monitored edge-app

# BEST PRACTICES
# ==============
# • Security & Compliance:
#   - Use minimal base images (Alpine Linux) to reduce attack surface
#   - Implement read-only filesystems where possible
#   - Use ARM multi-arch builds for edge device compatibility
#   - Regularly update base images and dependencies for security patches
#
# • Performance & Optimization:
#   - Set strict resource limits (CPU, memory) for edge device constraints
#   - Optimize for small image sizes to reduce storage and transfer overhead
#   - Implement efficient health checks for intermittent connectivity
#   - Use lightweight logging drivers to conserve disk space
#
# • Development & Operations:
#   - Design for offline operation and graceful degradation
#   - Implement secure update mechanisms for remote edge devices
#   - Configure proper health checks for edge environments
#   - Use environment variables for edge-specific configuration
#
# • Edge Computing-Specific Considerations:
#   - Understand edge device constraints (CPU, memory, storage, network)
#   - Design for intermittent connectivity and network latency
#   - Implement local data processing to reduce cloud dependency
#   - Consider power consumption and thermal constraints
#
# • Combination Patterns:
#   - Combine with language templates (python.Dockerfile, go.Dockerfile) for application logic
#   - Use with patterns/alpine.Dockerfile for minimal image sizes
#   - Integrate with patterns/security-hardened.Dockerfile for enhanced security
#   - Combine with patterns/multi-stage.Dockerfile for optimized builds
#   - Use with tools/mqtt.Dockerfile for IoT communication protocols
