# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for Elixir
# Website: https://elixir-lang.org/
# Repository: https://github.com/elixir-lang/elixir
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: Elixir runtime environment for modular combination
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: Version pinning, layer optimization, dependency management
# · OFFICIAL SOURCES: Elixir documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE - Elixir runtime with essential dependencies
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM elixir:1.16-alpine

# Build arguments for environment configuration
ARG ELIXIR_VERSION=1.16
ARG ERLANG_VERSION=26

# Environment variables for runtime
ENV ELIXIR_VERSION=${ELIXIR_VERSION} \
    ERLANG_VERSION=${ERLANG_VERSION} \

    MIX_ENV=prod \
    HEX_NO_PROMPT=1 \
    HEX_HTTP_TIMEOUT=120 \
    SHELL=/bin/bash \
    LANG=C.UTF-8

# Install additional runtime dependencies
RUN apk add --no-cache \
    bash \
    build-base \
    ca-certificates \
    curl \
    git \
    openssl \
    tzdata


WORKDIR /app

# Install Hex and Rebar package managers
RUN mix local.hex --force && \
    mix local.rebar --force


# Default command (can be overridden)
CMD ["iex"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Build basic Elixir image:
#    docker build -t my-elixir-app .
#
# 2. Build with custom arguments:
#    docker build \
#      --build-arg ELIXIR_VERSION=1.16 \
#      --build-arg ERLANG_VERSION=26 \
#      --build-arg BUILD_ID=$(git rev-parse --short HEAD) \
#      -t my-elixir-app:$(git rev-parse --short HEAD) .
#
# 3. Run Elixir application:
#    docker run -d \
#      -p 4000:4000 \
#      --name elixir-app \
#      --memory=512m \
#      --cpus=1.0 \
#      my-elixir-app:prod
#
# 4. Development with volume mounting:
#    docker run -d \
#      -p 4000:4000 \
#      -v $(pwd):/app \
#      --name elixir-dev \
#      my-elixir-app:dev
#
# 5. Run with environment variables:
#    docker run -d \
#      -p 4000:4000 \
#      -e DATABASE_URL=postgresql://user:pass@db:5432/mydb \
#      -e MIX_ENV=prod \
#      --name elixir-app \
#      my-elixir-app:prod
#
# 6. Run with health check:
#    docker run -d \
#      -p 4000:4000 \
#      --health-cmd="curl -f http://localhost:4000/health || exit 1" \
#      --health-interval=30s \
#      --name elixir-app \
#      my-elixir-app:prod
#
# 7. Build multi-stage Elixir application:
#    # Use this template as base, then add application-specific build steps
#
# 8. Development with interactive shell:
#    docker run -it \
#      -v $(pwd):/app \
#      --name elixir-shell \
#      my-elixir-app:prod \
#      iex -S mix

# BEST PRACTICES
# ==============
# • VERSION PINNING: Always pin Elixir, Erlang, and dependency versions for reproducibility
# • LAYER OPTIMIZATION: Structure Dockerfile to maximize layer caching efficiency
# • DEPENDENCY MANAGEMENT: Use mix.lock with exact versions for production deployments
# • SECURITY CONFIGURATION: Always run as non-root user in production environments
# • RESOURCE MANAGEMENT: Set appropriate memory and CPU limits for BEAM applications
# • BUILD OPTIMIZATION: Use multi-stage builds to separate build and runtime dependencies
# • TESTING INTEGRATION: Run tests during build process to ensure quality
# • MONITORING: Implement comprehensive logging and health checks for production

# ELIXIR-SPECIFIC CONSIDERATIONS
# • MIX ENVIRONMENTS: Use appropriate MIX_ENV (dev, test, prod) for each stage
# • DEPENDENCY COMPILATION: Compile dependencies during build for faster startup
# • RELEASE MANAGEMENT: Consider using releases for production deployments
# • DISTRIBUTED SYSTEMS: Configure node names and cookies for distributed Elixir
# • HOT CODE UPGRADES: Plan for hot code upgrades in long-running systems
# • OTP APPLICATIONS: Structure applications as proper OTP applications

# SECURITY CONSIDERATIONS
# • DEPENDENCY SCANNING: Regularly scan for vulnerabilities in Hex packages
# • SECRETS MANAGEMENT: Use Docker secrets or environment variables for sensitive data
# • CODE ANALYSIS: Implement static analysis with credo and dialyzer
# • CONTAINER HARDENING: Follow principle of least privilege for container permissions
# • NETWORK SECURITY: Use internal networks and limit exposed ports
# • SSL/TLS CONFIGURATION: Implement proper SSL/TLS for external communications

# PERFORMANCE OPTIMIZATION
# • BEAM VM TUNING: Optimize BEAM VM settings for your workload
# • CONNECTION POOLING: Use appropriate connection pooling for databases
# • CACHE IMPLEMENTATION: Implement caching strategies for frequently accessed data
# • COMPRESSION: Enable compression for API responses and static assets
# • LOAD BALANCING: Implement load balancing for high-traffic applications

# COMBINATION PATTERNS
# • Combine with patterns/multi-stage.Dockerfile for optimized production builds
# • Combine with patterns/security-hardened.Dockerfile for enhanced security
# • Combine with frameworks/phoenix.Dockerfile for web applications
# • Combine with tools/postgresql.Dockerfile for database applications
# • Combine with tools/redis.Dockerfile for caching and pub/sub functionality
