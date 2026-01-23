# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for PHP
# Website: https://www.php.net/
# Repository: https://github.com/php/php-src
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: PHP runtime configuration for Docker containers
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: Use with multi-stage builds for production deployments
# · OFFICIAL SOURCES: PHP documentation and Docker best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Choose appropriate base image based on your needs:

# Option 1: Alpine with FPM (smallest, recommended for production)
FROM php:8.2-fpm-alpine

# Option 2: Alpine with CLI
# FROM php:8.2-cli-alpine

# Option 3: Debian-based with FPM
# FROM php:8.2-fpm

# Option 4: Specific version with SHA
# FROM php:8.2-fpm-alpine@sha256:abc123...

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG PHP_VERSION=8.2
ARG APP_ENV=production
ARG BUILD_ID=unknown

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV PHP_VERSION=${PHP_VERSION} \
  APP_ENV=${APP_ENV} \
  BUILD_ID=${BUILD_ID} \
  PHP_MEMORY_LIMIT=256M \
  PHP_UPLOAD_MAX_FILESIZE=64M \
  PHP_POST_MAX_SIZE=64M \
  PHP_MAX_EXECUTION_TIME=30 \
  PHP_MAX_INPUT_TIME=60 \
  PHP_DATE_TIMEZONE=UTC \
  COMPOSER_ALLOW_SUPERUSER=1 \
  COMPOSER_HOME=/tmp/composer \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# WORKDIR SETUP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WORKDIR /var/www/html

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SYSTEM DEPENDENCIES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Install system dependencies (adjust based on your needs)

# For Alpine base images:
RUN apk add --no-cache \
  bash \
  curl \
  git \
  gnupg \
  libpng-dev \
  libjpeg-turbo-dev \
  libwebp-dev \
  libzip-dev \
  freetype-dev \
  icu-dev \
  postgresql-dev \
  oniguruma-dev \
  openssl-dev \
  supervisor \
  nginx \
  nodejs \
  yarn

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PHP EXTENSIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Install PHP extensions (common for web applications)

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
  docker-php-ext-install -j$(nproc) \
  bcmath \
  exif \
  gd \
  intl \
  mbstring \
  opcache \
  pdo \
  pdo_mysql \
  pdo_pgsql \
  zip \
  sockets

# Install Redis extension (optional)
RUN pecl install redis && docker-php-ext-enable redis

# Install Xdebug for development (optional)
# RUN pecl install xdebug && docker-php-ext-enable xdebug

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMPOSER INSTALLATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PHP CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Copy PHP configuration files
COPY docker/php/php.ini /usr/local/etc/php/conf.d/custom.ini
COPY docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf

# Configure PHP-FPM
RUN echo "pm.max_children = 50" >> /usr/local/etc/php-fpm.d/www.conf && \
  echo "pm.start_servers = 5" >> /usr/local/etc/php-fpm.d/www.conf && \
  echo "pm.min_spare_servers = 5" >> /usr/local/etc/php-fpm.d/www.conf && \
  echo "pm.max_spare_servers = 35" >> /usr/local/etc/php-fpm.d/www.conf

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEPENDENCY MANAGEMENT PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COPY composer.json composer.lock ./

# Pattern 1: Production dependencies only
RUN composer install --no-dev --no-interaction --no-progress --no-scripts --optimize-autoloader

# Pattern 2: Development dependencies
# RUN composer install --no-interaction --no-progress --no-scripts --optimize-autoloader

# Pattern 3: With platform requirements
# RUN composer install --no-dev --no-interaction --no-progress --no-scripts --optimize-autoloader --ignore-platform-reqs

# Copy package.json for JavaScript dependencies (if using Laravel Mix, Vite, etc.)
COPY package.json yarn.lock* ./
RUN yarn install --frozen-lockfile --non-interactive --production=false

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APPLICATION DEPLOYMENT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COPY . .

RUN chown -R www-data:www-data /var/www/html && \
  chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Expose port (customize for your application)
EXPOSE 9000

# Create logs directory
RUN mkdir -p /var/log/php /var/log/nginx && \
  chown -R www-data:www-data /var/log/php /var/log/nginx

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT & COMMAND OPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Option 1: PHP-FPM only
# CMD ["php-fpm"]

# Option 2: PHP-FPM with Nginx (using supervisor)
# COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Option 3: Laravel Artisan commands
# ENTRYPOINT ["php", "artisan"]
# CMD ["serve", "--host=0.0.0.0", "--port=8000"]

# Option 4: Custom entrypoint script
# COPY docker/entrypoint.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/entrypoint.sh
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# CMD ["php-fpm"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECK OPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Option 1: PHP-FPM health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD php-fpm-healthcheck || exit 1

# Option 2: HTTP health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
#     CMD curl -f http://localhost:9000/health || exit 1

# Option 3: Custom health check script
# HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
#     CMD /var/www/html/docker/healthcheck.sh

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Development-specific configurations (uncomment as needed)

# Install development dependencies
# RUN composer install --no-interaction --no-progress --no-scripts --optimize-autoloader

# Install Xdebug
# RUN pecl install xdebug && docker-php-ext-enable xdebug

# Development command with PHP built-in server
# CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PERFORMANCE OPTIMIZATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Uncomment optimizations as needed:

# Enable OPCache for production
RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
  echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
  echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
  echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
  echo "opcache.revalidate_freq=2" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# Clean up build dependencies
# RUN apk del .build-deps

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Basic PHP-FPM build
# docker build -t php-app .
# docker run -p 9000:9000 php-app

# Example 2: Build with custom PHP version
# docker build \
#   --build-arg PHP_VERSION=8.3 \
#   --build-arg APP_ENV=production \
#   -t php:8.3 .

# Example 3: Multi-stage PHP build
# cat languages/php.Dockerfile patterns/multi-stage.Dockerfile > Dockerfile
# docker build -t php-multi-stage .

# Example 4: With security hardening
# cat languages/php.Dockerfile patterns/security-hardened.Dockerfile > Dockerfile
# docker build -t php-secure .

# Example 5: Complete production setup
# cat languages/php.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/security-hardened.Dockerfile \
#     patterns/docker-compose.Dockerfile > Dockerfile

# Example 6: Development environment
# cat languages/php.Dockerfile patterns/development.Dockerfile > Dockerfile
# docker build -t php-dev .

# Example 7: CI/CD integration
# cat languages/php.Dockerfile patterns/ci-cd.Dockerfile > Dockerfile
# docker build \
#   --build-arg CI=true \
#   --build-arg CI_COMMIT_SHA=$CI_COMMIT_SHA \
#   -t php:$CI_COMMIT_SHA .

# Example 8: With nginx and supervisor
# cat languages/php.Dockerfile tools/nginx.Dockerfile > Dockerfile
# docker build -t php-nginx .

# BEST PRACTICES
# ==============

# 1. PHP Language Best Practices:
#    • Use specific version tags for base images (not 'latest')
#    • Implement multi-stage builds for production
#    • Run as non-root user in production environments
#    • Clean package manager caches to reduce image size
#    • Use environment variables for configuration
#    • Implement health checks for container orchestration
#    • Scan images for vulnerabilities before deployment
#    • Use .dockerignore to exclude unnecessary files
#    • Follow PHP coding standards (PSR)
#    • Implement proper error handling and logging

# 2. Security Considerations:
#    • This template provides PHP runtime configuration
#    • Combine with patterns/security-hardened.Dockerfile for security
#    • Use secrets management for sensitive data
#    • Implement proper input validation and sanitization
#    • Use HTTPS/TLS for network communication
#    • Regularly update PHP runtime and extensions
#    • Follow principle of least privilege
#    • Monitor for security vulnerabilities
#    • Disable dangerous PHP functions in production

# 3. Performance Optimization:
#    • Use Alpine variants for smaller images when possible
#    • Implement layer caching optimization
#    • Use multi-stage builds to exclude build tools
#    • Optimize dependency installation order
#    • Use appropriate resource limits
#    • Implement OPCache for PHP performance
#    • Use connection pooling for database access
#    • Profile and optimize application code

# 4. Development Workflow:
#    • Use development patterns for local development
#    • Implement Xdebug for debugging
#    • Configure development PHP settings
#    • Use Docker Compose for multi-service setups
#    • Implement automated testing
#    • Use linting and static analysis tools
#    • Follow PHP development patterns

# 5. Combination Patterns:
#    • This template is designed to be combined with pattern templates
#    • Always combine with security-hardened.Dockerfile for production
#    • Use multi-stage.Dockerfile for build optimization
#    • Add monitoring.Dockerfile for observability
#    • Implement CI/CD patterns for automated deployment
#    • Consider framework templates for complete applications
