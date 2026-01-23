# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Koa
# Website: https://koajs.com/
# Repository: https://github.com/koajs/koa
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Koa application with modern async/await patterns
# · DESIGN PHILOSOPHY: Minimal middleware framework for Node.js, ES2017 async functions
# · COMBINATION: Use standalone for complete Koa applications
# · SECURITY: Non-root user, Alpine base, dependency auditing
# · BEST PRACTICES: Async middleware chains, proper error handling, logging
# · OFFICIAL SOURCES: Koa documentation and Node.js security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Application compilation and dependency installation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS builder

# Build arguments for environment configuration
ARG NODE_ENV=production
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG NPM_CONFIG_LOGLEVEL=warn
ARG NPM_CONFIG_AUDIT=false
ARG NPM_CONFIG_FUND=false

# Environment variables for build process
ENV NODE_ENV=${NODE_ENV} \
    BUILD_ID=${BUILD_ID} \
    COMMIT_SHA=${COMMIT_SHA} \
    NPM_CONFIG_LOGLEVEL=${NPM_CONFIG_LOGLEVEL} \
    NPM_CONFIG_AUDIT=${NPM_CONFIG_AUDIT} \
    NPM_CONFIG_FUND=${NPM_CONFIG_FUND} \
    npm_config_update_notifier=false \
    npm_config_cache=/tmp/.npm

WORKDIR /app

# Copy dependency files first for optimal layer caching
COPY package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev --silent && \
    npm cache clean --force

COPY . .

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT STAGE - Optional development dependencies
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM builder AS development

# Install development dependencies
RUN npm ci --silent

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Minimal production image
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS runtime

# Security configuration
ARG APP_USER=appuser
ARG APP_GROUP=appgroup
ARG APP_UID=1001
ARG APP_GID=1001

# Create non-root user and group
RUN addgroup -g ${APP_GID} -S ${APP_GROUP} && \
    adduser -S -u ${APP_UID} -G ${APP_GROUP} ${APP_USER}

WORKDIR /app

# Copy application files from builder stage
COPY --from=builder --chown=${APP_USER}:${APP_GROUP} /app /app

# Set permissions
RUN chown -R ${APP_USER}:${APP_GROUP} /app && \
    chmod -R 750 /app

# Switch to non-root user
USER ${APP_USER}

EXPOSE 3000

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => { process.exit(r.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

# Application entrypoint
STOPSIGNAL SIGTERM
ENTRYPOINT ["node"]

# Default command (can be overridden)
CMD ["src/index.js"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build production image
# docker build --target runtime -t koa-app:prod .

# Example 2: Build development image
# docker build --target development -t koa-app:dev .

# Example 3: Build with custom arguments
# docker build \
#   --build-arg BUILD_ID=v1.0.0 \
#   --build-arg COMMIT_SHA=$(git rev-parse HEAD) \
#   -t koa-app:$(git rev-parse --short HEAD) .

# Example 4: Run production container
# docker run -d -p 3000:3000 --name koa-app koa-app:prod

# Example 5: Run development container
# docker run -d -p 3000:3000 -v $(pwd):/app --name koa-app-dev koa-app:dev

# Example 6: Run with environment variables
# docker run -d \
#   -p 3000:3000 \
#   -e NODE_ENV=production \
#   -e DATABASE_URL=postgresql://user:pass@db:5432/db \
#   --name koa-app \
#   koa-app:prod

# Example 7: Docker Compose deployment
# docker-compose up -d

# Example 8: Kubernetes deployment
# kubectl apply -f deployment.yaml

# BEST PRACTICES
# ==============

# 1. Always use .dockerignore to exclude node_modules, .git, etc.
# 2. Use specific Node.js versions (not 'latest' tags)
# 3. Run health checks in production for container orchestration
# 4. Use multi-stage builds for smaller production images
# 5. Set resource limits in docker-compose or Kubernetes
# 6. Run as non-root user in production for security
# 7. Use environment variables for configuration
# 8. Implement proper logging and monitoring

# Koa Framework Features:
# • Async/await middleware support
# • Context-based request/response handling
# • Lightweight core with extensible middleware
# • Error handling with try/catch

# Recommended Middleware:
# • @koa/router: Router middleware
# • koa-bodyparser: Request body parsing
# • koa-helmet: Security headers
# • koa-compress: Response compression
# • koa-logger: Request logging
# • koa-cors: CORS support

# Security Considerations:
# • Always use non-root users in production stages
# • Scan images for vulnerabilities regularly
# • Keep dependencies updated with security patches
# • Use secrets management for sensitive data
# • Implement proper authentication and authorization

# Performance Optimization:
# • Optimize layer caching by ordering instructions properly
# • Combine RUN commands to reduce layer count
# • Clean package manager caches in the same RUN command
# • Use Alpine base images for smaller size
# • Implement connection pooling and caching

# Customization Notes:
# 1. Replace 'src/index.js' with your actual entry point
# 2. Adjust exposed ports based on your application
# 3. Modify health check endpoints as needed
# 4. Add environment variables specific to your application
# 5. Customize build commands for your Koa setup
