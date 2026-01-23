# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Solid
# Website: https://www.solidjs.com/
# Repository: https://github.com/solidjs/solid
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Solid application with reactive programming model
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security hardening
# · COMBINATION: Use standalone for complete Solid applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: Solid documentation and Docker security guidelines

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

# Build SolidJS application
RUN npm run build

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PRODUCTION STAGE - Runtime environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS runtime

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
  adduser -S nodejs -u 1001

WORKDIR /app

# Copy built application from builder stage
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Switch to non-root user
USER nodejs

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (r) => r.statusCode === 200 ? process.exit(0) : process.exit(1))"

EXPOSE 3000

# Start application
STOPSIGNAL SIGTERM
CMD ["npm", "start"]

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

EXPOSE 3000

# Start development server with hot reload
CMD ["npm", "run", "dev"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES
# ==============
# 1. Build production image:
#    docker build --target production -t solidjs-app .
#
# 2. Build development image:
#    docker build --target development -t solidjs-app-dev .
#
# 3. Run production container:
#    docker run -p 3000:3000 solidjs-app
#
# 4. Run development container with hot reload:
#    docker run -p 3000:3000 -v $(pwd):/app solidjs-app-dev
#
# 5. Build with custom build arguments:
#    docker build --target production --build-arg BUILD_ID=1.0.0 -t solidjs-app .
#
# 6. Multi-stage build for CI/CD:
#    docker build --target builder --build-arg NODE_ENV=production .
#
# 7. Health check verification:
#    docker run -d --name solidjs-test -p 3000:3000 solidjs-app
#    docker inspect --format='{{.State.Health.Status}}' solidjs-test
#
# 8. Resource limits for production:
#    docker run -p 3000:3000 --memory=512m --cpus=1 solidjs-app

# BEST PRACTICES
# ==============
# Security:
# • Always run as non-root user (nodejs user created in template)
# • Use specific Node.js version (node:18-alpine) not 'latest'
# • Regularly update base images for security patches
# • Scan images for vulnerabilities: docker scan solidjs-app

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
# • Test with different SolidJS versions
# • Update template with new SolidJS features

# Combination Patterns:
# • Combine with patterns/security-hardened.Dockerfile for enhanced security
# • Combine with patterns/alpine.Dockerfile for further size optimization
# • Combine with tools/nginx.Dockerfile for reverse proxy configuration
# • Combine with patterns/monitoring.Dockerfile for observability

# SolidJS-Specific Considerations:
# • SolidJS uses fine-grained reactivity - optimize build for production
# • SSR (Server-Side Rendering) support available in SolidStart
# • Bundle size optimization critical for performance
# • Consider SolidStart for full-stack applications
