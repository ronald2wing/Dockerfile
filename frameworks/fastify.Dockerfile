# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Fastify
# Website: https://www.fastify.io/
# Repository: https://github.com/fastify/fastify
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Fastify application with high performance
# · DESIGN PHILOSOPHY: Minimal overhead with security hardening and optimization
# · COMBINATION: Use standalone for complete Fastify applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: Fastify documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Application compilation and optimization
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS builder

# Build arguments for environment configuration
ARG NODE_ENV=production
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG NODE_VERSION=18

# Environment variables for build process
ENV NODE_ENV=${NODE_ENV} \
    BUILD_ID=${BUILD_ID} \
    COMMIT_SHA=${COMMIT_SHA} \
    NODE_VERSION=${NODE_VERSION} \
    npm_config_update_notifier=false \
    npm_config_cache=/tmp/.npm

WORKDIR /app

# Copy dependency files first for optimal layer caching
COPY package*.json ./

# Install production dependencies only with security optimizations
RUN npm ci --omit=dev --no-audit --no-fund && \
    npm cache clean --force

COPY src/ ./src/
COPY *.js ./
COPY *.json ./

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Optimized runtime environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS runtime

# Build arguments for runtime configuration
ARG NODE_ENV=production
ARG PORT=3000
ARG APP_VERSION=1.0.0
ARG HOST=0.0.0.0

# Environment variables for runtime
ENV NODE_ENV=${NODE_ENV} \
    PORT=${PORT} \
    APP_VERSION=${APP_VERSION} \
    HOST=${HOST} \
    npm_config_update_notifier=false \
    npm_config_cache=/tmp/.npm

# Create non-root user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -S -u 1001 -G appgroup appuser

WORKDIR /app

# Copy built application from builder stage
COPY --from=builder --chown=appuser:appgroup /app ./

# Set permissions
RUN chown -R appuser:appgroup /app && \
    chmod -R 750 /app

# Switch to non-root user
USER appuser

EXPOSE ${PORT}

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:${PORT}/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Start the application
STOPSIGNAL SIGTERM
CMD ["node", "src/server.js"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT STAGE - Hot reload and debugging support
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS development

# Environment variables for development
ENV NODE_ENV=development \
    PORT=3000 \
    HOST=0.0.0.0 \
    npm_config_update_notifier=false

WORKDIR /app

COPY package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm ci --no-audit --no-fund && \
    npm cache clean --force

COPY src/ ./src/
COPY *.js ./
COPY *.json ./

EXPOSE ${PORT}

# Start development server with hot reload
CMD ["npm", "run", "dev"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Basic Usage:
#   docker build --target production -t fastify-app .
#   docker run -p 3000:3000 fastify-app
#
# Development with Hot Reload:
#   docker build --target development -t fastify-dev .
#   docker run -p 3000:3000 -v $(pwd):/app fastify-dev
#
# With Redis Cache:
#   cat frameworks/fastify.Dockerfile tools/redis.Dockerfile > Dockerfile
#   docker build -t fastify-with-redis .
#
# With PostgreSQL Database:
#   cat frameworks/fastify.Dockerfile tools/postgresql.Dockerfile > Dockerfile
#   docker build -t fastify-with-db .
#
# Performance Optimization:
#   cat frameworks/fastify.Dockerfile patterns/alpine.Dockerfile > Dockerfile
#   docker build -t fastify-optimized .
#
# Best Practices:
# 1. Always use .dockerignore to exclude node_modules, .git, etc.
# 2. Use specific version tags for base images (not 'latest')
# 3. Run health checks in production
# 4. Use multi-stage builds for smaller images
# 5. Set resource limits in docker-compose or Kubernetes
# 6. Run as non-root user in production
# 7. Regularly update dependencies and base images
#
# Security Recommendations:
# 1. Scan images for vulnerabilities regularly
# 2. Use minimal base images (Alpine recommended when available)
# 3. Implement security headers and configurations
# 4. Follow principle of least privilege
# 5. Monitor logs for security events
