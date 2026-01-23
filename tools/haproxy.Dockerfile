# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for HAProxy
# Website: https://www.haproxy.org/
# Repository: https://github.com/haproxy/haproxy
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Production-ready HAProxy load balancer with security hardening
# · DESIGN PHILOSOPHY: Self-contained with security configurations
# · COMBINATION: Use standalone for HAProxy deployments
# · SECURITY: Non-root user, minimal base image, security headers
# · BEST PRACTICES: Health checks, logging, SSL/TLS configuration
# · OFFICIAL SOURCES: HAProxy documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM haproxy:2.8-alpine

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG HAPROXY_VERSION=2.8
ARG BUILD_ID=unknown

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV HAPROXY_VERSION=${HAPROXY_VERSION} \
  BUILD_ID=${BUILD_ID} \
  HAPROXY_USER=haproxy \
  HAPROXY_GROUP=haproxy \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create non-root user and group
RUN addgroup -g 1000 -S ${HAPROXY_GROUP} && \
    adduser -S -D -H -u 1000 -h /var/lib/haproxy -s /sbin/nologin -G ${HAPROXY_GROUP} ${HAPROXY_USER}

# Set proper permissions
RUN mkdir -p /var/lib/haproxy && \
    chown -R ${HAPROXY_USER}:${HAPROXY_GROUP} /var/lib/haproxy && \
    chmod 750 /var/lib/haproxy

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURATION FILES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Copy HAProxy configuration
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

# Copy custom error pages (optional)
COPY errors/ /etc/haproxy/errors/

# Set permissions on configuration files
RUN chown -R ${HAPROXY_USER}:${HAPROXY_GROUP} /usr/local/etc/haproxy && \
    chmod 640 /usr/local/etc/haproxy/haproxy.cfg

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SSL/TLS CERTIFICATES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create directory for SSL certificates
RUN mkdir -p /etc/ssl/haproxy && \
    chown -R ${HAPROXY_USER}:${HAPROXY_GROUP} /etc/ssl/haproxy && \
    chmod 750 /etc/ssl/haproxy

# Copy SSL certificates (if available)
COPY ssl/ /etc/ssl/haproxy/

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LOGGING CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create log directory
RUN mkdir -p /var/log/haproxy && \
    chown -R ${HAPROXY_USER}:${HAPROXY_GROUP} /var/log/haproxy && \
    chmod 750 /var/log/haproxy

# Configure syslog for logging (optional)
RUN if [ -f /etc/alpine-release ]; then \
      apk add --no-cache rsyslog; \
    else \
      apt-get update && apt-get install -y --no-install-recommends rsyslog && rm -rf /var/lib/apt/lists/*; \
    fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECK
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Health check for HAProxy
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg || exit 1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Declare persistent data volume
VOLUME /var/lib/haproxy

# Expose ports
# - 80: HTTP
# - 443: HTTPS
# - 8404: Stats page (optional)
EXPOSE 80 443 8404

# Switch to non-root user
USER ${HAPROXY_USER}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT & COMMAND
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Entrypoint with configuration validation
ENTRYPOINT ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]

# Default command
CMD ["-db"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Build HAProxy image
# docker build -t my-haproxy:prod .

# Example 2: Run HAProxy container
# docker run -d -p 80:80 -p 443:443 --name haproxy my-haproxy:prod

# Example 3: Run with custom configuration
# docker run -d -p 80:80 -p 443:443 \
#   -v $(pwd)/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro \
#   -v $(pwd)/ssl:/etc/ssl/haproxy:ro \
#   --name haproxy my-haproxy:prod

# Example 4: Run with Docker Compose
# version: '3.8'
# services:
#   haproxy:
#     build: .
#     ports:
#       - "80:80"
#       - "443:443"
#     volumes:
#       - ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro
#       - ./ssl:/etc/ssl/haproxy:ro
#     restart: unless-stopped

# Example 5: Test configuration
# docker run --rm my-haproxy:prod haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg

# Best Practices:
# 1. Always validate configuration before deployment
# 2. Use SSL/TLS termination for secure connections
# 3. Implement proper health checks for backends
# 4. Monitor HAProxy metrics and logs
# 5. Set resource limits in production

# Customization Notes:
# 1. Adjust exposed ports based on your configuration
# 2. Modify health check as needed
# 3. Add environment variables for dynamic configuration
# 4. Customize logging configuration
# 5. Implement SSL/TLS with proper certificates

# Configuration File Structure:
# Create a haproxy.cfg file with your configuration:
# ```
# global
#   log /dev/log local0
#   log /dev/log local1 notice
#   chroot /var/lib/haproxy
#   stats socket /run/haproxy/admin.sock mode 660 level admin
#   stats timeout 30s
#   user haproxy
#   group haproxy
#   daemon
#
# defaults
#   log global
#   mode http
#   option httplog
#   option dontlognull
#   timeout connect 5000
#   timeout client 50000
#   timeout server 50000
#   errorfile 400 /etc/haproxy/errors/400.http
#   errorfile 403 /etc/haproxy/errors/403.http
#   errorfile 408 /etc/haproxy/errors/408.http
#   errorfile 500 /etc/haproxy/errors/500.http
#   errorfile 502 /etc/haproxy/errors/502.http
#   errorfile 503 /etc/haproxy/errors/503.http
#   errorfile 504 /etc/haproxy/errors/504.http
#
# frontend http_front
#   bind *:80
#   stats uri /haproxy?stats
#   default_backend http_back
#
# backend http_back
#   balance roundrobin
#   server server1 192.168.1.1:80 check
#   server server2 192.168.1.2:80 check
#
# listen stats
#   bind *:8404
#   stats enable
#   stats uri /stats
#   stats refresh 10s
#   stats admin if TRUE
# ```

# SSL/TLS Configuration:
# For SSL termination, add SSL certificates to /etc/ssl/haproxy/
# Configure frontend with SSL bindings in haproxy.cfg

# Monitoring:
# Enable stats page for monitoring HAProxy performance
# Integrate with Prometheus for metrics collection
# Set up log aggregation for troubleshooting
