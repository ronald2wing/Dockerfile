# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for Go
# Website: https://golang.org/
# Repository: https://github.com/golang/go
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: Go runtime configuration for Docker containers
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: Use with multi-stage builds for production deployments
# · OFFICIAL SOURCES: Go documentation and Docker best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Choose appropriate base image based on your needs:

# Option 1: Alpine (smallest)
FROM golang:1.21-alpine

# Option 2: Slim (Debian-based, smaller than full)
# FROM golang:1.21-slim

# Option 3: Full (includes build tools)
# FROM golang:1.21

# Option 4: Specific version with SHA
# FROM golang:1.21-alpine@sha256:abc123...

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG GO_VERSION=1.21
ARG GO_ENV=production
ARG BUILD_ID=unknown
ARG CGO_ENABLED=0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV GO_VERSION=${GO_VERSION} \
  GO_ENV=${GO_ENV} \
  BUILD_ID=${BUILD_ID} \
  CGO_ENABLED=${CGO_ENABLED} \
  GO111MODULE=on \
  GOPROXY=https://proxy.golang.org,direct \
  GOSUMDB=sum.golang.org \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# WORKDIR SETUP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WORKDIR /app

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEPENDENCY MANAGEMENT PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COPY go.mod go.sum ./

# Pattern 1: Download dependencies
RUN go mod download

# Pattern 2: Download and verify dependencies
# RUN go mod download && go mod verify

# Pattern 3: Vendor dependencies
# RUN go mod vendor

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APPLICATION DEPLOYMENT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COPY . .

# Build Go application
RUN go build -o /app/main .

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Expose port (customize for your application)
EXPOSE 8080

# Create logs directory
RUN mkdir -p /app/logs && chmod 755 /app/logs

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT & COMMAND OPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Option 1: Direct binary execution
# ENTRYPOINT ["/app/main"]

# Option 2: With arguments
# ENTRYPOINT ["/app/main"]
# CMD ["--port", "8080"]

# Option 3: Custom entrypoint script
# COPY entrypoint.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/entrypoint.sh
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# CMD ["/app/main"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECK OPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Option 1: HTTP health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD curl -f http://localhost:8080/health || exit 1

# Option 2: Process health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD pgrep main || exit 1

# Option 3: Custom health check script
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD /app/scripts/healthcheck.sh

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Development-specific configurations (uncomment as needed)

# Install development tools
# RUN go install github.com/cosmtrek/air@v1.51.0

# Development command with hot reload
# CMD ["air", "-c", ".air.toml"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PERFORMANCE OPTIMIZATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Uncomment optimizations as needed:

# Build with optimizations
# RUN go build -ldflags="-s -w" -o /app/main .

# Build for specific architecture
# RUN GOOS=linux GOARCH=amd64 go build -o /app/main .

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Build basic Go image
# docker build -t my-go-app:v1.0.0 .

# Example 2: Build with custom arguments
# docker build \
#   --build-arg GO_VERSION=1.21 \
#   --build-arg GO_ENV=production \
#   --build-arg BUILD_ID=$(git rev-parse --short HEAD) \
#   -t my-go-app:$(git rev-parse --short HEAD) .

# Example 3: Run Go application
# docker run -d \
#   -p 8080:8080 \
#   --name go-app \
#   --memory=512m \
#   --cpus=1.0 \
#   my-go-app:v1.0.0

# Example 4: Development with volume mounting
# docker run -d \
#   -p 8080:8080 \
#   -v $(pwd):/app \
#   --name go-dev \
#   my-go-app:dev

# Example 5: CI/CD pipeline build
# docker build \
#   --build-arg GO_VERSION=1.21 \
#   --build-arg GO_ENV=production \
#   --build-arg BUILD_ID=$CI_PIPELINE_ID \
#   --no-cache \
#   -t my-go-app:$CI_COMMIT_SHORT_SHA .

# Best Practices:
# 1. Always pin Go version and dependency versions
# 2. Use .dockerignore to exclude vendor/, .git, etc.
# 3. Use multi-stage builds for production (combine with patterns/multi-stage.Dockerfile)
# 4. Run as non-root user in production (combine with patterns/security-hardened.Dockerfile)
# 5. Use health checks for container orchestration
# 6. Build with CGO_ENABLED=0 for static binaries
# 7. Use go mod download for dependency caching
# 8. Implement proper logging and monitoring

# Security Recommendations:
# 1. Always combine with security-hardened template
# 2. Use static compilation (CGO_ENABLED=0) to reduce attack surface
# 3. Regularly update Go version and dependencies
# 4. Scan binaries for vulnerabilities
# 5. Use minimal base images (Alpine recommended)
