# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for FastAPI
# Website: https://fastapi.tiangolo.com/
# Repository: https://github.com/tiangolo/fastapi
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready FastAPI application with security hardening
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security
# · COMBINATION: Use standalone for complete FastAPI applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: FastAPI documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Dependency installation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM python:3.11-alpine AS builder

# Build arguments for environment configuration
ARG PYTHONUNBUFFERED=1
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown

# Environment variables for build process
ENV PYTHONUNBUFFERED=${PYTHONUNBUFFERED} \
  BUILD_ID=${BUILD_ID} \
  COMMIT_SHA=${COMMIT_SHA} \
  PYTHONDONTWRITEBYTECODE=1 \
  PIP_NO_CACHE_DIR=1 \
  PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# Copy dependency files first for optimal layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --user -r requirements.txt

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Production deployment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM python:3.11-alpine AS runtime

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S -u 1001 -G appgroup appuser

# Production environment configuration
ENV PYTHONUNBUFFERED=1 \
  PYTHONDONTWRITEBYTECODE=1 \
  PATH="/home/appuser/.local/bin:${PATH}" \
  UMASK=0027

WORKDIR /app

# Copy Python dependencies from builder stage
COPY --from=builder --chown=appuser:appgroup /root/.local /home/appuser/.local

COPY --chown=appuser:appgroup . .

# Switch to non-root user
USER appuser

# Create directories with secure permissions
RUN mkdir -p /app/logs /app/tmp && \
  chmod 750 /app/logs /app/tmp

EXPOSE 8000

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; \
  try: \
    urllib.request.urlopen('http://localhost:8000/health'); \
    exit(0) \
  except: \
    exit(1)"

# Run FastAPI application with Uvicorn
STOPSIGNAL SIGTERM
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT STAGE - Hot reload environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM python:3.11-alpine AS development

WORKDIR /app

# Install system dependencies for development
RUN apk add --no-cache \
  gcc \
  musl-dev \
  libffi-dev \
  openssl-dev

COPY requirements.txt .

# Install Python dependencies including dev dependencies
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Development command with hot reload
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Build production image
# docker build --target runtime -t my-fastapi-app:prod .

# Example 2: Build development image
# docker build --target development -t my-fastapi-app:dev .

# Example 3: Build with custom arguments
# docker build \
#   --build-arg BUILD_ID=$(git rev-parse --short HEAD) \
#   -t my-fastapi-app:$(git rev-parse --short HEAD) .

# Example 4: Run production container
# docker run -d -p 8000:8000 --name fastapi-app my-fastapi-app:prod

# Example 5: Run development container
# docker run -d -p 8000:8000 -v $(pwd):/app --name fastapi-dev my-fastapi-app:dev

# Best Practices:
# 1. Always use .dockerignore to exclude __pycache__, .git, etc.
# 2. Use specific Python versions (not 'latest')
# 3. Run health checks in production
# 4. Use multi-stage builds for smaller images
# 5. Set resource limits in docker-compose or Kubernetes

# Customization Notes:
# 1. Adjust Uvicorn workers based on your CPU cores
# 2. Modify health check endpoint as needed
# 3. Add environment variables for your application
# 4. Customize requirements.txt for your dependencies
# 5. Consider adding Gunicorn for production with multiple workers
