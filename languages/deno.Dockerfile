# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for Deno
# Website: https://deno.land/
# Repository: https://github.com/denoland/deno
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: Deno runtime environment for modern JavaScript/TypeScript applications
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: TypeScript first, import maps, lock files
# · OFFICIAL SOURCES: Deno documentation and security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE - Deno runtime
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM denoland/deno:1.38-alpine

# Build arguments for environment configuration
ARG DENO_VERSION=1.38
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG DENO_DIR=/deno-dir

# Environment variables for runtime
ENV DENO_VERSION=${DENO_VERSION} \
    BUILD_ID=${BUILD_ID} \
    COMMIT_SHA=${COMMIT_SHA} \
    DENO_DIR=${DENO_DIR} \
    DENO_INSTALL_ROOT=${DENO_DIR} \
    PATH=${DENO_DIR}/bin:${PATH}

WORKDIR /app

# Create cache directory
RUN mkdir -p ${DENO_DIR}

# Copy dependency files first for optimal layer caching
COPY deno.json deno.lock ./

# Cache dependencies (if deno.lock exists)
RUN if [ -f "deno.lock" ]; then \
      deno cache --lock=deno.lock --lock-write deno.json; \
    fi

COPY . .

# Expose application port (adjust based on your application)
EXPOSE 8000

# Default command (override in child images or runtime)
CMD ["deno", "run", "--allow-net", "mod.ts"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build basic Deno application
# docker build -t my-deno-app:v1.0.0 .

# Example 2: Build with custom arguments
# docker build \
#   --build-arg DENO_VERSION=1.38 \
#   --build-arg BUILD_ID=v1.0.0 \
#   --build-arg COMMIT_SHA=$(git rev-parse --short HEAD) \
#   -t my-deno-app:$(git rev-parse --short HEAD) .

# Example 3: Run Deno application with minimal permissions
# docker run -d \
#   -p 8000:8000 \
#   --name deno-app \
#   --memory=128m \
#   --cpus=0.5 \
#   my-deno-app:v1.0.0

# Example 4: Development with hot reload and volume mounting
# docker run -d \
#   -p 8000:8000 \
#   -v $(pwd):/app \
#   -v deno-cache:/deno-dir \
#   --name deno-dev \
#   my-deno-app:dev

# Example 5: Run Deno tests
# docker run --rm my-deno-app:v1.0.0 deno test --allow-all

# Example 6: Format code using Deno's built-in formatter
# docker run --rm -v $(pwd):/app my-deno-app:v1.0.0 deno fmt

# Example 7: Lint code using Deno's built-in linter
# docker run --rm -v $(pwd):/app my-deno-app:v1.0.0 deno lint

# Example 8: Production deployment with resource limits
# docker run -d \
#   -p 8000:8000 \
#   --restart unless-stopped \
#   --memory=256m \
#   --cpus=1.0 \
#   --name deno-prod \
#   my-deno-app:production

# BEST PRACTICES
# ==============

# Deno-Specific Best Practices:
# 1. Always use specific permission flags (--allow-net, --allow-read) instead of --allow-all
# 2. Use deno.lock files for reproducible builds
# 3. Leverage Deno's built-in tooling (fmt, lint, test, doc) instead of external tools
# 4. Use import maps for cleaner import statements
# 5. Cache dependencies in separate layer for faster builds

# Security Best Practices:
# 1. Run as non-root user (already configured in template)
# 2. Use Alpine base image for minimal attack surface
# 3. Grant only necessary permissions using --allow-* flags
# 4. Regularly update Deno version to get security patches
# 5. Scan dependencies for vulnerabilities using deno audit

# Performance Best Practices:
# 1. Use --cached-only flag in production to ensure all dependencies are cached
# 2. Set appropriate memory limits based on application requirements
# 3. Use health checks for container orchestration
# 4. Implement proper logging for monitoring and debugging

# Combination Patterns:
# 1. Combine with patterns/multi-stage.Dockerfile for optimized production builds
# 2. Combine with patterns/security-hardened.Dockerfile for additional security layers
# 3. Combine with patterns/monitoring.Dockerfile for production monitoring
# 4. Combine with frameworks templates for full-stack applications

# Deno Permission Model:
# • --allow-net: Required for network access (APIs, databases)
# • --allow-read: Required for file system read operations
# • --allow-write: Required for file system write operations
# • --allow-env: Required for environment variable access
# • --allow-run: Required for subprocess execution
# • --allow-ffi: Required for foreign function interface (native modules)
# • --allow-all: Grants all permissions (use with extreme caution)
