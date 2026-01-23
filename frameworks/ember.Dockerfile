# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Ember
# Website: https://emberjs.com/
# Repository: https://github.com/emberjs/ember.js
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Ember application with security hardening
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security
# · COMBINATION: Use standalone for complete Ember applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: Ember documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Application compilation and optimization
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS builder

# Build arguments for environment configuration
ARG NODE_ENV=production
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG NODE_VERSION=18

# Environment variables for build process
ENV NODE_ENV=${NODE_ENV} \
    BUILD_ID=${BUILD_ID} \
    COMMIT_SHA=${COMMIT_SHA} \
    NODE_VERSION=${NODE_VERSION} \
    npm_config_update_notifier=false \
    npm_config_cache=/tmp/.npm \
    EMBER_CLI_DISABLE_UI=true

WORKDIR /app

# Copy dependency files first for optimal layer caching
COPY package*.json ./

# Install dependencies with security optimizations
RUN npm ci --no-audit --no-fund && \
    npm cache clean --force

COPY . .

# Build Ember application for production
RUN npx ember build --environment=production

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Production-ready optimized image
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM nginx:1.25-alpine AS runtime

# Build arguments for runtime configuration
ARG NGINX_VERSION=1.25
ARG APP_PORT=80
ARG APP_USER=appuser
ARG APP_GROUP=appgroup
ARG APP_UID=1001
ARG APP_GID=1001

# Environment variables for runtime
ENV NGINX_VERSION=${NGINX_VERSION} \
    APP_PORT=${APP_PORT} \
    APP_USER=${APP_USER} \
    APP_GROUP=${APP_GROUP} \
    APP_UID=${APP_UID} \
    APP_GID=${APP_GID}

# Create non-root user and group
RUN addgroup -g ${APP_GID} -S ${APP_GROUP} && \
    adduser -S -u ${APP_UID} -G ${APP_GROUP} ${APP_USER}

# Configure nginx for Ember SPA
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY <<'EOF' /etc/nginx/nginx.conf
worker_processes auto;
pid /tmp/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging configuration
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log warn;

    # Basic security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Performance optimizations
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 10m;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;

    # SPA routing configuration for Ember
    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;

        root /usr/share/nginx/html;
        index index.html;

        # Security headers
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:;" always;

        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # SPA routing - redirect all non-file requests to index.html
        location / {
            try_files $uri $uri/ /index.html;
            expires -1;
            add_header Cache-Control "no-store, no-cache, must-revalidate";
        }

        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

# Set proper permissions
RUN chown -R ${APP_USER}:${APP_GROUP} /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html && \
    chown -R ${APP_USER}:${APP_GROUP} /var/log/nginx && \
    chown -R ${APP_USER}:${APP_GROUP} /var/cache/nginx && \
    chown -R ${APP_USER}:${APP_GROUP} /etc/nginx

# Switch to non-root user
USER ${APP_USER}

EXPOSE ${APP_PORT}

STOPSIGNAL SIGTERM

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${APP_PORT}/health || exit 1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Production build
# docker build --target runtime -t ember-app .
# docker run -p 80:80 ember-app

# Example 2: Development with hot reload
# docker build --target development -t ember-dev .
# docker run -p 3000:3000 -v $(pwd):/app ember-dev

# Example 3: Multi-stage build with specific stage
# docker build --target builder -t ember-builder .
# docker build --target runtime -t ember-prod .

# Example 4: Build with custom arguments
# docker build \
#   --build-arg NODE_ENV=production \
#   --build-arg PORT=8080 \
#   --target runtime \
#   -t ember-custom .

# Example 5: Complete CI/CD pipeline
# docker build \
#   --build-arg BUILD_ID=$CI_PIPELINE_ID \
#   --build-arg COMMIT_SHA=$CI_COMMIT_SHA \
#   --target runtime \
#   -t ember:$CI_COMMIT_SHA .

# Example 6: With PostgreSQL database
# cat frameworks/ember.Dockerfile tools/postgresql.Dockerfile > Dockerfile
# docker build -t ember-with-db .

# Example 7: With security hardening
# cat frameworks/ember.Dockerfile patterns/security-hardened.Dockerfile > Dockerfile
# docker build -t ember-secure .

# Example 8: Multi-stage with monitoring
# cat frameworks/ember.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/security-hardened.Dockerfile \
#     patterns/monitoring.Dockerfile > Dockerfile

# BEST PRACTICES
# ==============

# 1. Ember Best Practices:
#    • Use multi-stage builds for production deployments
#    • Always run as non-root user in production
#    • Use Alpine base images for smaller runtime size
#    • Implement health checks for container orchestration
#    • Use environment variables for configuration
#    • Clean npm cache to reduce image size
#    • Use specific Node.js versions (not 'latest')
#    • Scan images for vulnerabilities before deployment
#    • Implement proper logging and monitoring
#    • Follow Ember best practices and conventions

# 2. Security Considerations:
#    • This template includes non-root user configuration
#    • Production stage runs with minimal privileges
#    • Development stage includes all dependencies for hot reload
#    • Health check monitors application status
#    • Consider adding patterns/security-hardened.Dockerfile
#    • Use secrets management for sensitive data
#    • Implement proper authentication and authorization
#    • Use HTTPS in production environments
#    • Regularly update dependencies for security patches

# 3. Performance Optimization:
#    • Layer caching optimization with dependency-first copy
#    • Multi-stage builds reduce final image size
#    • Alpine base images minimize runtime footprint
#    • Production stage excludes development dependencies
#    • Proper resource limits for container orchestration
#    • Use .dockerignore to exclude unnecessary files
#    • Implement caching strategies for improved performance
#    • Optimize static asset delivery

# 4. Development Workflow:
#    • Use development stage for local development
#    • Mount source code volumes for hot reload
#    • Configure debugging ports for IDE integration
#    • Use Docker Compose for multi-service development
#    • Implement automated testing in CI/CD pipeline
#    • Use linting and code quality tools
#    • Follow Ember module and component patterns

# 5. Combination Patterns:
#    • This template is designed for standalone Ember applications
#    • Combine with database templates (PostgreSQL, MongoDB)
#    • Add security patterns for production hardening
#    • Use monitoring patterns for observability
#    • Implement CI/CD patterns for automated deployment
#    • Consider adding API gateway patterns if needed
