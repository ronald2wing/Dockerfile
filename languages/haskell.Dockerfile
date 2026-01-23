# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for Haskell
# Website: https://www.haskell.org/
# Repository: https://github.com/haskell/haskell-language
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: Haskell runtime environment for modular combination
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: Version pinning, layer optimization, dependency management
# · OFFICIAL SOURCES: Haskell documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE - Haskell runtime with essential dependencies
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM haskell:9.6-alpine

# Build arguments for environment configuration
ARG GHC_VERSION=9.6.4
ARG CABAL_VERSION=3.10.2.0
ARG STACK_VERSION=2.13.1

# Environment variables for runtime
ENV GHC_VERSION=${GHC_VERSION} \
    CABAL_VERSION=${CABAL_VERSION} \
    STACK_VERSION=${STACK_VERSION} \
    CABAL_DIR=/root/.cabal \
    STACK_ROOT=/root/.stack \
    PATH=/root/.cabal/bin:/root/.local/bin:$PATH

# Install additional runtime dependencies
RUN apk add --no-cache \
    bash \
    build-base \
    ca-certificates \
    curl \
    git \
    gmp-dev \
    libffi-dev \
    ncurses-dev \
    openssl \
    tzdata \
    zlib-dev

# Configure cabal
RUN cabal update && \
    cabal user-config init && \
    echo "repository hackage.haskell.org" >> $CABAL_DIR/config && \
    echo "  url: https://hackage.haskell.org/" >> $CABAL_DIR/config && \
    echo "  secure: True" >> $CABAL_DIR/config && \
    echo "  root-keys:" >> $CABAL_DIR/config && \
    echo "  key-threshold: 3" >> $CABAL_DIR/config

# Install stack
RUN curl -fsSL "https://github.com/commercialhaskell/stack/releases/download/v${STACK_VERSION}/stack-${STACK_VERSION}-linux-x86_64.tar.gz" | \
    tar -xz -C /tmp && \
    mv /tmp/stack-${STACK_VERSION}-linux-x86_64/stack /root/.local/bin/stack && \
    chmod +x /root/.local/bin/stack

# Set working directory for application
WORKDIR /app

# Default command (can be overridden)
CMD ["ghci"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Basic Haskell application build:
#    docker build -t haskell-app -f haskell.Dockerfile .
#
# 2. Development environment with mounted source code:
#    docker run -it --rm -v $(pwd):/app haskell-app ghci
#
# 3. Build Haskell project with cabal:
#    docker run -it --rm -v $(pwd):/app haskell-app cabal build
#
# 4. Run Haskell tests:
#    docker run -it --rm -v $(pwd):/app haskell-app cabal test
#
# 5. Install Haskell package globally:
#    docker run -it --rm haskell-app cabal install --lib text
#
# 6. Create Haskell executable with stack:
#    docker run -it --rm -v $(pwd):/app haskell-app stack build
#
# 7. Interactive GHCi session:
#    docker run -it --rm haskell-app
#
# 8. Multi-stage build combining with pattern templates:
#    # Use with patterns/multi-stage.Dockerfile for optimized production builds

# BEST PRACTICES
# ==============
# • Security & Compliance:
#   - Always use version-pinned base images (haskell:9.6-alpine)
#   - Run as non-root user (appuser) to minimize security risks
#   - Use Alpine Linux for smaller attack surface and reduced image size
#   - Regularly update GHC, cabal, and stack versions for security patches
#
# • Performance & Optimization:
#   - Leverage Haskell's lazy evaluation by structuring Docker layers appropriately
#   - Use cabal's dependency caching to speed up builds
#   - Consider using stack for reproducible builds across environments
#   - Optimize GHC compilation flags for production (-O2, -threaded)
#
# • Development & Operations:
#   - Mount local source code for development to enable hot-reload workflows
#   - Use GHCi for interactive development and debugging
#   - Configure cabal and stack for optimal dependency resolution
#   - Set up proper logging and monitoring for Haskell applications
#
# • Haskell-Specific Considerations:
#   - Understand Haskell's runtime system (RTS) options for containerized deployment
#   - Configure garbage collection settings based on application requirements
#   - Use Haskell's strong type system to catch errors at compile time
#   - Consider using Haskell's concurrency features (async, STM) for containerized apps
#
# • Combination Patterns:
#   - Combine with frameworks/haskell-web.Dockerfile for web applications
#   - Use with patterns/multi-stage.Dockerfile for optimized production builds
#   - Integrate with patterns/security-hardened.Dockerfile for enhanced security
#   - Combine with tools/postgresql.Dockerfile for database-backed applications
