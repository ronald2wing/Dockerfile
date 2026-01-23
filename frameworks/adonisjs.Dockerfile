# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for AdonisJS
# Website: https://adonisjs.com/
# Repository: https://github.com/adonisjs/core
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready AdonisJS application with full-stack capabilities
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security hardening
# · COMBINATION: Use standalone for complete AdonisJS applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: AdonisJS documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Application compilation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS builder

# Build arguments for environment configuration
ARG NODE_ENV=production
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown

# Environment variables for build process
ENV NODE_ENV=${NODE_ENV} \
  BUILD_ID=${BUILD_ID} \
  COMMIT_SHA=${COMMIT_SHA} \
  npm_config_update_notifier=false \
  npm_config_cache=/tmp/.npm

WORKDIR /app

# Copy dependency files first for optimal layer caching
COPY package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev && \
  npm cache clean --force

COPY . .

# Build AdonisJS application (if TypeScript compilation needed)
RUN if [ -f "tsconfig.json" ]; then npm run build; fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Runtime environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS runtime

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
  adduser -S nodejs -u 1001

WORKDIR /app

# Copy built application from builder stage
COPY --from=builder --chown=nodejs:nodejs /app ./

# Switch to non-root user
USER nodejs

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3333', (r) => r.statusCode === 200 ? process.exit(0) : process.exit(1))"

EXPOSE 3333

# Start AdonisJS application
STOPSIGNAL SIGTERM
CMD ["node", "ace", "serve"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT STAGE - Hot reload and debugging
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS development

# Build arguments for development
ARG NODE_ENV=development

# Environment variables for development
ENV NODE_ENV=${NODE_ENV} \
  npm_config_update_notifier=false \
  npm_config_cache=/tmp/.npm

WORKDIR /app

COPY package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm ci && \
  npm cache clean --force

COPY . .

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
  adduser -S nodejs -u 1001

# Switch to non-root user
USER nodejs

EXPOSE 3333

# Start development server with hot reload
CMD ["node", "ace", "serve", "--watch"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES
# ==============
# 1. Build production image:
#    docker build --target production -t adonisjs-app .
#
# 2. Build development image:
#    docker build --target development -t adonisjs-app-dev .
#
# 3. Run production container:
#    docker run -p 3333:3333 adonisjs-app
#
# 4. Run development container with hot reload:
#    docker run -p 3333:3333 -v $(pwd):/app adonisjs-app-dev
#
# 5. Build with custom build arguments:
#    docker build --target production --build-arg BUILD_ID=1.0.0 -t adonisjs-app .
#
# 6. Multi-stage build for CI/CD:
#    docker build --target builder --build-arg NODE_ENV=production .
#
# 7. Health check verification:
#    docker run -d --name adonisjs-test -p 3333:3333 adonisjs-app
#    docker inspect --format='{{.State.Health.Status}}' adonisjs-test
#
# 8. Resource limits for production:
#    docker run -p 3333:3333 --memory=512m --cpus=1 adonisjs-app

# BEST PRACTICES
# ==============
# Security:
# • Always run as non-root user (nodejs user created in template)
# • Use specific Node.js version (node:18-alpine) not 'latest'
# • Regularly update base images for security patches
# • Scan images for vulnerabilities: docker scan adonisjs-app

# Performance:
# • Multi-stage builds reduce final image size
# • Layer caching optimized with package.json copy first
# • Alpine Linux base image for minimal footprint
# • Production dependencies only in final stage

# Development:
# • Use development stage for local development with hot reload
# • Mount source code as volume for live updates
# • Development stage includes all dependencies for testing
# • Separate build arguments for development vs production

# Operations:
# • Health checks enable proper container orchestration
# • Resource limits prevent memory exhaustion
# • Logging configured for production monitoring
# • Environment-specific configurations via build args

# Maintenance:
# • Regular dependency updates with security scanning
# • Monitor Node.js version compatibility
# • Test with different AdonisJS versions
# • Update template with new AdonisJS features

# Combination Patterns:
# • Combine with patterns/security-hardened.Dockerfile for enhanced security
# • Combine with patterns/alpine.Dockerfile for further size optimization
# • Combine with tools/nginx.Dockerfile for reverse proxy configuration
# • Combine with patterns/monitoring.Dockerfile for observability
# • Combine with tools/postgresql.Dockerfile for database integration

# AdonisJS-Specific Considerations:
# • AdonisJS is a full-stack framework with built-in ORM (Lucid)
# • Supports multiple database drivers (PostgreSQL, MySQL, SQLite)
# • Includes authentication, validation, and authorization out of the box
# • TypeScript-first framework with excellent type safety
# • Consider using AdonisJS with Docker Compose for multi-service setups
