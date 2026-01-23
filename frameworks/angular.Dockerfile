# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Angular
# Website: https://angular.io/
# Repository: https://github.com/angular/angular
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Angular application with Node.js and Nginx
# · DESIGN PHILOSOPHY: Multi-stage builds with development and production targets
# · COMBINATION: Use standalone for complete Angular applications
# · SECURITY: Non-root users, Alpine base, security headers
# · BEST PRACTICES: Build optimization, asset compression, production defaults
# · OFFICIAL SOURCES: Angular documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Application compilation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS builder

# Build arguments for environment configuration
ARG NODE_ENV=production
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG NG_CLI_ANALYTICS="false"

# Environment variables for build process
ENV NODE_ENV=${NODE_ENV} \
  BUILD_ID=${BUILD_ID} \
  COMMIT_SHA=${COMMIT_SHA} \
  NG_CLI_ANALYTICS=${NG_CLI_ANALYTICS} \
  npm_config_update_notifier=false \
  npm_config_cache=/tmp/.npm

# Install Angular CLI globally
RUN npm install -g @angular/cli@15

WORKDIR /app

# Copy dependency files first for optimal layer caching
COPY package*.json ./

# Install dependencies
RUN npm ci --omit=dev && \
  npm cache clean --force

COPY . .

# Build Angular application for production
RUN ng build --configuration=production --output-path=dist

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Production deployment with Nginx
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM nginx:1.24-alpine AS runtime

# Create non-root user
RUN addgroup -g 1001 -S nginxgroup && \
  adduser -S -D -H -u 1001 -G nginxgroup nginxuser

# Remove default nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration with security headers
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built artifacts from builder stage
COPY --from=builder --chown=nginxuser:nginxgroup /app/dist /usr/share/nginx/html

# Set proper permissions
RUN chown -R nginxuser:nginxgroup /var/cache/nginx \
  && chown -R nginxuser:nginxgroup /var/log/nginx \
  && chown -R nginxuser:nginxgroup /etc/nginx/conf.d

# Add security headers configuration
RUN echo 'add_header X-Frame-Options "SAMEORIGIN" always;' >> /etc/nginx/conf.d/security-headers.conf && \
  echo 'add_header X-Content-Type-Options "nosniff" always;' >> /etc/nginx/conf.d/security-headers.conf && \
  echo 'add_header X-XSS-Protection "1; mode=block" always;' >> /etc/nginx/conf.d/security-headers.conf && \
  echo 'add_header Referrer-Policy "strict-origin-when-cross-origin" always;' >> /etc/nginx/conf.d/security-headers.conf && \
  echo 'add_header Content-Security-Policy "default-src '\''self'\''; script-src '\''self'\'' '\''unsafe-inline'\'' '\''unsafe-eval'\''; style-src '\''self'\'' '\''unsafe-inline'\''; img-src '\''self'\'' data: https:; font-src '\''self'\'' data:;" always;' >> /etc/nginx/conf.d/security-headers.conf

# Switch to non-root user
USER nginxuser

EXPOSE 80

# Health check for Nginx
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

# Start Nginx
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT STAGE - Hot reload environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS development

# Install Angular CLI globally
RUN npm install -g @angular/cli@15

# Set development environment variables
ENV NODE_ENV=development \
  NG_CLI_ANALYTICS="false" \
  CHOKIDAR_USEPOLLING=true

WORKDIR /app

COPY package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm ci

COPY . .

# Development command with hot reload
CMD ["ng", "serve", "--host", "0.0.0.0", "--port", "4200", "--disable-host-check"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TESTING STAGE - Unit and end-to-end testing
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS testing

# Install Angular CLI globally
RUN npm install -g @angular/cli@15

# Install Chrome for end-to-end testing
RUN apk add --no-cache \
  chromium \
  chromium-chromedriver

# Set environment variables for testing
ENV NODE_ENV=test \
  CHROME_BIN=/usr/bin/chromium-browser \
  CHROMIUM_FLAGS="--no-sandbox --disable-dev-shm-usage"

WORKDIR /app

COPY package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm ci

COPY . .

# Test command
CMD ["ng", "test", "--watch=false", "--browsers=ChromeHeadless"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Build production image
# docker build --target runtime -t my-angular-app:prod .

# Example 2: Build development image
# docker build --target development -t my-angular-app:dev .

# Example 3: Build testing image
# docker build --target testing -t my-angular-app:test .

# Example 4: Run production container
# docker run -d -p 80:80 --name angular-app my-angular-app:prod

# Example 5: Run development container with hot reload
# docker run -d -p 4200:4200 -v $(pwd):/app --name angular-dev my-angular-app:dev

# Required configuration file:
# nginx.conf - Nginx configuration for Angular SPA

# Example nginx.conf:
# server {
#   listen 80;
#   server_name localhost;
#   root /usr/share/nginx/html;
#   index index.html;
#
#   # SPA routing
#   location / {
#     try_files $uri $uri/ /index.html;
#   }
#
#   # Cache static assets
#   location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
#     expires 1y;
#     add_header Cache-Control "public, immutable";
#   }
#
#   # Gzip compression
#   gzip on;
#   gzip_vary on;
#   gzip_min_length 1024;
#   gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
# }

# Best Practices:
# 1. Always use .dockerignore to exclude node_modules, .git, dist, etc.
# 2. Use environment-specific configurations (environment.ts files)
# 3. Implement proper caching strategies for static assets
# 4. Set up CI/CD pipeline for automated testing and deployment
# 5. Use Angular's built-in optimization features (AOT compilation, tree shaking)

# Customization Notes:
# 1. Adjust Angular CLI version based on your project requirements
# 2. Modify Nginx configuration for your specific routing needs
# 3. Add environment variables for API endpoints and feature flags
# 4. Customize security headers based on your application requirements
# 5. Add additional build arguments for custom configurations
