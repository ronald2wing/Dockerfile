# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Laravel
# Website: https://laravel.com/
# Repository: https://github.com/laravel/laravel
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Laravel application with PHP-FPM and Nginx
# · DESIGN PHILOSOPHY: Multi-service architecture with PHP-FPM and Nginx
# · COMBINATION: Use standalone for complete Laravel applications
# · SECURITY: Non-root users, Alpine base, secure permissions
# · BEST PRACTICES: Composer optimization, opcache configuration, production defaults
# · OFFICIAL SOURCES: Laravel documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PHP-FPM STAGE - Application runtime
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM php:8.2-fpm-alpine AS php-fpm

# Build arguments for environment configuration
ARG APP_ENV=production
ARG APP_DEBUG=false
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown

# Environment variables for Laravel
ENV APP_ENV=${APP_ENV} \
  APP_DEBUG=${APP_DEBUG} \
  BUILD_ID=${BUILD_ID} \
  COMMIT_SHA=${COMMIT_SHA} \
  COMPOSER_ALLOW_SUPERUSER=1 \
  PHP_OPCACHE_ENABLE=1 \
  PHP_OPCACHE_VALIDATE_TIMESTAMPS=0 \
  PHP_OPCACHE_MAX_ACCELERATED_FILES=10000 \
  PHP_OPCACHE_MEMORY_CONSUMPTION=128 \
  PHP_OPCACHE_MAX_WASTED_PERCENTAGE=10

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
  git \
  curl \
  libpng-dev \
  libjpeg-turbo-dev \
  freetype-dev \
  libzip-dev \
  zip \
  unzip \
  supervisor \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install \
  pdo_mysql \
  pdo_pgsql \
  bcmath \
  gd \
  zip \
  opcache \
  && apk del --no-cache \
  libpng-dev \
  libjpeg-turbo-dev \
  freetype-dev \
  libzip-dev

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Create non-root user for PHP-FPM
RUN addgroup -g 1000 -S www && \
  adduser -u 1000 -S www -G www

WORKDIR /var/www/html

# Copy Composer files first for optimal layer caching
COPY composer.json composer.lock ./

# Install PHP dependencies (no dev dependencies in production)
RUN if [ "$APP_ENV" = "production" ]; then \
  composer install --no-dev --no-interaction --no-progress --optimize-autoloader; \
  else \
  composer install --no-interaction --no-progress --optimize-autoloader; \
  fi

COPY . .

# Set proper permissions
RUN chown -R www:www /var/www/html \
  && chmod -R 755 storage bootstrap/cache

# Create necessary directories
RUN mkdir -p /var/log/supervisor \
  && chown -R www:www /var/log/supervisor

# Copy PHP-FPM configuration
COPY --chown=www:www docker/php-fpm.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY --chown=www:www docker/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Switch to non-root user
USER www

EXPOSE 9000

# Health check for PHP-FPM
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD php -r "if(@fsockopen('127.0.0.1', 9000)) { exit(0); } exit(1);"

# Start PHP-FPM
STOPSIGNAL SIGTERM
CMD ["php-fpm"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NGINX STAGE - Web server
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM nginx:1.24-alpine AS nginx

# Create non-root user
RUN addgroup -g 1001 -S nginxgroup && \
  adduser -S -D -H -u 1001 -G nginxgroup nginxuser

# Remove default nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY docker/nginx.conf /etc/nginx/conf.d/app.conf

# Copy built artifacts from PHP-FPM stage
COPY --from=php-fpm --chown=nginxuser:nginxgroup /var/www/html /var/www/html

# Set proper permissions
RUN chown -R nginxuser:nginxgroup /var/cache/nginx \
  && chown -R nginxuser:nginxgroup /var/log/nginx \
  && chown -R nginxuser:nginxgroup /etc/nginx/conf.d \
  && chmod -R 755 /var/www/html/storage \
  && chmod -R 755 /var/www/html/bootstrap/cache

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
# DEVELOPMENT STAGE - Local development with Xdebug
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM php:8.2-fpm-alpine AS development

# Install Xdebug for development
RUN apk add --no-cache $PHPIZE_DEPS \
  && pecl install xdebug \
  && docker-php-ext-enable xdebug

# Copy development configuration
COPY --from=php-fpm /usr/local/etc/php/conf.d/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY docker/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Set development environment variables
ENV APP_ENV=local \
  APP_DEBUG=true \
  XDEBUG_MODE=develop,debug \
  XDEBUG_CONFIG="client_host=host.docker.internal"

# Install development tools (requires root for apk)
RUN apk add --no-cache \
  nodejs \
  npm \
  yarn \
  git

# Switch to non-root user for development
USER www

WORKDIR /var/www/html

# Development command
CMD ["php-fpm"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Build production image with Nginx:
#    docker build --target nginx -t my-laravel-app:prod .
#
# 2. Build PHP-FPM only (for use with external Nginx):
#    docker build --target php-fpm -t my-laravel-app:php-fpm .
#
# 3. Build development image with Xdebug:
#    docker build --target development -t my-laravel-app:dev .
#
# 4. Run production with docker-compose:
#    docker-compose up -d
#
# 5. Run development with hot reload:
#    docker run -d \
#      -p 9000:9000 \
#      -p 80:80 \
#      -v $(pwd):/var/www/html \
#      --name laravel-dev \
#      my-laravel-app:dev
#
# 6. Run with environment variables:
#    docker run -d \
#      -p 80:80 \
#      -e APP_ENV=production \
#      -e APP_DEBUG=false \
#      -e DB_HOST=mysql \
#      -e DB_DATABASE=laravel \
#      -e DB_USERNAME=laravel \
#      -e DB_PASSWORD=secret \
#      --name laravel-app \
#      my-laravel-app:prod
#
# 7. Run with health checks:
#    docker run -d \
#      -p 80:80 \
#      --health-cmd="curl -f http://localhost/health || exit 1" \
#      --health-interval=30s \
#      --name laravel-app \
#      my-laravel-app:prod
#
# 8. Build with custom build arguments:
#    docker build \
#      --target nginx \
#      --build-arg APP_ENV=production \
#      --build-arg APP_DEBUG=false \
#      --build-arg BUILD_ID=$(git rev-parse --short HEAD) \
#      -t my-laravel-app:$(git rev-parse --short HEAD) .

# BEST PRACTICES
# ==============
# • VERSION PINNING: Always pin PHP, Nginx, and Composer versions for reproducibility
# • LAYER OPTIMIZATION: Structure Dockerfile to maximize layer caching efficiency
# • DEPENDENCY MANAGEMENT: Use Composer for PHP dependencies with optimized autoloader
# • SECURITY CONFIGURATION: Run PHP-FPM and Nginx as non-root users in production
# • RESOURCE MANAGEMENT: Set appropriate memory limits for PHP and Nginx processes
# • BUILD OPTIMIZATION: Use multi-stage builds to separate development and production
# • TESTING INTEGRATION: Run PHPUnit tests during build process to ensure quality
# • MONITORING: Implement comprehensive logging and health checks for production

# LARAVEL-SPECIFIC CONSIDERATIONS
# • ARTISAN COMMANDS: Run migrations, seeders, and optimizations during deployment
# • QUEUE WORKERS: Configure supervisor for queue worker management
# • CACHE CONFIGURATION: Optimize cache drivers (Redis, file, database) for performance
# • STORAGE PERMISSIONS: Set proper permissions for storage and bootstrap/cache directories
# • ENVIRONMENT CONFIGURATION: Use .env files with appropriate security measures
# • SCHEDULED TASKS: Implement Laravel task scheduling with appropriate cron configuration

# SECURITY CONSIDERATIONS
# • FILE PERMISSIONS: Set strict permissions on configuration and storage directories
# • ENVIRONMENT VARIABLES: Use Docker secrets or environment variables for sensitive data
# • SSL/TLS TERMINATION: Implement SSL/TLS at Nginx level for secure communication
# • RATE LIMITING: Configure rate limiting at Nginx level to prevent abuse
# • CORS CONFIGURATION: Implement proper CORS headers for API security

# PERFORMANCE OPTIMIZATION
# • OPCACHE CONFIGURATION: Optimize PHP OPcache settings for production performance
# • COMPOSER OPTIMIZATION: Use Composer's optimized autoloader and classmap generation
# • ASSET COMPILATION: Pre-compile assets (CSS, JavaScript) during build process
# • DATABASE OPTIMIZATION: Use database connection pooling and query optimization
# • CACHE IMPLEMENTATION: Implement appropriate caching strategies for application data

# REQUIRED CONFIGURATION FILES
# 1. docker/nginx.conf - Nginx configuration for Laravel application routing
# 2. docker/php-fpm.conf - PHP-FPM process manager configuration
# 3. docker/opcache.ini - PHP OPcache optimization configuration
# 4. docker/xdebug.ini - Xdebug configuration for development debugging

# COMBINATION PATTERNS
# • Combine with patterns/multi-stage.Dockerfile for additional optimization stages
# • Combine with patterns/security-hardened.Dockerfile for enhanced security
# • Combine with tools/mysql.Dockerfile for MySQL database integration
# • Combine with tools/redis.Dockerfile for caching and queue management
# • Combine with patterns/monitoring.Dockerfile for application monitoring
