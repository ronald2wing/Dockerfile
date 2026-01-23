# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for Nginx
# Website: https://nginx.org/
# Repository: https://github.com/nginx/nginx
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Production-ready Nginx web server configuration
# · DESIGN PHILOSOPHY: Self-contained with security hardening and best practices
# · COMBINATION: Use standalone for Nginx web server containers
# · SECURITY: Non-root user, security headers, minimal configuration
# · BEST PRACTICES: Static file serving, reverse proxy, load balancing patterns
# · OFFICIAL SOURCES: Nginx documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM nginx:1.24-alpine

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG NGINX_VERSION=1.24
ARG BUILD_ID=unknown

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV NGINX_VERSION=${NGINX_VERSION} \
  BUILD_ID=${BUILD_ID} \
  NGINX_ENV=production \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CRITICAL: Security-hardened configuration for production web server

# Remove default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Create non-root user for Nginx
RUN addgroup -g 1001 -S nginxgroup && \
  adduser -S -D -H -u 1001 -h /var/cache/nginx -s /sbin/nologin -G nginxgroup -g nginx nginxuser

# Set proper permissions
RUN chown -R nginxuser:nginxgroup /var/cache/nginx && \
  chown -R nginxuser:nginxgroup /var/log/nginx && \
  chmod -R 755 /var/log/nginx

# Switch to non-root user
USER nginxuser

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CUSTOM CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/

# Set proper permissions for configuration files
RUN chmod 644 /etc/nginx/nginx.conf && \
  chmod 644 /etc/nginx/conf.d/*.conf

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STATIC CONTENT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create directory for static content
RUN mkdir -p /usr/share/nginx/html && \
  chown -R nginxuser:nginxgroup /usr/share/nginx/html && \
  chmod -R 755 /usr/share/nginx/html

# Copy static content (if any)
COPY html/ /usr/share/nginx/html/

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECK
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/health || exit 1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EXPOSE PORTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Declare persistent data volume
VOLUME /usr/share/nginx/html

# Expose HTTP and HTTPS ports
EXPOSE 80
EXPOSE 443

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Build Nginx image
# docker build -t my-nginx:1.24 .

# Example 2: Run Nginx for static content
# docker run -d \
#   --name nginx-server \
#   -p 80:80 \
#   -v $(pwd)/html:/usr/share/nginx/html \
#   my-nginx:1.24

# Example 3: Run as reverse proxy
# docker run -d \
#   --name nginx-proxy \
#   -p 80:80 \
#   -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf \
#   -v $(pwd)/conf.d:/etc/nginx/conf.d \
#   my-nginx:1.24

# Example 4: Run with SSL/TLS
# docker run -d \
#   --name nginx-ssl \
#   -p 80:80 \
#   -p 443:443 \
#   -v $(pwd)/ssl:/etc/nginx/ssl \
#   -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf \
#   my-nginx:1.24

# Example 5: Run with resource limits
# docker run -d \
#   --name nginx-server \
#   --memory=512m \
#   --cpus=1 \
#   -p 80:80 \
#   my-nginx:1.24

# Configuration Patterns:

# Pattern 1: Static file server
# server {
#   listen 80;
#   server_name example.com;
#   root /usr/share/nginx/html;
#   index index.html;
#
#   location / {
#     try_files $uri $uri/ =404;
#   }
# }

# Pattern 2: Reverse proxy
# server {
#   listen 80;
#   server_name api.example.com;
#
#   location / {
#     proxy_pass http://backend:3000;
#     proxy_set_header Host $host;
#     proxy_set_header X-Real-IP $remote_addr;
#   }
# }

# Pattern 3: Load balancer
# upstream backend {
#   server backend1:3000;
#   server backend2:3000;
#   server backend3:3000;
# }
#
# server {
#   listen 80;
#   server_name app.example.com;
#
#   location / {
#     proxy_pass http://backend;
#   }
# }

# Best Practices:
# 1. Always run as non-root user
# 2. Use specific Nginx versions (not 'latest')
# 3. Implement security headers (X-Frame-Options, CSP, etc.)
# 4. Enable gzip compression for text-based content
# 5. Set appropriate cache headers for static assets
# 6. Implement rate limiting for API endpoints
# 7. Use SSL/TLS for all production traffic
# 8. Regularly update Nginx to latest security patches

# Customization Notes:
# 1. Adjust worker_processes based on CPU cores
# 2. Modify worker_connections based on expected traffic
# 3. Add custom modules if needed
# 4. Configure logging format and rotation
# 5. Set up access and error log paths
# 6. Implement custom error pages

# Security Recommendations:
# 1. Disable server tokens (server_tokens off)
# 2. Implement security headers
# 3. Restrict HTTP methods to needed ones
# 4. Implement request size limits
# 5. Use secure SSL/TLS configurations
# 6. Implement IP-based access control
# 7. Regular security scanning of configuration
