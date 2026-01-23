# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Qwik
# Website: https://qwik.builder.io/
# Repository: https://github.com/BuilderIO/qwik
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Qwik application with resumable architecture
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security hardening
# · COMBINATION: Use standalone for complete Qwik applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: Qwik documentation and Docker security guidelines

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

# Build Qwik application
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

# Start Qwik application
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
#    docker build --target production -t qwik-app .
#
# 2. Build development image:
#    docker build --target development -t qwik-app-dev .
#
# 3. Run production container:
#    docker run -p 3000:3000 qwik-app
#
# 4. Run development container with hot reload:
#    docker run -p 3000:3000 -v $(pwd):/app qwik-app-dev
#
# 5. Build with custom build arguments:
#    docker build --target production --build-arg BUILD_ID=1.0.0 -t qwik-app .
#
# 6. Multi-stage build for CI/CD:
#    docker build --target builder --build-arg NODE_ENV=production .
#
# 7. Health check verification:
#    docker run -d --name qwik-test -p 3000:3000 qwik-app
#    docker inspect --format='{{.State.Health.Status}}' qwik-test
#
# 8. Resource limits for production:
#    docker run -p 3000:3000 --memory=512m --cpus=1 qwik-app

# BEST PRACTICES
# ==============
# Security:
# • Always run as non-root user (nodejs user created in template)
# • Use specific Node.js version (node:18-alpine) not 'latest'
# • Regularly update base images for security patches
# • Scan images for vulnerabilities: docker scan qwik-app

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
# • Test with different Qwik versions
# • Update template with new Qwik features

# Combination Patterns:
# • Combine with patterns/security-hardened.Dockerfile for enhanced security
# • Combine with patterns/alpine.Dockerfile for further size optimization
# • Combine with tools/nginx.Dockerfile for reverse proxy configuration
# • Combine with patterns/monitoring.Dockerfile for observability

# Qwik-Specific Considerations:
# • Qwik uses resumable architecture - optimize for server-side rendering
# • Fine-grained lazy loading requires proper build configuration
# • Bundle size optimization critical for performance
# • Consider Qwik City for full-stack applications with routing
# • Optimize for edge deployments with serverless adapters
