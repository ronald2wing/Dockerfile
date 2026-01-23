# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Gatsby
# Website: https://www.gatsbyjs.com/
# Repository: https://github.com/gatsbyjs/gatsby
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Gatsby static site with security hardening
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security
# · COMBINATION: Use standalone for complete Gatsby applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: Gatsby documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Node.js LTS version for stability and security
# Using specific version to avoid "latest" tag security issues

FROM node:20.11.1-alpine AS builder

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Customize build behavior with these arguments

ARG NODE_ENV=production
ARG GATSBY_TELEMETRY_DISABLED=1
ARG CI=true

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEPENDENCIES
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
COPY gatsby*.json ./

# Install dependencies with clean cache
RUN npm ci --no-audit --progress=false && \
    npm cache clean --force

# Build Gatsby site
RUN npm run build

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Multi-stage build for optimized final image

FROM node:20.11.1-alpine AS runtime

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S -u 1001 -G nodejs gatsbyuser

WORKDIR /app

# Install serve for static file serving
RUN npm install -g serve@14.2.1

# Copy built assets from builder stage
COPY --from=builder --chown=gatsbyuser:nodejs /app/public ./public

# Switch to non-root user
USER gatsbyuser

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Environment variables and health checks

ENV NODE_ENV=production
ENV PORT=8000

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000 || exit 1

EXPOSE 8000

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Serve static files with proper caching headers

STOPSIGNAL SIGTERM
CMD ["serve", "-s", "public", "-l", "8000", "--cors", "--no-clipboard", "--no-port-switching"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Production build
# docker build --target runtime -t gatsby-app .
# docker run -p 8000:8000 gatsby-app

# Example 2: Development with hot reload
# docker build --target builder -t gatsby-dev .
# docker run -p 8000:8000 -v $(pwd):/app gatsby-dev npm run develop

# Example 3: Build with custom arguments
# docker build \
#   --build-arg NODE_ENV=production \
#   --build-arg GATSBY_TELEMETRY_DISABLED=1 \
#   --target runtime \
#   -t gatsby-custom .

# Example 4: Complete CI/CD pipeline
# docker build \
#   --build-arg CI=true \
#   --build-arg COMMIT_SHA=$CI_COMMIT_SHA \
#   --target runtime \
#   -t gatsby:$CI_COMMIT_SHA .

# Example 5: With nginx reverse proxy
# cat frameworks/gatsby.Dockerfile tools/nginx.Dockerfile > Dockerfile
# docker build -t gatsby-with-nginx .

# Example 6: With security hardening
# cat frameworks/gatsby.Dockerfile patterns/security-hardened.Dockerfile > Dockerfile
# docker build -t gatsby-secure .

# Example 7: Multi-stage with monitoring
# cat frameworks/gatsby.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/security-hardened.Dockerfile \
#     patterns/monitoring.Dockerfile > Dockerfile

# Example 8: Development with volume mounting
# docker run -p 8000:8000 \
#   -v $(pwd):/app \
#   -v /app/node_modules \
#   gatsby-dev npm run develop

# BEST PRACTICES
# ==============

# 1. Gatsby.js Best Practices:
#    • Use multi-stage builds for production deployments
#    • Always run as non-root user in production
#    • Use Alpine base images for smaller runtime size
#    • Implement health checks for container orchestration
#    • Use environment variables for configuration
#    • Clean npm cache to reduce image size
#    • Use specific Node.js versions (not 'latest')
#    • Scan images for vulnerabilities before deployment
#    • Implement proper logging and monitoring
#    • Follow Gatsby.js best practices and conventions

# 2. Security Considerations:
#    • This template includes non-root user configuration
#    • Production stage runs with minimal privileges
#    • Development stage includes all dependencies for hot reload
#    • Health check monitors application status
#    • Consider adding patterns/security-hardened.Dockerfile
#    • Use secrets management for sensitive data
#    • Disable Gatsby telemetry in production
#    • Use HTTPS in production environments
#    • Regularly update dependencies for security patches

# 3. Performance Optimization:
#    • Layer caching optimization with dependency-first copy
#    • Multi-stage builds reduce final image size
#    • Alpine base images minimize runtime footprint
#    • Production stage excludes development dependencies
#    • Proper resource limits for container orchestration
#    • Use .dockerignore to exclude unnecessary files
#    • Implement caching strategies for improved performance
#    • Optimize static asset delivery with proper headers

# 4. Development Workflow:
#    • Use development mode for local development
#    • Mount source code volumes for hot reload
#    • Configure debugging ports for IDE integration
#    • Use Docker Compose for multi-service development
#    • Implement automated testing in CI/CD pipeline
#    • Use linting and code quality tools
#    • Follow Gatsby.js component and page patterns

# 5. Combination Patterns:
#    • This template is designed for standalone Gatsby.js applications
#    • Combine with nginx for reverse proxy and static file serving
#    • Add security patterns for production hardening
#    • Use monitoring patterns for observability
#    • Implement CI/CD patterns for automated deployment
#    • Consider adding CMS integration patterns if needed
