# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for Varnish Cache
# Website: https://varnish-cache.org/
# Repository: https://github.com/varnishcache/varnish-cache
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Varnish HTTP accelerator and reverse proxy cache
# · DESIGN PHILOSOPHY: High-performance caching with security hardening
# · COMBINATION: Use as reverse proxy in front of web applications
# · SECURITY: Access control, request filtering, TLS termination
# · BEST PRACTICES: Cache tuning, purging strategies, monitoring
# · OFFICIAL SOURCES: Varnish documentation and Docker best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VARNISH CACHE CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM varnish:7.4-alpine

# Build arguments for configuration
ARG VARNISH_VERSION=7.4
ARG VARNISH_PORT=80
ARG VARNISH_BACKEND_PORT=8080
ARG VARNISH_BACKEND_HOST=backend
ARG VARNISH_MEMORY_SIZE=256m
ARG VARNISH_STORAGE_SIZE=1G
ARG VARNISH_TTL=120
ARG VARNISH_GRACE=10
ARG VARNISH_USER=varnish
ARG VARNISH_GROUP=varnish
ARG VARNISH_UID=1001
ARG VARNISH_GID=1001

# Environment variables for Varnish configuration
ENV VARNISH_VERSION=${VARNISH_VERSION} \
    VARNISH_PORT=${VARNISH_PORT} \
    VARNISH_BACKEND_PORT=${VARNISH_BACKEND_PORT} \
    VARNISH_BACKEND_HOST=${VARNISH_BACKEND_HOST} \
    VARNISH_MEMORY_SIZE=${VARNISH_MEMORY_SIZE} \
    VARNISH_STORAGE_SIZE=${VARNISH_STORAGE_SIZE} \
    VARNISH_TTL=${VARNISH_TTL} \
    VARNISH_GRACE=${VARNISH_GRACE} \
    VARNISH_USER=${VARNISH_USER} \
    VARNISH_GROUP=${VARNISH_GROUP} \
    VARNISH_UID=${VARNISH_UID} \
    VARNISH_GID=${VARNISH_GID}

# Create custom user and group if they don't exist
RUN if ! getent group ${VARNISH_GID} > /dev/null; then \
        groupadd -g ${VARNISH_GID} ${VARNISH_GROUP}; \
    fi && \
    if ! getent passwd ${VARNISH_UID} > /dev/null; then \
        useradd -u ${VARNISH_UID} -g ${VARNISH_GID} ${VARNISH_USER}; \
    fi

# Create directories with proper permissions
RUN mkdir -p /var/lib/varnish && \
    mkdir -p /var/log/varnish && \
    chown -R ${VARNISH_USER}:${VARNISH_GROUP} /var/lib/varnish && \
    chown -R ${VARNISH_USER}:${VARNISH_GROUP} /var/log/varnish && \
    chmod -R 750 /var/lib/varnish && \
    chmod -R 750 /var/log/varnish

# Copy custom VCL configuration
COPY <<'EOF' /etc/varnish/default.vcl
vcl 4.1;

# Default backend definition
backend default {
    .host = "${VARNISH_BACKEND_HOST}";
    .port = "${VARNISH_BACKEND_PORT}";
    .connect_timeout = 5s;
    .first_byte_timeout = 60s;
    .between_bytes_timeout = 60s;
    .max_connections = 1000;
}

# Access control list for purge operations
acl purge {
    "localhost";
    "127.0.0.1";
    "::1";
}

# Subroutine called at the beginning of a request
sub vcl_recv {
    # Allow purge requests only from authorized clients
    if (req.method == "PURGE") {
        if (!client.ip ~ purge) {
            return (synth(405, "Method not allowed"));
        }
        return (purge);
    }

    # Only cache GET and HEAD requests
    if (req.method != "GET" && req.method != "HEAD") {
        return (pass);
    }

    # Remove cookies for static assets to improve cache hit rate
    if (req.url ~ "\.(css|js|png|gif|jp(e?)g|ico|webp|svg|woff2?|ttf|eot)$") {
        unset req.http.Cookie;
    }

    # Normalize Accept-Encoding header
    if (req.http.Accept-Encoding) {
        if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
            # No point in compressing these
            unset req.http.Accept-Encoding;
        } elsif (req.http.Accept-Encoding ~ "gzip") {
            set req.http.Accept-Encoding = "gzip";
        } elsif (req.http.Accept-Encoding ~ "deflate") {
            set req.http.Accept-Encoding = "deflate";
        } else {
            unset req.http.Accept-Encoding;
        }
    }

    # Remove tracking and analytics cookies
    if (req.http.Cookie) {
        set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(__[a-z]+|_ga|_gat|utm[a-z]+|gclid|fbclid)=", "; \1");
        set req.http.Cookie = regsuball(req.http.Cookie, "^;+", "");

        if (req.http.Cookie == "") {
            unset req.http.Cookie;
        }
    }

    return (hash);
}

# Subroutine called after an object has been retrieved from the backend
sub vcl_backend_response {
    # Set default TTL
    set beresp.ttl = ${VARNISH_TTL}s;
    set beresp.grace = ${VARNISH_GRACE}s;

    # Cache static assets for longer
    if (bereq.url ~ "\.(css|js|png|gif|jp(e?)g|ico|webp|svg|woff2?|ttf|eot)$") {
        set beresp.ttl = 1w;
        unset beresp.http.Set-Cookie;
    }

    # Don't cache responses with Set-Cookie header
    if (beresp.http.Set-Cookie) {
        set beresp.uncacheable = true;
        set beresp.ttl = 120s;
        return (deliver);
    }

    # Don't cache error responses
    if (beresp.status >= 400) {
        set beresp.uncacheable = true;
        set beresp.ttl = 120s;
        return (deliver);
    }

    # Enable ESI (Edge Side Includes) processing
    if (beresp.http.Surrogate-Control ~ "ESI/1.0") {
        unset beresp.http.Surrogate-Control;
        set beresp.do_esi = true;
    }

    return (deliver);
}

# Subroutine called before delivering the object to the client
sub vcl_deliver {
    # Add cache hit/miss header for debugging
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
        set resp.http.X-Cache-Hits = obj.hits;
    } else {
        set resp.http.X-Cache = "MISS";
    }

    # Add security headers
    set resp.http.X-Content-Type-Options = "nosniff";
    set resp.http.X-Frame-Options = "SAMEORIGIN";
    set resp.http.X-XSS-Protection = "1; mode=block";
    set resp.http.Referrer-Policy = "strict-origin-when-cross-origin";

    # Remove internal headers
    unset resp.http.Via;
    unset resp.http.X-Varnish;
    unset resp.http.Server;

    return (deliver);
}

# Subroutine called when there's a cache miss
sub vcl_miss {
    return (fetch);
}

# Subroutine called when there's a cache hit
sub vcl_hit {
    if (obj.ttl >= 0s) {
        return (deliver);
    }

    if (obj.ttl + obj.grace > 0s) {
        return (deliver);
    }

    return (fetch);
}

# Subroutine called for synthetic responses
sub vcl_synth {
    set resp.http.Content-Type = "text/html; charset=utf-8";
    set resp.http.Retry-After = "5";

    synthetic( {"<!DOCTYPE html>
<html>
  <head>
    <title>"} + resp.status + " " + resp.reason + {"</title>
  </head>
  <body>
    <h1>Error "} + resp.status + " " + resp.reason + {"</h1>
    <p>"} + resp.reason + {"</p>
    <hr>
    <p>Varnish cache server</p>
  </body>
</html>
"} );

    return (deliver);
}
EOF

# Copy startup script with configuration
COPY <<'EOF' /docker-entrypoint.sh
#!/bin/sh
set -e

# Set Varnish configuration
export VARNISH_STORAGE="malloc,${VARNISH_MEMORY_SIZE}"
export VARNISH_LISTEN=":${VARNISH_PORT}"

# Start Varnish
exec varnishd \
    -F \
    -a ${VARNISH_LISTEN} \
    -f /etc/varnish/default.vcl \
    -s malloc,${VARNISH_MEMORY_SIZE} \
    -p http_resp_hdr_len=8192 \
    -p http_resp_size=98304 \
    -p workspace_backend=64k \
    -p workspace_client=64k \
    -p vcc_allow_inline_c=on
EOF

# Make startup script executable
RUN chmod +x /docker-entrypoint.sh

# Declare persistent data volume
VOLUME /var/lib/varnish

# Switch to non-root user
USER ${VARNISH_USER}

# Expose Varnish port
EXPOSE ${VARNISH_PORT}

# Health check for Varnish
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD varnishadm backend.list | grep -q "Healthy" || exit 1

# Start Varnish
CMD ["/docker-entrypoint.sh"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build Varnish image
# docker build -t my-varnish:7.4 .

# Example 2: Run Varnish as reverse proxy for backend application
# docker run -d \
#   --name varnish-cache \
#   -p 80:80 \
#   -e VARNISH_BACKEND_HOST=backend-app \
#   -e VARNISH_BACKEND_PORT=8080 \
#   my-varnish:7.4

# Example 3: Run with custom memory allocation
# docker run -d \
#   --name varnish-large \
#   -p 80:80 \
#   -e VARNISH_MEMORY_SIZE=512m \
#   -e VARNISH_BACKEND_HOST=backend \
#   my-varnish:7.4

# Example 4: Run with Docker Compose
# docker-compose up -d

# Example 5: Run with custom VCL configuration
# docker run -d \
#   --name varnish-custom \
#   -p 80:80 \
#   -v ./custom.vcl:/etc/varnish/default.vcl \
#   my-varnish:7.4

# Example 6: Run with resource limits
# docker run -d \
#   --name varnish-prod \
#   -p 80:80 \
#   --memory=1g \
#   --cpus=2 \
#   -e VARNISH_MEMORY_SIZE=512m \
#   my-varnish:7.4

# Example 7: Run with health check verification
# docker run -d \
#   --name varnish-monitored \
#   -p 80:80 \
#   --health-cmd="varnishadm backend.list | grep -q 'Healthy' || exit 1" \
#   my-varnish:7.4

# Example 8: Run with TLS termination (using external proxy)
# docker run -d \
#   --name varnish-tls \
#   -p 443:443 \
#   -e VARNISH_PORT=443 \
#   -v ./ssl:/etc/ssl \
#   my-varnish:7.4

# BEST PRACTICES
# ==============

# Security Best Practices:
# • Restrict purge operations to authorized IP addresses only
# • Implement request filtering to block malicious traffic
# • Use TLS termination for secure connections
# • Regularly update Varnish and Alpine dependencies
# • Monitor access logs for suspicious activity
# • Implement rate limiting for API endpoints
# • Use secure headers for web application protection
# • Restrict backend access to trusted networks

# Performance Optimization:
# • Adjust VARNISH_MEMORY_SIZE based on available RAM
# • Tune TTL and grace periods for your specific workload
# • Implement proper cache invalidation strategies
# • Use edge-side includes (ESI) for dynamic content caching
# • Monitor cache hit rates and adjust configuration accordingly
# • Implement compression for text-based content
# • Use persistent storage for large cache objects
# • Optimize VCL configuration for your application patterns

# Operations & Maintenance:
# • Use specific version tags for Varnish images (avoid 'latest')
# • Implement proper logging and log rotation
# • Monitor backend health and implement failover strategies
# • Use health checks for container orchestration
# • Implement automated cache warming after deployments
# • Set up monitoring for cache performance metrics
# • Regularly review and optimize VCL configuration
# • Implement backup strategies for critical configurations

# Varnish-Specific Considerations:
# • Configure appropriate TTL values for different content types
# • Implement proper cache purging mechanisms
# • Use Varnish Administration Console (varnishadm) for management
# • Monitor backend response times and implement timeouts
# • Use Varnish Custom Statistics (varnishstat) for monitoring
# • Implement request coalescing for high-traffic endpoints
# • Configure appropriate workspace sizes for your workload
# • Use Varnish's built-in load balancing capabilities

# Cache Strategy:
# • Implement different caching strategies for static vs dynamic content
# • Use cache variations for user-specific content
# • Implement cache warming for critical pages
# • Monitor cache efficiency and adjust strategies
# • Use cache tags for granular invalidation
# • Implement stale-while-revalidate patterns
# • Configure appropriate cache headers for CDN integration
# • Monitor cache memory usage and fragmentation

# Development & Testing:
# • Use Docker Compose for local development environments
# • Implement integration tests with backend applications
# • Test cache invalidation strategies thoroughly
# • Use Varnish's test tools for configuration validation
# • Set up development environments with realistic traffic patterns
# • Monitor cache behavior during development
# • Implement proper error handling in VCL
# • Test performance under load with different configurations
