# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for Traefik
# Website: https://traefik.io/
# Repository: https://github.com/traefik/traefik
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Production-ready Traefik reverse proxy with security hardening
# · DESIGN PHILOSOPHY: Self-contained with security configurations
# · COMBINATION: Use standalone for Traefik load balancer containers
# · SECURITY: TLS termination, access control, network security
# · BEST PRACTICES: Resource limits, monitoring, automatic SSL certificates
# · OFFICIAL SOURCES: Traefik documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Choose appropriate base image based on your needs:

# Option 1: Official Traefik with Alpine (smallest)
FROM traefik:v3.0

# Option 2: Traefik with specific version
# FROM traefik:v3.0-alpine

# Option 3: Specific version with SHA
# FROM traefik:v3.0@sha256:abc123...

# Option 4: Traefik Enterprise Edition
# FROM traefik/traefik-ee:v3.0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG TRAEFIK_VERSION=v3.0
ARG TRAEFIK_API_DASHBOARD=true
ARG TRAEFIK_API_INSECURE=false
ARG TRAEFIK_PROVIDERS_DOCKER=true

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV TRAEFIK_VERSION=${TRAEFIK_VERSION} \
  TRAEFIK_API_DASHBOARD=${TRAEFIK_API_DASHBOARD} \
  TRAEFIK_API_INSECURE=${TRAEFIK_API_INSECURE} \
  TRAEFIK_PROVIDERS_DOCKER=${TRAEFIK_PROVIDERS_DOCKER} \
  TRAEFIK_PROVIDERS_DOCKER_EXPOSEDBYDEFAULT=false \
  TRAEFIK_ENTRYPOINTS_WEB_ADDRESS=:80 \
  TRAEFIK_ENTRYPOINTS_WEBSECURE_ADDRESS=:443 \
  TRAEFIK_CERTIFICATESRESOLVERS_LETSENCRYPT_ACME_EMAIL=admin@example.com \
  TRAEFIK_CERTIFICATESRESOLVERS_LETSENCRYPT_ACME_STORAGE=/letsencrypt/acme.json \
  TZ=UTC \
  LANG=C.UTF-8

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURATION FILES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create configuration directory
RUN mkdir -p /etc/traefik /letsencrypt

# Create dynamic configuration directory
RUN mkdir -p /etc/traefik/dynamic

# Create static Traefik configuration
RUN echo "# Traefik Static Configuration" > /etc/traefik/traefik.yml && \
  echo "api:" >> /etc/traefik/traefik.yml && \
  echo "  dashboard: ${TRAEFIK_API_DASHBOARD}" >> /etc/traefik/traefik.yml && \
  echo "  insecure: ${TRAEFIK_API_INSECURE}" >> /etc/traefik/traefik.yml && \
  echo "" >> /etc/traefik/traefik.yml && \
  echo "entryPoints:" >> /etc/traefik/traefik.yml && \
  echo "  web:" >> /etc/traefik/traefik.yml && \
  echo "    address: ${TRAEFIK_ENTRYPOINTS_WEB_ADDRESS}" >> /etc/traefik/traefik.yml && \
  echo "    http:" >> /etc/traefik/traefik.yml && \
  echo "      redirections:" >> /etc/traefik/traefik.yml && \
  echo "        entryPoint:" >> /etc/traefik/traefik.yml && \
  echo "          to: websecure" >> /etc/traefik/traefik.yml && \
  echo "          scheme: https" >> /etc/traefik/traefik.yml && \
  echo "  websecure:" >> /etc/traefik/traefik.yml && \
  echo "    address: ${TRAEFIK_ENTRYPOINTS_WEBSECURE_ADDRESS}" >> /etc/traefik/traefik.yml && \
  echo "" >> /etc/traefik/traefik.yml && \
  echo "certificatesResolvers:" >> /etc/traefik/traefik.yml && \
  echo "  letsencrypt:" >> /etc/traefik/traefik.yml && \
  echo "    acme:" >> /etc/traefik/traefik.yml && \
  echo "      email: ${TRAEFIK_CERTIFICATESRESOLVERS_LETSENCRYPT_ACME_EMAIL}" >> /etc/traefik/traefik.yml && \
  echo "      storage: ${TRAEFIK_CERTIFICATESRESOLVERS_LETSENCRYPT_ACME_STORAGE}" >> /etc/traefik/traefik.yml && \
  echo "      httpChallenge:" >> /etc/traefik/traefik.yml && \
  echo "        entryPoint: web" >> /etc/traefik/traefik.yml && \
  echo "" >> /etc/traefik/traefik.yml && \
  echo "providers:" >> /etc/traefik/traefik.yml && \
  echo "  docker:" >> /etc/traefik/traefik.yml && \
  echo "    endpoint: unix:///var/run/docker.sock" >> /etc/traefik/traefik.yml && \
  echo "    exposedByDefault: ${TRAEFIK_PROVIDERS_DOCKER_EXPOSEDBYDEFAULT}" >> /etc/traefik/traefik.yml && \
  echo "  file:" >> /etc/traefik/traefik.yml && \
  echo "    directory: /etc/traefik/dynamic" >> /etc/traefik/traefik.yml && \
  echo "    watch: true" >> /etc/traefik/traefik.yml && \
  echo "" >> /etc/traefik/traefik.yml && \
  echo "log:" >> /etc/traefik/traefik.yml && \
  echo "  level: INFO" >> /etc/traefik/traefik.yml && \
  echo "  filePath: /var/log/traefik/traefik.log" >> /etc/traefik/traefik.yml && \
  echo "" >> /etc/traefik/traefik.yml && \
  echo "accessLog:" >> /etc/traefik/traefik.yml && \
  echo "  filePath: /var/log/traefik/access.log" >> /etc/traefik/traefik.yml

# Create dynamic configuration for middleware
RUN echo "# Traefik Dynamic Configuration" > /etc/traefik/dynamic/middlewares.yml && \
  echo "http:" >> /etc/traefik/dynamic/middlewares.yml && \
  echo "  middlewares:" >> /etc/traefik/dynamic/middlewares.yml && \
  echo "    security-headers:" >> /etc/traefik/dynamic/middlewares.yml && \
  echo "      headers:" >> /etc/traefik/dynamic/middlewares.yml && \
  echo "        browserXssFilter: true" >> /etc/traefik/dynamic/middlewares.yml && \
  echo "        contentTypeNosniff: true" >> /etc/traefik/dynamic/middlewares.yml && \
  echo "        frameDeny: true" >> /etc/traefik/dynamic/middlewares.yml && \
  echo "        sslRedirect: true" >> /etc/traefik/dynamic/middlewares.yml && \
  echo "        stsIncludeSubdomains: true" >> /etc/traefik/dynamic/middlewares.yml && \
  echo "        stsPreload: true" >> /etc/traefik/dynamic/middlewares.yml && \
  echo "        stsSeconds: 31536000" >> /etc/traefik/dynamic/middlewares.yml && \
  echo "    rate-limit:" >> /etc/traefik/dynamic/middlewares.yml && \
  echo "      rateLimit:" >> /etc/traefik/dynamic/middlewares.yml && \
  echo "        average: 100" >> /etc/traefik/dynamic/middlewares.yml && \
  echo "        burst: 50" >> /etc/traefik/dynamic/middlewares.yml

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create non-root user for Traefik
RUN addgroup -g 1001 -S traefik && \
  adduser -S -u 1001 -G traefik traefik

# Set proper permissions
RUN chown -R traefik:traefik /etc/traefik /letsencrypt && \
  chmod -R 750 /etc/traefik /letsencrypt

# Create logs directory
RUN mkdir -p /var/log/traefik && \
  chown -R traefik:traefik /var/log/traefik && \
  chmod 750 /var/log/traefik

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Declare persistent data volume
VOLUME /etc/traefik

# Expose Traefik ports
EXPOSE 80    # HTTP
EXPOSE 443   # HTTPS
EXPOSE 8080  # Dashboard/API

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ping || exit 1

# Switch to non-root user
USER traefik

# Run Traefik with configuration
CMD ["traefik", "--configfile=/etc/traefik/traefik.yml"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DOCKER SOCKET ACCESS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Note: To use Docker provider, mount Docker socket:
# -v /var/run/docker.sock:/var/run/docker.sock:ro

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ADDITIONAL CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create additional configuration for specific use cases

# File provider configuration example
RUN echo "# File Provider Configuration Example" > /etc/traefik/dynamic/routers.yml && \
  echo "http:" >> /etc/traefik/dynamic/routers.yml && \
  echo "  routers:" >> /etc/traefik/dynamic/routers.yml && \
  echo "    web-app:" >> /etc/traefik/dynamic/routers.yml && \
  echo "      rule: Host(\`example.com\`)" >> /etc/traefik/dynamic/routers.yml && \
  echo "      service: web-app-service" >> /etc/traefik/dynamic/routers.yml && \
  echo "      entryPoints:" >> /etc/traefik/dynamic/routers.yml && \
  echo "        - websecure" >> /etc/traefik/dynamic/routers.yml && \
  echo "      middlewares:" >> /etc/traefik/dynamic/routers.yml && \
  echo "        - security-headers" >> /etc/traefik/dynamic/routers.yml && \
  echo "      tls:" >> /etc/traefik/dynamic/routers.yml && \
  echo "        certResolver: letsencrypt" >> /etc/traefik/dynamic/routers.yml && \
  echo "    api:" >> /etc/traefik/dynamic/routers.yml && \
  echo "      rule: Host(\`api.example.com\`)" >> /etc/traefik/dynamic/routers.yml && \
  echo "      service: api-service" >> /etc/traefik/dynamic/routers.yml && \
  echo "      entryPoints:" >> /etc/traefik/dynamic/routers.yml && \
  echo "        - websecure" >> /etc/traefik/dynamic/routers.yml && \
  echo "      middlewares:" >> /etc/traefik/dynamic/routers.yml && \
  echo "        - security-headers" >> /etc/traefik/dynamic/routers.yml && \
  echo "        - rate-limit" >> /etc/traefik/dynamic/routers.yml && \
  echo "      tls:" >> /etc/traefik/dynamic/routers.yml && \
  echo "        certResolver: letsencrypt" >> /etc/traefik/dynamic/routers.yml

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Run Traefik with Docker provider
# docker run -d \
#   --name traefik \
#   -p 80:80 \
#   -p 443:443 \
#   -p 8080:8080 \
#   -v /var/run/docker.sock:/var/run/docker.sock:ro \
#   -v traefik_config:/etc/traefik \
#   -v traefik_certs:/letsencrypt \
#   traefik:v3.0

# Example 2: Run with custom configuration
# docker run -d \
#   --name traefik \
#   -p 80:80 \
#   -p 443:443 \
#   -p 8080:8080 \
#   -v ./traefik.yml:/etc/traefik/traefik.yml \
#   -v ./dynamic:/etc/traefik/dynamic \
#   -v traefik_certs:/letsencrypt \
#   traefik:v3.0

# Example 3: Run with environment variables
# docker run -d \
#   --name traefik \
#   -p 80:80 \
#   -p 443:443 \
#   -p 8080:8080 \
#   -e TRAEFIK_API_DASHBOARD=true \
#   -e TRAEFIK_API_INSECURE=false \
#   traefik:prod

# Example 4: Run with Docker Compose
# docker-compose up -d

# Example 5: Development build
# docker build --build-arg TRAEFIK_VERSION=v3.0 -t traefik:dev .

# Example 6: Multi-architecture build
# docker buildx build --platform linux/amd64,linux/arm64 -t traefik:multi-arch .

# Example 7: CI/CD test build
# docker build --no-cache -t traefik:test .

# Example 8: Resource-limited production run
# docker run -d \
#   --name traefik \
#   --memory 256m \
#   --cpus 1.0 \
#   -p 80:80 \
#   -p 443:443 \
#   traefik:prod

# BEST PRACTICES
# ==============
# • SECURITY: Use secure certificates and enable TLS for all public endpoints
# • PERFORMANCE: Configure appropriate buffer sizes and timeouts
# • OPERATIONS: Monitor dashboard access, set up log rotation
# • COMBINATION: Pair with certbot for automatic TLS certificate management
