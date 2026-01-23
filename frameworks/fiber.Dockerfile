# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Fiber
# Website: https://gofiber.io/
# Repository: https://github.com/gofiber/fiber
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Fiber web framework application with high performance
# · DESIGN PHILOSOPHY: Express-inspired API with Go performance, minimal footprint
# · COMBINATION: Use standalone for complete Fiber applications
# · SECURITY: Non-root user, Alpine base, static compilation
# · BEST PRACTICES: Zero memory allocation patterns, optimized routing
# · OFFICIAL SOURCES: Fiber documentation and Go performance guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Application compilation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM golang:1.21-alpine AS builder

# Build arguments for environment configuration
ARG GO_VERSION=1.21
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG CGO_ENABLED=0
ARG GOOS=linux
ARG GOARCH=amd64

# Environment variables for build process
ENV GO_VERSION=${GO_VERSION} \
    BUILD_ID=${BUILD_ID} \
    COMMIT_SHA=${COMMIT_SHA} \
    CGO_ENABLED=${CGO_ENABLED} \
    GOOS=${GOOS} \
    GOARCH=${GOARCH} \
    GOPROXY=https://proxy.golang.org,direct \
    GOMODCACHE=/go/pkg/mod

# Install build dependencies
RUN apk add --no-cache git ca-certificates tzdata

WORKDIR /app

# Copy go module files first for optimal layer caching
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download && go mod verify

COPY . .

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMPILATION STAGE - Build optimized binary
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Build static binary with performance optimizations
RUN go build \
    -ldflags="-w -s -X main.Version=${BUILD_ID} -X main.Commit=${COMMIT_SHA}" \
    -trimpath \
    -gcflags="all=-trimpath=$(pwd)" \
    -asmflags="all=-trimpath=$(pwd)" \
    -o /app/fiber-app \
    ./cmd/main.go

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Minimal production image
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM alpine:3.19 AS runtime

# Security configuration
ARG APP_USER=appuser
ARG APP_GROUP=appgroup
ARG APP_UID=1001
ARG APP_GID=1001

# Create non-root user and group
RUN addgroup -g ${APP_GID} -S ${APP_GROUP} && \
    adduser -S -u ${APP_UID} -G ${APP_GROUP} ${APP_USER}

# Install runtime dependencies
RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

# Copy compiled binary from builder stage
COPY --from=builder --chown=${APP_USER}:${APP_GROUP} /app/fiber-app /app/fiber-app

# Copy configuration files if any
COPY --from=builder --chown=${APP_USER}:${APP_GROUP} /app/configs/ ./configs/

# Set permissions
RUN chmod 750 /app/fiber-app && \
    chown -R ${APP_USER}:${APP_GROUP} /app

# Switch to non-root user
USER ${APP_USER}

EXPOSE 3000

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Application entrypoint
STOPSIGNAL SIGTERM
ENTRYPOINT ["/app/fiber-app"]

# Default command (can be overridden)
CMD ["serve"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build production image
# docker build --target runtime -t my-fiber-app:prod .

# Example 2: Build with custom build arguments
# docker build \
#   --build-arg BUILD_ID=v1.0.0 \
#   --build-arg COMMIT_SHA=$(git rev-parse HEAD) \
#   -t my-fiber-app:prod .

# Example 3: Run development with hot reload
# docker run -d -p 3000:3000 -v $(pwd):/app --name fiber-dev my-fiber-app:dev

# Example 4: Run production with resource limits
# docker run -d \
#   -p 3000:3000 \
#   --restart unless-stopped \
#   --memory 128m \
#   --cpus 0.5 \
#   --name fiber-app \
#   my-fiber-app:prod

# Example 5: Run with Docker Compose
# docker-compose up -d

# Example 6: Build for multiple architectures
# docker buildx build --platform linux/amd64,linux/arm64 -t my-fiber-app:multi-arch .

# Example 7: Run with health check verification
# docker run -d -p 3000:3000 --health-cmd="curl -f http://localhost:3000/health || exit 1" --name fiber-app my-fiber-app:prod

# Example 8: Run with environment variables
# docker run -d -p 3000:3000 -e APP_ENV=production -e APP_DEBUG=false --name fiber-app my-fiber-app:prod

# BEST PRACTICES
# ==============

# Security Best Practices:
# • Always use non-root user for runtime execution
# • Use specific base image versions (avoid 'latest' tags)
# • Enable CGO_ENABLED=0 for static compilation when possible
# • Regularly update base images and dependencies
# • Scan images for vulnerabilities using tools like Trivy or Grype

# Performance Optimization:
# • Use multi-stage builds to minimize final image size
# • Leverage layer caching by copying dependency files first
# • Use Alpine base images for smaller footprint when appropriate
# • Set appropriate resource limits (memory, CPU) in production
# • Enable Go module proxy for faster dependency downloads

# Development Workflow:
# • Use separate development and production Dockerfiles or targets
# • Mount source code as volume for hot reload during development
# • Set up proper .dockerignore to exclude unnecessary files
# • Use Docker Compose for local development with dependencies
# • Implement health checks for container orchestration

# Production Deployment:
# • Use specific version tags for production images
# • Implement proper logging and monitoring
# • Set up automated builds and security scanning
# • Use container orchestration (Kubernetes, Docker Swarm) for scaling
# • Implement zero-downtime deployment strategies

# Fiber-Specific Considerations:
# • Configure appropriate timeouts and limits for your workload
# • Use Fiber's built-in middleware for common tasks
# • Implement proper error handling and recovery
# • Set up monitoring for request metrics and performance
# • Use connection pooling for database and external service calls
