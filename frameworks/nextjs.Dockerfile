# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Next
# Website: https://nextjs.org/
# Repository: https://github.com/vercel/next.js
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Next application with security hardening
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security
# · COMBINATION: Use standalone for complete Next applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: Next documentation and Docker security guidelines

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
    npm_config_cache=/tmp/.npm \
    NEXT_TELEMETRY_DISABLED=1

WORKDIR /app

# Copy dependency files first for optimal layer caching
COPY package*.json ./

# Install dependencies with security optimizations
RUN npm ci --no-audit --no-fund && \
    npm cache clean --force

COPY . .

# Build the Next.js application
RUN npm run build

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Optimized runtime environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS runtime

# Build arguments for runtime configuration
ARG NODE_ENV=production
ARG PORT=3000

# Environment variables for runtime
ENV NODE_ENV=${NODE_ENV} \
    PORT=${PORT} \
    npm_config_update_notifier=false \
    npm_config_cache=/tmp/.npm \
    NEXT_TELEMETRY_DISABLED=1

# Create non-root user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -S -u 1001 -G appgroup appuser

WORKDIR /app

# Copy built application from builder stage
COPY --from=builder --chown=appuser:appgroup /app/package*.json ./
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/.next ./.next
COPY --from=builder --chown=appuser:appgroup /app/public ./public
COPY --from=builder --chown=appuser:appgroup /app/next.config.* ./

# Set permissions
RUN mkdir -p /app/logs /app/tmp && \
    chown -R appuser:appgroup /app && \
    chmod -R 750 /app

# Switch to non-root user
USER appuser

EXPOSE ${PORT}

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:${PORT}', (r) => { \
    process.exit(r.statusCode === 200 ? 0 : 1); \
    }).on('error', () => process.exit(1))"

# Start Next application
STOPSIGNAL SIGTERM
CMD ["npm", "start"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT STAGE - Hot reload environment for local development
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS development

WORKDIR /app

COPY package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm ci --no-audit --no-fund

COPY . .

# Development command with hot reload
CMD ["npm", "run", "dev"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Build production image
# docker build --target runtime -t my-nextjs-app:prod .

# Example 2: Build development image
# docker build --target development -t my-nextjs-app:dev .

# Example 3: Build with custom arguments
# docker build \
#   --build-arg NODE_ENV=production \
#   --build-arg BUILD_ID=$(git rev-parse --short HEAD) \
#   --build-arg COMMIT_SHA=$(git rev-parse HEAD) \
#   -t my-nextjs-app:$(git rev-parse --short HEAD) .

# Example 4: Run production container
# docker run -d \
#   -p 3000:3000 \
#   --name nextjs-app \
#   --memory=512m \
#   --cpus=1.0 \
#   my-nextjs-app:prod

# Example 5: Run development container with volume mounting
# docker run -d \
#   -p 3000:3000 \
#   -v $(pwd):/app \
#   -v /app/node_modules \
#   --name nextjs-dev \
#   my-nextjs-app:dev

# Best Practices:
# 1. Always use .dockerignore to exclude node_modules, .git, etc.
# 2. Use specific Node.js versions (not 'latest')
# 3. Run health checks in production
# 4. Use multi-stage builds for smaller images
# 5. Set resource limits in docker-compose or Kubernetes
# 6. Use npm ci for deterministic builds
# 7. Disable telemetry in production
# 8. Clean package caches to reduce image size

# Customization Notes:
# 1. Adjust exposed ports based on your application
# 2. Modify health check endpoint as needed
# 3. Add environment variables for your Next application
# 4. Customize build commands for your Next setup
# 5. Consider adding standalone output for smaller images
# 6. Add custom entrypoint scripts if needed
# 7. Configure logging for production monitoring
