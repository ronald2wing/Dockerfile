# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for Dart
# Website: https://dart.dev/
# Repository: https://github.com/dart-lang/sdk
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: Dart runtime environment for client and server applications
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: Sound null safety, package version pinning, AOT compilation
# · OFFICIAL SOURCES: Dart documentation and performance guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Application compilation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM dart:3.5 AS builder

# Build arguments for environment configuration
ARG DART_VERSION=stable
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG BUILD_MODE=release

# Environment variables for build process
ENV DART_VERSION=${DART_VERSION} \
    BUILD_ID=${BUILD_ID} \
    COMMIT_SHA=${COMMIT_SHA} \
    BUILD_MODE=${BUILD_MODE} \
    PUB_CACHE=/tmp/.pub-cache

WORKDIR /app

# Copy dependency files first for optimal layer caching
COPY pubspec.* ./

# Get dependencies
RUN dart pub get

COPY . .

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMPILATION STAGE - AOT compilation for production
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Build AOT snapshot for production
RUN dart compile aot-snapshot bin/main.dart -o /app/main.aot

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Minimal production image
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM debian:bookworm-slim AS runtime

# Install Dart runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    tzdata && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy AOT snapshot from builder stage
COPY --from=builder /app/main.aot /app/main.aot

# Copy configuration files if any
COPY --from=builder /app/config/ ./config/

# Copy Dart runtime
COPY --from=builder /usr/lib/dart /usr/lib/dart

# Set up environment
ENV PATH="/usr/lib/dart/bin:${PATH}" \
    DART_SDK="/usr/lib/dart"

# Expose application port (adjust based on your application)
EXPOSE 8080

# Application entrypoint using AOT snapshot
ENTRYPOINT ["dart", "--enable-asserts", "/app/main.aot"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build production image with AOT compilation
# docker build -t my-dart-app:prod .

# Example 2: Build with custom build arguments
# docker build \
#   --build-arg BUILD_ID=v1.0.0 \
#   --build-arg COMMIT_SHA=$(git rev-parse HEAD) \
#   -t my-dart-app:prod .

# Example 3: Run development with JIT compilation and hot reload
# docker run -d -p 8080:8080 -v $(pwd):/app --name dart-dev my-dart-app:dev

# Example 4: Run production with resource limits
# docker run -d \
#   -p 8080:8080 \
#   --restart unless-stopped \
#   --memory 256m \
#   --cpus 0.5 \
#   --name dart-app \
#   my-dart-app:prod

# Example 5: Run with Docker Compose
# docker-compose up -d

# Example 6: Build for multiple architectures
# docker buildx build --platform linux/amd64,linux/arm64 -t my-dart-app:multi-arch .

# Example 7: Run with health check verification
# docker run -d -p 8080:8080 --health-cmd="dart /app/health_check.dart || exit 1" --name dart-app my-dart-app:prod

# Example 8: Run with environment variables
# docker run -d -p 8080:8080 -e APP_ENV=production -e DATABASE_URL=postgres://user:pass@db:5432/app --name dart-app my-dart-app:prod

# BEST PRACTICES
# ==============

# Security Best Practices:
# • Always use non-root user for runtime execution
# • Use specific Dart version tags (avoid 'stable' or 'latest' tags)
# • Enable sound null safety for type safety
# • Use AOT compilation for production to reduce attack surface
# • Regularly update Dart SDK and dependencies
# • Scan images for vulnerabilities using tools like Trivy or Grype
# • Implement proper input validation and sanitization
# • Use environment variables for sensitive configuration

# Performance Optimization:
# • Use AOT compilation for faster startup and better performance
# • Leverage layer caching by copying pubspec.* files first
# • Use multi-stage builds to minimize final image size
# • Set appropriate resource limits (memory, CPU) in production
# • Enable Dart's built-in optimizations for production builds
# • Use isolates for CPU-intensive operations
# • Implement proper caching strategies for web applications
# • Monitor and optimize memory usage

# Development Workflow:
# • Use separate development and production Dockerfiles or targets
# • Mount source code as volume for hot reload during development
# • Set up proper .dockerignore to exclude build/, .dart_tool/, .packages
# • Use Docker Compose for local development with databases
# • Implement health checks for container orchestration
# • Use Dart's built-in testing framework for unit and integration tests
# • Implement proper logging and debugging tools
# • Use code generation tools where appropriate

# Production Deployment:
# • Use specific version tags for production images
# • Implement proper logging with structured JSON format
# • Set up automated builds and security scanning
# • Use container orchestration (Kubernetes, Docker Swarm) for scaling
# • Implement zero-downtime deployment strategies
# • Monitor application performance and error rates
# • Implement proper backup and recovery procedures
# • Use blue-green or canary deployment strategies

# Dart-Specific Considerations:
# • Choose appropriate compilation mode (AOT for production, JIT for development)
# • Configure appropriate garbage collection settings
# • Use isolates for concurrent programming
# • Implement proper error handling with try-catch and zones
# • Use Dart's built-in async/await for asynchronous operations
# • Consider using Shelf, Aqueduct, or Angel frameworks for web applications
# • Use Flutter for cross-platform UI development
# • Implement proper package management with pubspec.yaml
