# ==============================================================================
# Created by https://Dockerfile.io/
# Pattern TEMPLATE for Security Hardening
# Website: https://docs.docker.com/
# Repository: https://github.com/docker-library/official-images
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Pattern
# · PURPOSE: Security hardening patterns for all Docker projects
# · DESIGN PHILOSOPHY: Modular security patterns for combination
# · COMBINATION: Combine with language or framework templates
# · SECURITY: Critical protection for production deployments
# · BEST PRACTICES: Follows CIS Docker Benchmark and OWASP guidelines
# · OFFICIAL SOURCES: Docker security documentation and community best practices
#
# IMPORTANT: Always include this template in production deployments.

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USER SECURITY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CRITICAL: Never run containers as root in production

RUN addgroup -g 1001 -S appgroup && \
  adduser -S -u 1001 -G appgroup appuser

# Alternative: Use existing non-root user if available
# USER node  # For Node.js images
# USER nginx # For Nginx images

# Switch to non-root user
USER appuser

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FILE PERMISSIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Set secure default permissions

# Set proper umask (027 = owner read/write/execute, group read/execute, others none)
ENV UMASK=0027

RUN mkdir -p /app/logs /app/tmp /app/data && \
  chown -R appuser:appgroup /app && \
  chmod -R 750 /app && \
  chmod 755 /app

COPY --chown=appuser:appgroup . /app

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT SECURITY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Secure environment variable configuration

# Production environment
ENV NODE_ENV=production \
  # Disable npm update notifications
  npm_config_update_notifier=false \
  # Set language and encoding
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8 \
  # Disable Python bytecode generation
  PYTHONDONTWRITEBYTECODE=1 \
  # Force Python to stdout/stderr unbuffered
  PYTHONUNBUFFERED=1 \
  # Disable .NET telemetry
  DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  # Disable Next.js telemetry
  NEXT_TELEMETRY_DISABLED=1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PACKAGE MANAGER SECURITY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Secure package installation patterns

# npm security
RUN npm config set audit true && \
  npm config set fund false && \
  npm config set update-notifier false

# pip security
RUN pip config set global.disable-pip-version-check true

# apt security (Debian/Ubuntu)
RUN apt-get update && \
  apt-get install -y --no-install-recommends package-name && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# apk security (Alpine)
RUN apk add --no-cache --virtual .build-deps package-name && \
  apk del .build-deps

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NETWORK SECURITY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Network security configurations

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Alternative health checks:
# CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
# CMD nc -z localhost 3000 || exit 1
# CMD pgrep process-name || exit 1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME SECURITY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Runtime security configurations

# Set resource limits (to be used with docker run or docker-compose)
# docker run --memory=512m --cpus=1.0 myapp

# Set read-only root filesystem (if possible)
# docker run --read-only myapp

# Set no-new-privileges
# docker run --security-opt=no-new-privileges myapp

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY SCANNING INTEGRATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Patterns for security scanning in CI/CD

# Stage for security scanning
FROM runtime AS security-scan

USER root
RUN apk add --no-cache \
  curl \
  jq

COPY --chown=root:root security-scan.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/security-scan.sh

USER appuser

# Note: This stage doesn't have CMD/ENTRYPOINT

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Combine with language template
# cat languages/node.Dockerfile \
#     patterns/security-hardened.Dockerfile > Dockerfile

# Example 2: Complete production setup
# cat languages/python.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/security-hardened.Dockerfile \
#     patterns/docker-compose.Dockerfile > Dockerfile

# Example 3: Security scanning in CI/CD
# docker build --target security-scan -t myapp:scan .
# docker run --rm myapp:scan /usr/local/bin/security-scan.sh

# Example 4: Production deployment with security
# docker run -d \
#   --name myapp \
#   --user 1001:1001 \
#   --read-only \
#   --security-opt=no-new-privileges \
#   --memory=512m \
#   --cpus=1.0 \
#   myapp:prod

# Example 5: Security checklist verification
# docker run --rm \
#   -v /var/run/docker.sock:/var/run/docker.sock \
#   aquasec/trivy image myapp:prod

# Example 6: Multi-stage with security
# cat languages/java.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/security-hardened.Dockerfile \
#     patterns/ci-cd.Dockerfile > Dockerfile

# BEST PRACTICES
# ==============

# 1. Security Best Practices:
#    • Always use specific base image versions (no 'latest' tag)
#    • Always run as non-root user in production
#    • Use multi-stage builds to exclude build tools
#    • Scan images for vulnerabilities (trivy, grype, docker scan)
#    • Use .dockerignore to exclude sensitive files
#    • Set resource limits in production
#    • Use health checks for container orchestration
#    • Sign images with cosign or similar tools
#    • Use secrets management (Docker secrets, external vaults)
#    • Regularly update base images and dependencies

# 2. Security Checklist:
#    ✅ User Security: Non-root user, specific UID/GID, user switched before runtime
#    ✅ File Permissions: Secure umask (0027), proper directory permissions, files owned by non-root user
#    ✅ Environment Security: Production environment, telemetry disabled, secure defaults
#    ✅ Network Security: Only necessary ports exposed, health checks, network policies
#    ✅ Package Security: No unnecessary packages, caches cleaned, security updates
#    ✅ Runtime Security: Resource limits, read-only filesystem, no new privileges

# 3. Security Considerations:
#    • This template provides security patterns only
#    • Combine with language-specific templates for complete solutions
#    • Adjust UID/GID based on your environment requirements
#    • Test security configurations in staging before production
#    • Regularly review and update security practices
#    • Consider compliance requirements (GDPR, HIPAA, PCI-DSS)
#    • Implement defense in depth (multiple security layers)
#    • Monitor containers for security incidents
#    • Use secrets management for sensitive data
#    • Follow principle of least privilege

# 4. Combination Patterns:
#    • This template is designed to be combined with language/framework templates
#    • Always combine with multi-stage.Dockerfile for production optimization
#    • Use ci-cd.Dockerfile for automated security scanning
#    • Consider adding monitoring.Dockerfile for security observability

# 5. Testing Recommendations:
#    • Run security scans in CI/CD pipeline
#    • Test with different security configurations
#    • Validate non-root user functionality
#    • Test health check endpoints
#    • Verify resource limits work correctly
