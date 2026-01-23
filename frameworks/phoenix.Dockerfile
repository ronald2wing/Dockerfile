# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Phoenix
# Website: https://www.phoenixframework.org/
# Repository: https://github.com/phoenixframework/phoenix
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Phoenix application with security hardening
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security
# · COMBINATION: Use standalone for complete Phoenix applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: Phoenix documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Application compilation and optimization
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM elixir:1.16-alpine AS builder

# Build arguments for environment configuration
ARG MIX_ENV=prod
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG ELIXIR_VERSION=1.16
ARG PHOENIX_VERSION=1.7

# Environment variables for build process
ENV MIX_ENV=${MIX_ENV} \
    BUILD_ID=${BUILD_ID} \
    COMMIT_SHA=${COMMIT_SHA} \
    ELIXIR_VERSION=${ELIXIR_VERSION} \
    PHOENIX_VERSION=${PHOENIX_VERSION} \
    HEX_NO_PROMPT=1 \
    HEX_HTTP_TIMEOUT=120

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    git \
    nodejs \
    npm \
    python3

WORKDIR /app

# Copy dependency files first for optimal layer caching
COPY mix.exs mix.lock ./

# Install production dependencies
RUN mix deps.get --only ${MIX_ENV} && \
    mix deps.compile

COPY . .

# Install Node.js dependencies and build assets
COPY assets/package.json assets/package-lock.json ./assets/
WORKDIR /app/assets
RUN npm ci --no-audit --no-fund && \
    npm run deploy
WORKDIR /app

# Compile Phoenix application
RUN mix phx.digest && \
    mix compile && \
    mix release

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Production-ready optimized image
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM alpine:3.19 AS runtime

# Build arguments for runtime configuration
ARG APP_PORT=4000
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
    MIX_ENV=prod \
    SHELL=/bin/bash \
    LANG=C.UTF-8

# Install runtime dependencies
RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    libgcc \
    libstdc++ \
    ncurses-libs \
    openssl \
    tzdata

# Create non-root user and group
RUN addgroup -g ${APP_GID} -S ${APP_GROUP} && \
    adduser -S -u ${APP_UID} -G ${APP_GROUP} ${APP_USER}

WORKDIR /app

# Copy release from builder stage
COPY --from=builder --chown=${APP_USER}:${APP_GROUP} /app/_build/prod/rel/my_app ./

# Set proper permissions
RUN chown -R ${APP_USER}:${APP_GROUP} /app && \
    chmod -R 750 /app

# Switch to non-root user
USER ${APP_USER}

EXPOSE ${APP_PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:${APP_PORT}/health || exit 1

# Start Phoenix application
STOPSIGNAL SIGTERM
CMD ["./bin/my_app", "start"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build production image
# docker build --target runtime -t my-phoenix-app:prod .

# Example 2: Build with custom application name
# docker build --build-arg APP_NAME=my_app -t my-phoenix-app:prod .

# Example 3: Run development with hot reload
# docker run -d -p 4000:4000 -v $(pwd):/app --name phoenix-dev my-phoenix-app:dev

# Example 4: Run production with resource limits
# docker run -d \
#   -p 4000:4000 \
#   --restart unless-stopped \
#   --memory 256m \
#   --cpus 1.0 \
#   --name phoenix-app \
#   my-phoenix-app:prod

# Example 5: Run with Docker Compose
# docker-compose up -d

# Example 6: Build for multiple architectures
# docker buildx build --platform linux/amd64,linux/arm64 -t my-phoenix-app:multi-arch .

# Example 7: Run with health check verification
# docker run -d -p 4000:4000 --health-cmd="curl -f http://localhost:4000/health || exit 1" --name phoenix-app my-phoenix-app:prod

# Example 8: Run with environment variables
# docker run -d -p 4000:4000 -e MIX_ENV=prod -e DATABASE_URL=postgres://user:pass@db:5432/app --name phoenix-app my-phoenix-app:prod

# BEST PRACTICES
# ==============

# Security Best Practices:
# • Always use non-root user for runtime execution
# • Use specific base image versions (avoid 'latest' tags)
# • Set appropriate file permissions for application directories
# • Regularly update Elixir, Erlang, and Alpine dependencies
# • Scan images for vulnerabilities using tools like Trivy or Grype

# Performance Optimization:
# • Use multi-stage builds to minimize final image size
# • Leverage layer caching by copying mix.exs and mix.lock first
# • Use Alpine base images for smaller footprint
# • Set appropriate resource limits (memory, CPU) in production
# • Enable Erlang distribution for clustering when needed

# Development Workflow:
# • Use separate development and production Dockerfiles or targets
# • Mount source code as volume for hot reload during development
# • Set up proper .dockerignore to exclude _build, deps, node_modules
# • Use Docker Compose for local development with PostgreSQL
# • Implement health checks for container orchestration

# Production Deployment:
# • Use specific version tags for production images
# • Implement proper logging with structured JSON format
# • Set up automated builds and security scanning
# • Use container orchestration (Kubernetes, Docker Swarm) for scaling
# • Implement zero-downtime deployment with hot upgrades

# Phoenix-Specific Considerations:
# • Configure database connection pooling appropriately
# • Set up proper Ecto migrations and seed data
# • Implement proper error handling with Sentry or similar
# • Set up monitoring for request metrics and performance
# • Use Phoenix channels and presence for real-time features
