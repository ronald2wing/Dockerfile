# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for Swift
# Website: https://swift.org/
# Repository: https://github.com/swiftlang/swift
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY:          Language
# · PURPOSE:           Swift runtime environment for modular combination
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION:       Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY:          No security patterns included - combine with security template
# · BEST PRACTICES:    Use with multi-stage builds for production deployments
# · OFFICIAL SOURCES:  Swift documentation and Docker best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Official Swift image for compilation
# Using specific version for reproducible builds

FROM swift:5.9-focal AS builder

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Customize build behavior with these arguments

ARG SWIFT_BUILD_MODE=release
ARG SWIFT_FLAGS="-c release --static-swift-stdlib"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ENVIRONMENT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Install system dependencies

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libssl-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEPENDENCIES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Copy package manifest first for caching

COPY Package.swift .
COPY Package.resolved .

# Resolve dependencies
RUN swift package resolve

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SOURCE CODE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Copy source code

COPY Sources ./Sources
COPY Tests ./Tests
COPY Resources ./Resources

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD PROCESS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Build Swift application

RUN swift build $SWIFT_FLAGS

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Multi-stage build for optimized final image

FROM ubuntu:focal AS runtime

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME DEPENDENCIES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Install minimal runtime dependencies

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libssl1.1 \
    libsqlite3-0 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APPLICATION DEPLOYMENT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Copy built binary from builder stage

COPY --from=builder /app/.build/release/App .

# Copy resources if any
COPY --from=builder /app/Resources ./Resources

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Environment variables for application configuration

ENV PORT=8080
ENV HOST=0.0.0.0

# Health check for container orchestration
# HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
#     CMD curl -f http://localhost:8080/health || exit 1

EXPOSE 8080

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Start Swift application

CMD ["./App", "serve", "--hostname", "0.0.0.0", "--port", "8080"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build basic Swift image
# docker build -t my-swift-app:v1.0.0 .

# Example 2: Build with custom arguments
# docker build \
#   --build-arg SWIFT_VERSION=5.9 \
#   --build-arg SWIFT_BUILD_MODE=release \
#   --build-arg BUILD_ID=$(git rev-parse --short HEAD) \
#   -t my-swift-app:$(git rev-parse --short HEAD) .

# Example 3: Run Swift application
# docker run -d \
#   -p 8080:8080 \
#   --name swift-app \
#   --memory=512m \
#   --cpus=1.0 \
#   my-swift-app:v1.0.0

# Example 4: Development with volume mounting
# docker run -d \
#   -p 8080:8080 \
#   -v $(pwd):/app \
#   --name swift-dev \
#   my-swift-app:dev

# Example 5: Test execution
# docker run --rm my-swift-app:test swift test

# Example 6: Shell access for debugging
# docker run -it --rm my-swift-app:v1.0.0 /bin/sh

# Example 7: Combine with pattern templates
# cat languages/swift.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/security-hardened.Dockerfile > Dockerfile

# Example 8: Production deployment with monitoring
# cat languages/swift.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/security-hardened.Dockerfile \
#     patterns/monitoring.Dockerfile > Dockerfile

# BEST PRACTICES
# ==============

# 1. Always pin Swift runtime and package versions
# 2. Use .dockerignore to exclude build artifacts, .build, etc.
# 3. Use multi-stage builds for production deployments
# 4. Run as non-root user in production for security
# 5. Use health checks for container orchestration
# 6. Clean package caches to reduce image size
# 7. Use environment variables for configuration
# 8. Implement proper logging and monitoring

# Security Recommendations:
# 1. Always combine with security-hardened template for production
# 2. Scan for vulnerabilities with Swift-specific tools
# 3. Use dependency isolation and version pinning
# 4. Regularly update dependencies for security patches
# 5. Use secrets management for sensitive data

# Performance Optimization:
# 1. Optimize dependency installation order
# 2. Use appropriate base images
# 3. Implement connection pooling where applicable
# 4. Use build cache effectively
# 5. Minimize layer count through command combination

# Swift-Specific Considerations:
# • Use static linking for smaller binaries when possible
# • Consider Alpine variants for smaller images (with compatibility testing)
# • Optimize Swift Package Manager dependency resolution
# • Use appropriate build configurations (debug/release)
# • Implement proper error handling and logging

# Combination Patterns:
# 1. This template is designed to be combined with pattern templates
# 2. Always combine with security-hardened.Dockerfile for production
# 3. Use multi-stage.Dockerfile for optimized builds
# 4. Consider adding monitoring.Dockerfile for observability
# 5. Add ci-cd.Dockerfile for automated pipeline integration

# Framework Integration:
# • Vapor: Use with Vapor package dependencies
# • Perfect: Use with Perfect package dependencies
# • Kitura: Use with Kitura package dependencies
# • Custom: Adapt build commands for your Swift framework
