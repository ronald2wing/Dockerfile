# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Remix
# Website: https://remix.run/
# Repository: https://github.com/remix-run/remix
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Remix application with security hardening
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security
# · COMBINATION: Use standalone for complete Remix applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: Remix documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Node.js LTS version for Remix applications
# Using specific version to avoid "latest" tag security issues

FROM node:20.11.1-alpine AS builder

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Customize build behavior with these arguments

ARG NODE_ENV=production
ARG CI=true

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Install system dependencies and create app directory

RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git \
    curl

WORKDIR /app

# Copy package files for dependency installation
COPY package*.json ./
COPY remix.config.js ./

# Install dependencies with clean cache
RUN npm ci --no-audit --progress=false && \
    npm cache clean --force

# Build Remix application
RUN npm run build

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Multi-stage build for optimized final image

FROM node:20.11.1-alpine AS runtime

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S -u 1001 -G nodejs remixuser

WORKDIR /app

# Copy built assets and dependencies from builder stage
COPY --from=builder --chown=remixuser:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=remixuser:nodejs /app/build ./build
COPY --from=builder --chown=remixuser:nodejs /app/public ./public
COPY --from=builder --chown=remixuser:nodejs /app/package.json ./package.json

# Switch to non-root user
USER remixuser

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Environment variables and health checks

ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

EXPOSE 3000

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Start Remix application in production mode

STOPSIGNAL SIGTERM
CMD ["npm", "start"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build production image
# docker build --target runtime -t my-remix-app:prod .

# Example 2: Run development with hot reload
# docker run -d -p 3000:3000 -v $(pwd):/app --name remix-dev my-remix-app:dev

# Example 3: Run production with resource limits
# docker run -d \
#   -p 3000:3000 \
#   --restart unless-stopped \
#   --memory 256m \
#   --cpus 0.5 \
#   --name remix-app \
#   my-remix-app:prod

# Example 4: Run with Docker Compose
# docker-compose up -d

# Example 5: Build for multiple architectures
# docker buildx build --platform linux/amd64,linux/arm64 -t my-remix-app:multi-arch .

# Example 6: Run with health check verification
# docker run -d -p 3000:3000 --health-cmd="curl -f http://localhost:3000/health || exit 1" --name remix-app my-remix-app:prod

# Example 7: Run with environment variables
# docker run -d -p 3000:3000 -e NODE_ENV=production -e DATABASE_URL=postgres://user:pass@db:5432/app --name remix-app my-remix-app:prod

# Example 8: Combine with PostgreSQL template
# cat frameworks/remix.Dockerfile tools/postgresql.Dockerfile > Dockerfile

# BEST PRACTICES
# ==============

# Security Best Practices:
# • Always use non-root user for runtime execution
# • Use specific base image versions (avoid 'latest' tags)
# • Set appropriate file permissions for application directories
# • Regularly update Node.js and Alpine dependencies
# • Scan images for vulnerabilities using tools like Trivy or Grype

# Performance Optimization:
# • Use multi-stage builds to minimize final image size
# • Leverage layer caching by copying package.json and package-lock.json first
# • Use Alpine base images for smaller footprint
# • Set appropriate resource limits (memory, CPU) in production
# • Enable Node.js optimizations for production

# Development Workflow:
# • Use separate development and production Dockerfiles or targets
# • Mount source code as volume for hot reload during development
# • Set up proper .dockerignore to exclude node_modules, .git, build artifacts
# • Use Docker Compose for local development with databases
# • Implement health checks for container orchestration

# Production Deployment:
# • Use specific version tags for production images
# • Implement proper logging with structured JSON format
# • Set up automated builds and security scanning
# • Use container orchestration (Kubernetes, Docker Swarm) for scaling
# • Implement zero-downtime deployment strategies

# Remix-Specific Considerations:
# • Configure appropriate session storage (Redis recommended for production)
# • Set up proper error boundaries and error handling
# • Implement proper caching headers for static assets
# • Set up monitoring for request metrics and performance
# • Use Remix's built-in features for data loading and mutations
