# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Play Framework
# Website: https://www.playframework.com/
# Repository: https://github.com/playframework/playframework
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Play Framework application with security hardening
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security
# · COMBINATION: Use standalone for complete Play Framework applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: Play Framework documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Application compilation and optimization
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM eclipse-temurin:17-jdk-alpine AS builder

# Build arguments for environment configuration
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG JAVA_VERSION=17
ARG SCALA_VERSION=2.13
ARG SBT_VERSION=1.9.7

# Environment variables for build process
ENV BUILD_ID=${BUILD_ID} \
    COMMIT_SHA=${COMMIT_SHA} \
    JAVA_VERSION=${JAVA_VERSION} \
    SCALA_VERSION=${SCALA_VERSION} \
    SBT_VERSION=${SBT_VERSION} \
    SBT_OPTS="-Xmx2G -XX:+UseG1GC -XX:+UseStringDeduplication" \
    JAVA_OPTS="-Xmx2G -XX:+UseG1GC"

# Install build dependencies
RUN apk add --no-cache \
    bash \
    curl \
    git \
    openssl

# Install sbt
RUN curl -fsSL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | \
    tar -xz -C /usr/local && \
    ln -s /usr/local/sbt/bin/sbt /usr/local/bin/sbt

WORKDIR /app

# Copy build configuration files first for optimal layer caching
COPY build.sbt project/plugins.sbt project/build.properties ./

# Download dependencies (this layer will be cached unless build files change)
RUN sbt update

COPY . .

# Build Play Framework application
RUN sbt stage

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Production-ready optimized image
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM eclipse-temurin:17-jre-alpine AS runtime

# Build arguments for runtime configuration
ARG APP_PORT=9000
ARG APP_USER=appuser
ARG APP_GROUP=appgroup
ARG APP_UID=1001
ARG APP_GID=1001

# Environment variables for runtime
ENV APP_PORT=${APP_PORT} \
    APP_USER=${APP_USER} \
    APP_GROUP=${APP_GROUP} \
    APP_UID=${APP_UID} \
    APP_GID=${APP_GID} \
    JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -XX:+UseStringDeduplication" \
    JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport"

# Create non-root user and group
RUN addgroup -g ${APP_GID} -S ${APP_GROUP} && \
    adduser -S -u ${APP_UID} -G ${APP_GROUP} ${APP_USER}

WORKDIR /app

# Copy built application from builder stage
COPY --from=builder --chown=${APP_USER}:${APP_GROUP} /app/target/universal/stage ./

# Set proper permissions
RUN chown -R ${APP_USER}:${APP_GROUP} /app && \
    chmod -R 750 /app

# Switch to non-root user
USER ${APP_USER}

EXPOSE ${APP_PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${APP_PORT}/health || exit 1

# Start Play Framework application
STOPSIGNAL SIGTERM
CMD ["./bin/my-app"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build production image
# docker build --target runtime -t my-play-app:prod .

# Example 2: Build with custom application name
# docker build --build-arg APP_NAME=my_app -t my-play-app:prod .

# Example 3: Run development with hot reload
# docker run -d -p 9000:9000 -v $(pwd):/app --name play-dev my-play-app:dev

# Example 4: Run production with resource limits
# docker run -d \
#   -p 9000:9000 \
#   --restart unless-stopped \
#   --memory 512m \
#   --cpus 1.0 \
#   --name play-app \
#   my-play-app:prod

# Example 5: Run with Docker Compose
# docker-compose up -d

# Example 6: Build for multiple architectures
# docker buildx build --platform linux/amd64,linux/arm64 -t my-play-app:multi-arch .

# Example 7: Run with health check verification
# docker run -d -p 9000:9000 --health-cmd="curl -f http://localhost:9000/health || exit 1" --name play-app my-play-app:prod

# Example 8: Run with Java memory settings
# docker run -d -p 9000:9000 -e JAVA_OPTS="-Xmx1g -Xms512m" --name play-app my-play-app:prod

# BEST PRACTICES
# ==============

# Security Best Practices:
# • Always use non-root user for runtime execution
# • Use specific base image versions (avoid 'latest' tags)
# • Set appropriate file permissions for application directories
# • Regularly update Java runtime and Alpine dependencies
# • Scan images for vulnerabilities using tools like Trivy or Grype

# Performance Optimization:
# • Use multi-stage builds to minimize final image size
# • Leverage layer caching by copying build.sbt and project files first
# • Use Alpine base images for smaller footprint
# • Set appropriate Java heap and GC settings for your workload
# • Enable container support with -XX:+UseContainerSupport

# Development Workflow:
# • Use separate development and production Dockerfiles or targets
# • Mount source code as volume for hot reload during development
# • Set up proper .dockerignore to exclude target, project/target, .git
# • Use Docker Compose for local development with databases
# • Implement health checks for container orchestration

# Production Deployment:
# • Use specific version tags for production images
# • Implement proper logging with structured JSON format
# • Set up automated builds and security scanning
# • Use container orchestration (Kubernetes, Docker Swarm) for scaling
# • Implement zero-downtime deployment strategies

# Play Framework-Specific Considerations:
# • Configure appropriate Akka actor system settings
# • Set up database connection pooling with HikariCP
# • Implement proper error handling and logging
# • Set up monitoring for request metrics and performance
# • Use Play's built-in features for caching and sessions
