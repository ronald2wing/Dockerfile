# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Django
# Website: https://www.djangoproject.com/
# Repository: https://github.com/django/django
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Django application with security hardening
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security
# · COMBINATION: Use standalone for complete Django applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: Django documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Application compilation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM python:3.11-alpine AS builder

# Build arguments for environment configuration
ARG PYTHON_ENV=production
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown

# Environment variables for build process
ENV PYTHON_ENV=${PYTHON_ENV} \
  BUILD_ID=${BUILD_ID} \
  COMMIT_SHA=${COMMIT_SHA} \
  PYTHONUNBUFFERED=1 \
  PYTHONDONTWRITEBYTECODE=1 \
  PIP_NO_CACHE_DIR=1 \
  PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# Copy dependency files first for optimal layer caching
COPY requirements*.txt ./

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
  pip install --no-cache-dir -r requirements.txt

COPY . .

# Collect static files (Django specific)
RUN python manage.py collectstatic --noinput --clear

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Production deployment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM python:3.11-alpine AS runtime

ARG PYTHON_VERSION=3.11

# Security: Create non-root user
RUN addgroup -g 1001 -S appgroup && \
  adduser -S -u 1001 -G appgroup appuser

# Production environment configuration
ENV PYTHON_ENV=production \
  PYTHONUNBUFFERED=1 \
  PYTHONDONTWRITEBYTECODE=1 \
  UMASK=0027

WORKDIR /app

# Install runtime dependencies only
RUN apk add --no-cache \
  libpq \
  zlib \
  jpeg \
  libffi

# Copy installed dependencies from builder stage
COPY --from=builder /usr/local/lib/python${PYTHON_VERSION}/site-packages /usr/local/lib/python${PYTHON_VERSION}/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy application code with proper ownership
COPY --from=builder --chown=appuser:appgroup /app /app

# Copy collected static files
COPY --from=builder --chown=appuser:appgroup /app/staticfiles /app/staticfiles

# Create directories with secure permissions
RUN mkdir -p /app/logs /app/media && \
  chown -R appuser:appgroup /app/logs /app/media && \
  chmod 750 /app/logs /app/media

# Switch to non-root user
USER appuser

EXPOSE 8000

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; \
  urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# Default command with Gunicorn
STOPSIGNAL SIGTERM
ENTRYPOINT ["gunicorn"]
CMD ["--bind", "0.0.0.0:8000", "--workers", "3", "--worker-class", "sync", "project.wsgi:application"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT STAGE - Hot reload environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM python:3.11-alpine AS development

WORKDIR /app

# Install system dependencies including dev tools
RUN apk add --no-cache \
  build-base \
  ca-certificates \
  postgresql-dev \
  zlib-dev \
  jpeg-dev \
  libffi-dev

COPY requirements*.txt ./

# Install all dependencies (including dev dependencies)
RUN pip install --no-cache-dir --upgrade pip && \
  pip install --no-cache-dir -r requirements-dev.txt

COPY . .

# Development command with Django runserver
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Build production image
# docker build --target runtime -t my-django-app:prod .

# Example 2: Build development image
# docker build --target development -t my-django-app:dev .

# Example 3: Build with custom arguments
# docker build \
#   --build-arg PYTHON_ENV=production \
#   --build-arg BUILD_ID=$(git rev-parse --short HEAD) \
#   -t my-django-app:$(git rev-parse --short HEAD) .

# Example 4: Run production container
# docker run -d -p 8000:8000 --name django-app my-django-app:prod

# Example 5: Run development container with volume mount
# docker run -d -p 8000:8000 -v $(pwd):/app --name django-dev my-django-app:dev

# Best Practices:
# 1. Always use .dockerignore to exclude __pycache__, .git, etc.
# 2. Use specific Python versions (not 'latest')
# 3. Run health checks in production
# 4. Use multi-stage builds for smaller images
# 5. Set resource limits in docker-compose or Kubernetes

# Customization Notes:
# 1. Adjust Gunicorn workers based on available CPU cores
# 2. Modify exposed ports based on your application
# 3. Customize health check endpoint as needed
# 4. Add environment variables for database connections
# 5. Configure static/media file storage appropriately
