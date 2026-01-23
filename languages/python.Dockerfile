# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for Python
# Website: https://python.org/
# Repository: https://github.com/python/cpython
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: Python runtime configuration for Docker containers
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: Use with multi-stage builds for production deployments
# · OFFICIAL SOURCES: Python documentation and Docker best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Choose appropriate base image based on your needs:

# Option 1: Alpine (smallest, ~40MB) - Recommended for production
FROM python:3.11-alpine

# Option 2: Slim (Debian-based, smaller than full, ~120MB)
# FROM python:3.11-slim

# Option 3: Full (includes build tools, ~900MB) - For development
# FROM python:3.11

# Option 4: Specific version with SHA for reproducibility
# FROM python:3.11-alpine@sha256:abc123...

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG PYTHON_VERSION=3.11
ARG PYTHON_ENV=production
ARG BUILD_ID=unknown
ARG PIP_VERSION=24.0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV PYTHON_VERSION=${PYTHON_VERSION} \
    PYTHON_ENV=${PYTHON_ENV} \
    BUILD_ID=${BUILD_ID} \
    PIP_VERSION=${PIP_VERSION} \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONPATH=/app

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# WORKDIR SETUP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WORKDIR /app

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SYSTEM DEPENDENCIES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Install system dependencies (adjust based on your needs)

# For Alpine base images:
RUN apk add --no-cache \
    build-base \
    ca-certificates \
    curl

# For Debian-based images, use:
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     build-essential \
#     ca-certificates \
#     curl \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEPENDENCY MANAGEMENT PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COPY requirements*.txt ./

# Pattern 1: Production dependencies only (recommended for production)
RUN pip install --no-cache-dir --upgrade pip==${PIP_VERSION} && \
    pip install --no-cache-dir -r requirements.txt

# Pattern 2: Development dependencies
# RUN pip install --no-cache-dir --upgrade pip==${PIP_VERSION} && \
#     pip install --no-cache-dir -r requirements-dev.txt

# Pattern 3: With virtual environment (better isolation)
# RUN python -m venv /opt/venv && \
#     /opt/venv/bin/pip install --no-cache-dir --upgrade pip==${PIP_VERSION} && \
#     /opt/venv/bin/pip install --no-cache-dir -r requirements.txt && \
#     ln -s /opt/venv/bin/python /usr/local/bin/python-app

# Pattern 4: Poetry package manager (modern Python packaging)
# RUN pip install --no-cache-dir poetry==1.5.0 && \
#     poetry config virtualenvs.create false && \
#     poetry install --no-dev --no-interaction --no-ansi

# Pattern 5: Pipenv package manager
# RUN pip install --no-cache-dir pipenv==2023.6.0 && \
#     pipenv install --deploy --system

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APPLICATION DEPLOYMENT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COPY . .

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Expose port (customize for your application)
EXPOSE 8000

# Create logs directory with proper permissions
RUN mkdir -p /app/logs && chmod 755 /app/logs

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT & COMMAND OPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Option 1: Direct Python execution (simple scripts)
# ENTRYPOINT ["python"]
# CMD ["app.py"]

# Option 2: Gunicorn for WSGI web applications (recommended for production)
# ENTRYPOINT ["gunicorn"]
# CMD ["--bind", "0.0.0.0:8000", "--workers", "4", "--worker-class", "sync", "wsgi:app"]

# Option 3: Uvicorn for ASGI applications (FastAPI, Starlette)
# ENTRYPOINT ["uvicorn"]
# CMD ["main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]

# Option 4: Custom entrypoint script (most flexible)
# COPY entrypoint.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/entrypoint.sh
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# CMD ["python", "app.py"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECK OPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Option 1: HTTP health check (for web applications)
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD python -c "import urllib.request; \
#     urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# Option 2: Process health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD pgrep python || exit 1

# Option 3: Custom health check script
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD /app/scripts/healthcheck.sh

# Option 4: Simple curl health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD curl -f http://localhost:8000/health || exit 1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Development-specific configurations (uncomment as needed)

# Install development dependencies
# RUN pip install --no-cache-dir -r requirements-dev.txt

# Install debugging tools
# RUN pip install --no-cache-dir ipython debugpy

# Development command with hot reload
# CMD ["python", "-m", "debugpy", "--listen", "0.0.0.0:5678", "--wait-for-client", "app.py"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PERFORMANCE OPTIMIZATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Uncomment optimizations as needed:

# Pre-compile Python bytecode for faster startup
# RUN python -m compileall .

# Install optimized packages (compile from source)
# RUN pip install --no-cache-dir --no-binary :all: numpy

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMBINATION GUIDANCE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Complete production setup:
# 1. Start with this template
# 2. Add patterns/multi-stage.Dockerfile for multi-stage builds
# 3. Add patterns/security-hardened.Dockerfile for security
# 4. Add patterns/docker-compose.Dockerfile if using Docker Compose

# Example combination:
# cat languages/python.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/security-hardened.Dockerfile \
#     patterns/docker-compose.Dockerfile > Dockerfile

# Important: This template does NOT include security configurations.
# Always combine with patterns/security-hardened.Dockerfile for production.

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Build basic Python image:
#    docker build -t my-python-app .
#
# 2. Build with custom arguments:
#    docker build \
#      --build-arg PYTHON_VERSION=3.11 \
#      --build-arg PYTHON_ENV=production \
#      --build-arg BUILD_ID=$(git rev-parse --short HEAD) \
#      -t my-python-app:$(git rev-parse --short HEAD) .
#
# 3. Run Python application:
#    docker run -d \
#      -p 8000:8000 \
#      --name python-app \
#      --memory=512m \
#      --cpus=1.0 \
#      my-python-app:v1.0.0
#
# 4. Development with volume mounting:
#    docker run -d \
#      -p 8000:8000 \
#      -v $(pwd):/app \
#      --name python-dev \
#      my-python-app:dev
#
# 5. Run with environment variables:
#    docker run -d \
#      -p 8000:8000 \
#      -e DATABASE_URL=postgresql://user:pass@db:5432/mydb \
#      -e DEBUG=false \
#      --name python-app \
#      my-python-app:v1.0.0
#
# 6. Run with health check:
#    docker run -d \
#      -p 8000:8000 \
#      --health-cmd="curl -f http://localhost:8000/health || exit 1" \
#      --health-interval=30s \
#      --name python-app \
#      my-python-app:v1.0.0
#
# 7. Build multi-stage Python application:
#    # Use this template as base, then add application-specific build steps
#
# 8. Development with debugging:
#    docker run -d \
#      -p 8000:8000 \
#      -p 5678:5678 \
#      -v $(pwd):/app \
#      --name python-debug \
#      my-python-app:dev

# BEST PRACTICES
# ==============
# • VERSION PINNING: Always pin Python, pip, and package versions for reproducibility
# • LAYER OPTIMIZATION: Structure Dockerfile to maximize layer caching efficiency
# • DEPENDENCY MANAGEMENT: Use requirements.txt with exact versions for production
# • SECURITY CONFIGURATION: Always run as non-root user in production environments
# • RESOURCE MANAGEMENT: Set appropriate memory and CPU limits for Python applications
# • BUILD OPTIMIZATION: Use multi-stage builds to separate build and runtime dependencies
# • TESTING INTEGRATION: Run tests during build process to ensure quality
# • MONITORING: Implement comprehensive logging and health checks for production

# PYTHON-SPECIFIC CONSIDERATIONS
# • VIRTUAL ENVIRONMENTS: Consider using venv for better dependency isolation
# • PACKAGE MANAGERS: Choose appropriate package manager (pip, poetry, pipenv)
# • WHEEL CACHING: Use pip wheel caching for faster builds
# • BYTECODE COMPILATION: Pre-compile Python bytecode for faster startup times
# • GIL CONSIDERATIONS: Understand Python's Global Interpreter Lock for multi-threading
# • ASYNC SUPPORT: Consider async/await patterns for I/O-bound applications

# SECURITY CONSIDERATIONS
# • DEPENDENCY SCANNING: Regularly scan for vulnerabilities with safety or bandit
# • SECRETS MANAGEMENT: Use Docker secrets or environment variables for sensitive data
# • CODE ANALYSIS: Implement static analysis with pylint, mypy, or black
# • CONTAINER HARDENING: Follow principle of least privilege for container permissions
# • NETWORK SECURITY: Use internal networks and limit exposed ports

# COMBINATION PATTERNS
# • Combine with patterns/multi-stage.Dockerfile for optimized production builds
# • Combine with patterns/security-hardened.Dockerfile for enhanced security
# • Combine with frameworks/django.Dockerfile for web applications
# • Combine with frameworks/fastapi.Dockerfile for modern API development
# • Combine with tools/postgresql.Dockerfile for database applications
