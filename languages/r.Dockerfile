# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for R
# Website: https://www.r-project.org/
# Repository: https://github.com/wch/r-source
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: R runtime environment for statistical computing and data analysis
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: Reproducible research, package version pinning
# · OFFICIAL SOURCES: R documentation and CRAN guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE - R runtime with tidyverse
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM rocker/tidyverse:4.3

# Build arguments for environment configuration
ARG R_VERSION=4.3
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG CRAN_MIRROR=https://cran.r-project.org
ARG R_LIBS_USER=/usr/local/lib/R/site-library

# Environment variables for runtime
ENV R_VERSION=${R_VERSION} \
    BUILD_ID=${BUILD_ID} \
    COMMIT_SHA=${COMMIT_SHA} \
    CRAN_MIRROR=${CRAN_MIRROR} \
    R_LIBS_USER=${R_LIBS_USER} \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# Create R library directory with proper permissions
RUN mkdir -p ${R_LIBS_USER}

WORKDIR /app

# Copy dependency files first for optimal layer caching
COPY DESCRIPTION ./

# Install system dependencies for common R packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libudunits2-dev \
    libgdal-dev \
    libproj-dev \
    libgeos-dev && \
    rm -rf /var/lib/apt/lists/*

# Install R packages from DESCRIPTION file
RUN if [ -f "DESCRIPTION" ]; then \
      Rscript -e "options(repos = c(CRAN = '${CRAN_MIRROR}')); \
                  install.packages('renv'); \
                  renv::restore()"; \
    fi

COPY . .

# Expose application port (adjust based on your application)
EXPOSE 8080

# Default command (override in child images or runtime)
CMD ["Rscript", "src/main.R"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Basic R application build:
#    docker build -t r-app -f r.Dockerfile .
#
# 2. Development environment with mounted source code:
#    docker run -it --rm -v $(pwd):/app -p 8080:8080 r-app Rscript src/main.R
#
# 3. Build R project with custom R version:
#    docker build --build-arg R_VERSION=4.2 -t r-app .
#
# 4. Run R tests:
#    docker run -it --rm -v $(pwd):/app r-app Rscript -e "testthat::test_dir('tests')"
#
# 5. Production deployment with Shiny:
#    docker build -t shiny-app -f r.Dockerfile .
#    docker run -d -p 3838:3838 --name shiny-app shiny-app
#
# 6. Interactive R console:
#    docker run -it --rm r-app R
#
# 7. Multi-stage build combining with pattern templates:
#    cat languages/r.Dockerfile patterns/multi-stage.Dockerfile > Dockerfile
#    docker build -t optimized-r-app .
#
# 8. Data science workflow with Jupyter:
#    cat languages/r.Dockerfile tools/jupyter.Dockerfile > Dockerfile
#    docker build -t r-jupyter-app .

# BEST PRACTICES
# ==============
# • Security & Compliance:
#   - Always use version-pinned base images (rocker/tidyverse:4.3)
#   - Run as non-root user (ruser) to minimize security risks
#   - Use renv for reproducible package management and isolation
#   - Regularly update R, system packages, and CRAN packages for security patches
#
# • Performance & Optimization:
#   - Leverage R's package caching by mounting R library directories
#   - Use multi-stage builds to separate build dependencies from runtime
#   - Optimize R memory settings based on container resource limits
#   - Consider using R's native serialization for faster data loading
#
# • Development & Operations:
#   - Mount local source code for development to enable interactive analysis
#   - Use renv for consistent package versions across environments
#   - Configure proper health checks for container orchestration (Kubernetes, Docker Swarm)
#   - Set up logging and monitoring for R applications (Shiny, Plumber APIs)
#
# • R-Specific Considerations:
#   - Understand R's memory management for large datasets
#   - Configure R's garbage collection settings based on application requirements
#   - Use R's package system for modular code organization
#   - Consider using R's parallel processing capabilities for computationally intensive tasks
#
# • Combination Patterns:
#   - Combine with tools/jupyter.Dockerfile for interactive data science notebooks
#   - Use with patterns/multi-stage.Dockerfile for optimized production builds
#   - Integrate with patterns/security-hardened.Dockerfile for enhanced security
#   - Combine with tools/postgresql.Dockerfile for database-backed applications
#   - Use with patterns/alpine.Dockerfile for smaller image sizes
