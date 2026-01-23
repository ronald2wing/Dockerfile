# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for React
# Website: https://reactjs.org/
# Repository: https://github.com/facebook/react
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready React application with security hardening
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security
# · COMBINATION: Use standalone for complete React applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: React documentation and Docker security guidelines

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

# Build React application
RUN npm run build --if-present

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Production deployment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS runtime

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S -u 1001 -G appgroup appuser

# Production environment configuration
ENV NODE_ENV=production \
  npm_config_update_notifier=false \
  UMASK=0027

WORKDIR /app

# Copy built artifacts from builder stage with proper ownership
COPY --from=builder --chown=appuser:appgroup /app/package*.json ./
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/build ./build
COPY --from=builder --chown=appuser:appgroup /app/public ./public

# Create directories with secure permissions
RUN mkdir -p /app/logs /app/tmp && \
  chown -R appuser:appgroup /app/logs /app/tmp && \
  chmod 750 /app/logs /app/tmp

# Switch to non-root user
USER appuser

EXPOSE 3000

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (r) => { \
  process.exit(r.statusCode === 200 ? 0 : 1); \
  }).on('error', () => process.exit(1))"

# Serve static build with npx serve
STOPSIGNAL SIGTERM
ENTRYPOINT ["npx", "serve", "-s", "build"]
CMD ["-l", "3000"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT STAGE - Hot reload environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS development

WORKDIR /app

COPY package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm ci

COPY . .

# Development command with hot reload
CMD ["npm", "start"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Build production image
# docker build --target runtime -t my-react-app:prod .

# Example 2: Build development image
# docker build --target development -t my-react-app:dev .

# Example 3: Build with custom arguments
# docker build \
#   --build-arg NODE_ENV=production \
#   --build-arg BUILD_ID=$(git rev-parse --short HEAD) \
#   -t my-react-app:$(git rev-parse --short HEAD) .

# Example 4: Run production container
# docker run -d -p 3000:3000 --name react-app my-react-app:prod

# Example 5: Run development container
# docker run -d -p 3000:3000 -v $(pwd):/app --name react-dev my-react-app:dev

# Best Practices:
# 1. Always use .dockerignore to exclude node_modules, .git, etc.
# 2. Use specific Node.js versions (not 'latest')
# 3. Run health checks in production
# 4. Use multi-stage builds for smaller images
# 5. Set resource limits in docker-compose or Kubernetes

# Customization Notes:
# 1. Replace 'serve' with your preferred static file server
# 2. Adjust exposed ports based on your application
# 3. Modify health check endpoint as needed
# 4. Add environment variables for your application
# 5. Customize build commands for your React setup
