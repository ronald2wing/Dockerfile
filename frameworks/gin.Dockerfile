# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Gin
# Website: https://gin-gonic.com/
# Repository: https://github.com/gin-gonic/gin
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Gin web framework application with security hardening
# · DESIGN PHILOSOPHY: Multi-stage build for minimal final image, security-first approach
# · COMBINATION: Use standalone for complete Gin applications
# · SECURITY: Non-root user, Alpine base, minimal dependencies
# · BEST PRACTICES: Static binary compilation, layer caching, production defaults
# · OFFICIAL SOURCES: Gin documentation and Go security guidelines

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
# COMPILATION STAGE - Build static binary
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Build static binary with optimizations
RUN go build \
    -ldflags="-w -s -X main.Version=${BUILD_ID} -X main.Commit=${COMMIT_SHA}" \
    -trimpath \
    -o /app/gin-app \
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
COPY --from=builder --chown=${APP_USER}:${APP_GROUP} /app/gin-app /app/gin-app

# Copy configuration files if any
COPY --from=builder --chown=${APP_USER}:${APP_GROUP} /app/configs/ ./configs/

# Set permissions
RUN chmod 750 /app/gin-app && \
    chown -R ${APP_USER}:${APP_GROUP} /app

# Switch to non-root user
USER ${APP_USER}

EXPOSE 8080

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Application entrypoint
STOPSIGNAL SIGTERM
ENTRYPOINT ["/app/gin-app"]

# Default command (can be overridden)
CMD ["serve"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build production image
# docker build --target runtime -t gin-app:prod .

# Example 2: Build development image
# docker build --target development -t gin-app:dev .

# Example 3: Build with custom arguments
# docker build \
#   --build-arg BUILD_ID=v1.0.0 \
#   --build-arg COMMIT_SHA=$(git rev-parse HEAD) \
#   -t gin-app:$(git rev-parse --short HEAD) .

# Example 4: Run production container
# docker run -d -p 8080:8080 --name gin-app gin-app:prod

# Example 5: Run development container
# docker run -d -p 8080:8080 -v $(pwd):/app --name gin-app-dev gin-app:dev

# Example 6: Run with environment variables
# docker run -d \
#   -p 8080:8080 \
#   -e GIN_MODE=release \
#   -e DATABASE_URL=postgresql://user:pass@db:5432/db \
#   --name gin-app \
#   gin-app:prod

# Example 7: Docker Compose deployment
# docker-compose up -d

# Example 8: Kubernetes deployment
# kubectl apply -f deployment.yaml

# BEST PRACTICES
# ==============

# 1. Always use .dockerignore to exclude unnecessary files
# 2. Use specific Go versions (never use 'latest' tags)
# 3. Run health checks in production for container orchestration
# 4. Use multi-stage builds for smaller production images
# 5. Set resource limits in docker-compose or Kubernetes
# 6. Run as non-root user in production for security
# 7. Use environment variables for configuration
# 8. Implement proper logging and monitoring

# Security Considerations:
# • Always use non-root users in production stages
# • Compile with CGO_ENABLED=0 for static binaries
# • Scan images for vulnerabilities regularly
# • Keep dependencies updated with security patches
# • Use secrets management for sensitive data

# Performance Optimization:
# • Use static compilation for smaller binaries
# • Optimize layer caching by ordering instructions properly
# • Combine RUN commands to reduce layer count
# • Use Alpine base images for smaller size
# • Implement connection pooling and caching

# Customization Notes:
# 1. Replace 'gin-app' with your actual binary name
# 2. Adjust exposed ports based on your application
# 3. Modify health check endpoints as needed
# 4. Add environment variables specific to your application
# 5. Customize build commands for your Go setup
