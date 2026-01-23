# ==============================================================================
# Created by https://Dockerfile.io/
# Pattern TEMPLATE for Alpine Linux
# Website: https://alpinelinux.org/
# Repository: https://github.com/alpinelinux
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Pattern
# · PURPOSE: Alpine Linux optimizations and configurations
# · DESIGN PHILOSOPHY: Minimal, secure, and efficient Alpine patterns
# · COMBINATION: Combine with language or framework templates
# · SECURITY: Minimal attack surface, musl libc compatibility
# · BEST PRACTICES: Package management, size optimization, security hardening
# · OFFICIAL SOURCES: Alpine Linux documentation and Docker best practices
#
# IMPORTANT: Alpine Linux is designed for minimal size and security.
# Test compatibility with your application's libc requirements.

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Official Alpine base image (specific version recommended)
FROM alpine:3.19

# Alternative: Version-pinned with SHA for reproducibility
# FROM alpine:3.19@sha256:abc123...

# Alternative: Edge (rolling) release for latest features
# FROM alpine:edge

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SYSTEM CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Set timezone (optional)
RUN apk add --no-cache tzdata && \
  cp /usr/share/zoneinfo/UTC /etc/localtime && \
  echo "UTC" > /etc/timezone && \
  apk del tzdata

ENV LANG=C.UTF-8 \
  LC_ALL=C.UTF-8

RUN addgroup -g 1001 -S appgroup && \
  adduser -S -u 1001 -G appgroup appuser

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PACKAGE MANAGEMENT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache \
  # System utilities
  ca-certificates \
  curl \
  wget \
  bash \
  # Security tools
  openssl \
  # Monitoring tools
  htop \
  iftop \
  # Debugging tools (development only)
  # strace \
  # lsof \
  # Network tools
  iputils \
  net-tools

RUN apk add --no-cache --virtual .build-deps \
  gcc \
  g++ \
  make \
  cmake \
  autoconf \
  automake \
  libtool \
  pkgconfig \
  linux-headers

# Clean build dependencies after build
# RUN apk del .build-deps

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RUN update-ca-certificates

# Set secure permissions
RUN chmod -R 755 /etc/ssl/certs && \
  chown -R root:root /etc/ssl/certs

# Create secure directories
RUN mkdir -p /app && \
  chown -R appuser:appgroup /app && \
  chmod 750 /app

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME OPTIMIZATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Set working directory
WORKDIR /app

# Switch to non-root user
USER appuser

# Set secure umask
ENV UMASK=0027

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LANGUAGE RUNTIMES (OPTIONAL)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Node.js on Alpine
# RUN apk add --no-cache nodejs npm

# Python on Alpine
# RUN apk add --no-cache python3 py3-pip

# Go on Alpine
# RUN apk add --no-cache go

# Java on Alpine
# RUN apk add --no-cache openjdk17-jre

# Ruby on Alpine
# RUN apk add --no-cache ruby

# PHP on Alpine
# RUN apk add --no-cache php php-fpm php-common php-json

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# WEB SERVER CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Nginx on Alpine
# RUN apk add --no-cache nginx
# COPY nginx.conf /etc/nginx/nginx.conf
# EXPOSE 80 443

# Apache on Alpine
# RUN apk add --no-cache apache2
# COPY httpd.conf /etc/apache2/httpd.conf
# EXPOSE 80 443

# Caddy on Alpine
# RUN apk add --no-cache caddy
# COPY Caddyfile /etc/caddy/Caddyfile
# EXPOSE 80 443

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DATABASE CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# PostgreSQL on Alpine
# RUN apk add --no-cache postgresql15
# RUN mkdir -p /var/lib/postgresql/data
# RUN chown -R postgres:postgres /var/lib/postgresql/data
# USER postgres
# EXPOSE 5432

# MySQL/MariaDB on Alpine
# RUN apk add --no-cache mariadb mariadb-client
# RUN mkdir -p /var/lib/mysql
# RUN chown -R mysql:mysql /var/lib/mysql
# USER mysql
# EXPOSE 3306

# Redis on Alpine
# RUN apk add --no-cache redis
# USER redis
# EXPOSE 6379

# MongoDB on Alpine
# RUN apk add --no-cache mongodb
# RUN mkdir -p /data/db
# RUN chown -R mongodb:mongodb /data/db
# USER mongodb
# EXPOSE 27017

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONTAINER RUNTIME
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# Default command (override in child images)
CMD ["/bin/sh"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Combine with language template
# cat languages/node.Dockerfile \
#     patterns/alpine.Dockerfile > Dockerfile

# Example 2: Complete production setup
# cat languages/python.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/alpine.Dockerfile \
#     patterns/security-hardened.Dockerfile > Dockerfile

# Example 3: With framework template
# cat frameworks/react.Dockerfile \
#     patterns/alpine.Dockerfile \
#     patterns/security-hardened.Dockerfile > Dockerfile

# Example 4: Multiple pattern combination
# cat languages/java.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/alpine.Dockerfile \
#     patterns/ci-cd.Dockerfile > Dockerfile

# Example 5: Development environment
# cat languages/node.Dockerfile \
#     patterns/alpine.Dockerfile \
#     patterns/development.Dockerfile > Dockerfile

# Example 6: CI/CD pipeline integration
# cat languages/go.Dockerfile \
#     patterns/alpine.Dockerfile \
#     patterns/ci-cd.Dockerfile > Dockerfile

# Example 7: With monitoring
# cat languages/ruby.Dockerfile \
#     patterns/alpine.Dockerfile \
#     patterns/monitoring.Dockerfile > Dockerfile

# BEST PRACTICES
# ==============

# 1. Alpine Pattern Best Practices:
#    • This pattern is designed to be combined with other templates
#    • Always test pattern combinations before production deployment
#    • Follow Alpine-specific implementation guidelines
#    • Consider performance implications of Alpine usage
#    • Document Alpine usage in your project documentation
#    • Review Alpine compatibility with other patterns
#    • Monitor Alpine effectiveness in production
#    • Update Alpine patterns based on new best practices

# 2. Security Considerations:
#    • Alpine Linux provides a smaller attack surface
#    • Always combine with security-hardened.Dockerfile for production
#    • Review Alpine-specific security implications
#    • Test security configurations in staging environments
#    • Monitor for security vulnerabilities related to Alpine usage
#    • Follow security best practices for Alpine implementation
#    • Consider compliance requirements when using Alpine

# 3. Performance Optimization:
#    • Alpine provides smaller image sizes
#    • Consider performance impact of Alpine implementation
#    • Test Alpine performance under load
#    • Optimize Alpine configuration for your use case
#    • Monitor performance metrics related to Alpine usage
#    • Review Alpine efficiency and resource usage
#    • Consider alternative base images for specific use cases

# 4. Development Workflow:
#    • Test Alpine combinations during development
#    • Document Alpine usage in development environment
#    • Use Alpine-specific development tools when available
#    • Implement Alpine testing in CI/CD pipeline
#    • Review Alpine documentation and examples
#    • Follow Alpine implementation guidelines

# 5. Combination Patterns:
#    • This pattern is designed to work with language and framework templates
#    • Combine with other patterns for complete solutions
#    • Test Alpine compatibility before production use
#    • Document Alpine combinations in your project
#    • Review Alpine interaction with other patterns
#    • Consider pattern sequencing and order of combination
