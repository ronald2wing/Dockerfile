# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Nest
# Website: https://nestjs.com/
# Repository: https://github.com/nestjs/nest
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Nest application with TypeScript support
# · DESIGN PHILOSOPHY: Multi-stage build with security hardening and optimization
# · COMBINATION: Use standalone for complete Nest applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: Nest documentation and Docker security guidelines

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
COPY tsconfig*.json ./
COPY nest-cli.json ./

# Install dependencies with security optimizations
RUN npm ci --no-audit --no-fund && \
    npm cache clean --force

COPY src/ ./src/

# Build the application
RUN npm run build

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Optimized runtime environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS runtime

# Build arguments for runtime configuration
ARG NODE_ENV=production
ARG PORT=3000
ARG APP_VERSION=1.0.0

# Environment variables for runtime
ENV NODE_ENV=${NODE_ENV} \
    PORT=${PORT} \
    APP_VERSION=${APP_VERSION} \
    npm_config_update_notifier=false \
    npm_config_cache=/tmp/.npm

# Create non-root user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -S -u 1001 -G appgroup appuser

WORKDIR /app

# Copy built application from builder stage
COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/package*.json ./

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
CMD ["node", "dist/main.js"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT STAGE - Hot reload and debugging support
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS development

# Environment variables for development
ENV NODE_ENV=development \
    PORT=3000 \
    npm_config_update_notifier=false

WORKDIR /app

COPY package*.json ./
COPY tsconfig*.json ./
COPY nest-cli.json ./

# Install all dependencies (including dev dependencies)
RUN npm ci --no-audit --no-fund && \
    npm cache clean --force

COPY src/ ./src/

EXPOSE ${PORT}

# Start development server with hot reload
CMD ["npm", "run", "start:dev"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Production build
# docker build --target production -t nestjs-app .
# docker run -p 3000:3000 nestjs-app

# Example 2: Development with hot reload
# docker build --target development -t nestjs-dev .
# docker run -p 3000:3000 -v $(pwd):/app nestjs-dev

# Example 3: Multi-stage build with specific stage
# docker build --target builder -t nestjs-builder .
# docker build --target production -t nestjs-prod .

# Example 4: Build with custom arguments
# docker build \
#   --build-arg NODE_ENV=production \
#   --build-arg PORT=8080 \
#   --target production \
#   -t nestjs-custom .

# Example 5: Complete CI/CD pipeline
# docker build \
#   --build-arg BUILD_ID=$CI_PIPELINE_ID \
#   --build-arg COMMIT_SHA=$CI_COMMIT_SHA \
#   --target production \
#   -t nestjs:$CI_COMMIT_SHA .

# Example 6: With PostgreSQL database
# cat frameworks/nestjs.Dockerfile tools/postgresql.Dockerfile > Dockerfile
# docker build -t nestjs-with-db .

# Example 7: With security hardening
# cat frameworks/nestjs.Dockerfile patterns/security-hardened.Dockerfile > Dockerfile
# docker build -t nestjs-secure .

# Example 8: Multi-stage with monitoring
# cat frameworks/nestjs.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/security-hardened.Dockerfile \
#     patterns/monitoring.Dockerfile > Dockerfile

# BEST PRACTICES
# ==============

# 1. NestJS Best Practices:
#    • Use multi-stage builds for production deployments
#    • Always run as non-root user in production
#    • Use Alpine base images for smaller runtime size
#    • Implement health checks for container orchestration
#    • Use environment variables for configuration
#    • Clean npm cache to reduce image size
#    • Use specific Node.js versions (not 'latest')
#    • Scan images for vulnerabilities before deployment
#    • Implement proper logging and monitoring
#    • Use TypeScript strict mode for better type safety

# 2. Security Considerations:
#    • This template includes non-root user configuration
#    • Production stage runs with minimal privileges
#    • Development stage includes all dependencies for hot reload
#    • Health check monitors application status
#    • Consider adding patterns/security-hardened.Dockerfile
#    • Use secrets management for sensitive data
#    • Implement rate limiting and request validation
#    • Use HTTPS in production environments
#    • Regularly update dependencies for security patches

# 3. Performance Optimization:
#    • Layer caching optimization with dependency-first copy
#    • Multi-stage builds reduce final image size
#    • Alpine base images minimize runtime footprint
#    • Production stage excludes development dependencies
#    • Proper resource limits for container orchestration
#    • Use .dockerignore to exclude unnecessary files
#    • Implement connection pooling for database access
#    • Use caching strategies for improved performance

# 4. Development Workflow:
#    • Use development stage for local development
#    • Mount source code volumes for hot reload
#    • Configure debugging ports for IDE integration
#    • Use Docker Compose for multi-service development
#    • Implement automated testing in CI/CD pipeline
#    • Use linting and code quality tools
#    • Follow NestJS module and service patterns
#    • Implement proper error handling and logging

# 5. Combination Patterns:
#    • This template is designed for standalone NestJS applications
#    • Combine with database templates (PostgreSQL, MongoDB)
#    • Add security patterns for production hardening
#    • Use monitoring patterns for observability
#    • Implement CI/CD patterns for automated deployment
#    • Consider adding API gateway patterns if needed
