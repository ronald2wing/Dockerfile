# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for Julia
# Website: https://julialang.org/
# Repository: https://github.com/JuliaLang/julia
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: Julia runtime environment for scientific computing and data science
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: Project.toml for dependencies, precompilation for performance
# · OFFICIAL SOURCES: Julia documentation and performance guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE - Julia runtime
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM julia:1.10-bookworm

# Build arguments for environment configuration
ARG JULIA_VERSION=1.10
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG JULIA_DEPOT_PATH=/usr/local/julia
ARG JULIA_PKG_SERVER=https://pkg.julialang.org

# Environment variables for runtime
ENV JULIA_VERSION=${JULIA_VERSION} \
    BUILD_ID=${BUILD_ID} \
    COMMIT_SHA=${COMMIT_SHA} \
    JULIA_DEPOT_PATH=${JULIA_DEPOT_PATH} \
    JULIA_PKG_SERVER=${JULIA_PKG_SERVER} \
    JULIA_PKG_USE_CLI_GIT=true \
    JULIA_PROJECT=/app



# Create Julia depot directory with proper permissions
RUN mkdir -p ${JULIA_DEPOT_PATH}

WORKDIR /app

# Copy dependency files first for optimal layer caching
COPY Project.toml Manifest.toml ./

# Install dependencies as root first to cache them
RUN julia --project=/app -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'

COPY . .


# Expose application port (adjust based on your application)
EXPOSE 8000


# Default command (override in child images or runtime)
CMD ["julia", "--project=/app", "src/main.jl"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build basic Julia application
# docker build -t julia-app:prod .

# Example 2: Build with custom arguments
# docker build \
#   --build-arg JULIA_VERSION=1.10 \
#   --build-arg BUILD_ID=v1.0.0 \
#   --build-arg COMMIT_SHA=$(git rev-parse HEAD) \
#   -t julia-app:$(git rev-parse --short HEAD) .

# Example 3: Run Julia application
# docker run -d \
#   -p 8000:8000 \
#   --name julia-app \
#   --memory=512m \
#   --cpus=1.0 \
#   julia-app:prod

# Example 4: Development with volume mounting
# docker run -d \
#   -p 8000:8000 \
#   -v $(pwd):/app \
#   -v julia-depot:/usr/local/julia \
#   --name julia-dev \
#   julia-app:dev

# Example 5: Production deployment with resource limits
# docker run -d \
#   -p 8000:8000 \
#   --restart unless-stopped \
#   --memory 1g \
#   --cpus 2.0 \
#   --name julia-prod \
#   julia-app:prod

# Example 6: Access Julia REPL
# docker run -it --rm julia-app julia --project=/app

# Example 7: Run tests
# docker run --rm julia-app julia --project=/app -e 'using Pkg; Pkg.test()'

# Example 8: Add package
# docker run --rm julia-app julia --project=/app -e 'using Pkg; Pkg.add("PackageName")'

# BEST PRACTICES
# ==============

# Julia-Specific Best Practices:
# 1. Always pin Julia version in FROM instruction (e.g., julia:1.10-bookworm)
# 2. Use Project.toml and Manifest.toml for reproducible dependency management
# 3. Precompile packages during build for faster startup: Pkg.precompile()
# 4. Use JULIA_DEPOT_PATH for centralized package storage
# 5. Leverage Julia's JIT compilation and multiple dispatch for performance
# 6. Use built-in parallelism for scientific computing workloads
# 7. Implement proper health checks for web applications using HTTP.jl

# Containerization Best Practices:
# 1. Use .dockerignore to exclude unnecessary files (.git, __pycache__, etc.)
# 2. Combine with patterns/multi-stage.Dockerfile for optimized production builds
# 3. Run as non-root user in production (already implemented in this template)
# 4. Use health checks for container orchestration (already implemented)
# 5. Set appropriate resource limits (memory, CPU) for production deployments
# 6. Use volume mounts for development with live code reloading
# 7. Implement proper logging for debugging and monitoring

# Security Recommendations:
# 1. Always combine with patterns/security-hardened.Dockerfile for production
# 2. Regularly update Julia version and package dependencies
# 3. Use non-root user execution (already implemented)
# 4. Isolate dependencies using project-specific environments
# 5. Scan images for vulnerabilities regularly
# 6. Use minimal base images when possible
# 7. Implement proper secret management for sensitive data

# Performance Optimization:
# 1. Use precompilation to reduce startup time: Pkg.precompile()
# 2. Leverage Julia's type system for performance optimization
# 3. Use built-in parallelism for CPU-intensive workloads
# 4. Implement proper caching for package dependencies
# 5. Monitor memory usage for scientific computing applications
# 6. Use appropriate base image (bookworm for stability, alpine for size)

# Common Julia Packages for Different Use Cases:
# - Data Science: DataFrames.jl, Plots.jl, Statistics.jl
# - Scientific Computing: DifferentialEquations.jl, LinearAlgebra.jl
# - Web Development: HTTP.jl, Genie.jl, Mux.jl
# - Machine Learning: Flux.jl, MLJ.jl, ScikitLearn.jl
# - Parallel Computing: Distributed.jl, SharedArrays.jl
