# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for Bun
# Website: https://bun.sh/
# Repository: https://github.com/oven-sh/bun
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: Bun runtime environment for fast JavaScript/TypeScript applications
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: Fast package management, built-in tooling, performance optimization
# · OFFICIAL SOURCES: Bun documentation and performance guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE - Bun runtime
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM oven/bun:1.0-alpine

# Build arguments for environment configuration
ARG BUN_VERSION=1.0
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG NODE_ENV=production

# Environment variables for runtime
ENV BUN_VERSION=${BUN_VERSION} \
    BUILD_ID=${BUILD_ID} \
    COMMIT_SHA=${COMMIT_SHA} \
    NODE_ENV=${NODE_ENV} \
    BUN_INSTALL=/usr/local \
    PATH=/usr/local/bin:${PATH}

WORKDIR /app

# Copy dependency files first for optimal layer caching
COPY package.json bun.lockb ./

# Install production dependencies
RUN bun install --production --frozen-lockfile && \
    bun pm cache rm && \
    rm -rf /tmp/*

COPY . .

# Expose application port (adjust based on your application)
EXPOSE 3000

# Default command (override in child images or runtime)
CMD ["bun", "run", "src/index.js"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build production image
# docker build -t my-bun-app:prod .

# Example 2: Build with custom build arguments
# docker build \
#   --build-arg BUILD_ID=v1.0.0 \
#   --build-arg COMMIT_SHA=$(git rev-parse HEAD) \
#   -t my-bun-app:prod .

# Example 3: Run development with hot reload
# docker run -d -p 3000:3000 -v $(pwd):/app --name bun-dev my-bun-app:dev

# Example 4: Run production with resource limits
# docker run -d \
#   -p 3000:3000 \
#   --restart unless-stopped \
#   --memory 128m \
#   --cpus 0.5 \
#   --name bun-app \
#   my-bun-app:prod

# Example 5: Run with Docker Compose
# docker-compose up -d

# Example 6: Build for multiple architectures
# docker buildx build --platform linux/amd64,linux/arm64 -t my-bun-app:multi-arch .

# Example 7: Run with health check verification
# docker run -d -p 3000:3000 --health-cmd="bun run health-check.js || exit 1" --name bun-app my-bun-app:prod

# Example 8: Run with environment variables
# docker run -d -p 3000:3000 -e NODE_ENV=production -e DATABASE_URL=postgres://user:pass@db:5432/app --name bun-app my-bun-app:prod

# BEST PRACTICES
# ==============

# Security Best Practices:
# • Combine with patterns/security-hardened.Dockerfile for non-root execution
# • Use specific base image versions (avoid 'latest' tags)
# • Regularly update Bun and Alpine dependencies
# • Scan images for vulnerabilities using tools like Trivy or Grype

# Performance Optimization:
# • Use multi-stage builds to minimize final image size
# • Leverage layer caching by copying package.json and bun.lockb first
# • Use Alpine base images for smaller footprint
# • Set appropriate resource limits (memory, CPU) in production
# • Use Bun's built-in optimizations for faster builds

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

# Bun-Specific Considerations:
# • Use bun.lockb for deterministic dependency installation
# • Leverage Bun's built-in TypeScript support without compilation step
# • Use Bun's test runner for faster test execution
# • Take advantage of Bun's WebSocket and SQLite support
# • Use Bun's bundler for optimized production builds
