# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Ruby on Rails
# Website: https://rubyonrails.org/
# Repository: https://github.com/rails/rails
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Ruby on Rails application with security hardening
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security
# · COMBINATION: Use standalone for complete Rails applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: Rails documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Dependency installation and asset compilation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM ruby:3.2-alpine AS builder

# Build arguments for environment configuration
ARG RAILS_ENV=production
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG BUNDLE_WITHOUT="development test"

# Environment variables for build process
ENV RAILS_ENV=${RAILS_ENV} \
  BUILD_ID=${BUILD_ID} \
  COMMIT_SHA=${COMMIT_SHA} \
  BUNDLE_WITHOUT=${BUNDLE_WITHOUT} \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3

# Install system dependencies
RUN apk add --no-cache \
  build-base \
  git \
  postgresql-dev \
  nodejs \
  yarn \
  tzdata

WORKDIR /app

# Copy dependency files first for optimal layer caching
COPY Gemfile Gemfile.lock ./

# Install Ruby dependencies
RUN bundle install --jobs=${BUNDLE_JOBS} --retry=${BUNDLE_RETRY} && \
  bundle clean --force

COPY . .

# Precompile assets
RUN bundle exec rails assets:precompile

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Production deployment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM ruby:3.2-alpine AS runtime

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S -u 1001 -G appgroup appuser

# Install runtime dependencies only
RUN apk add --no-cache \
  postgresql-client \
  tzdata \
  nodejs

# Production environment configuration
ENV RAILS_ENV=production \
  RAILS_LOG_TO_STDOUT=true \
  RAILS_SERVE_STATIC_FILES=true \
  BUNDLE_PATH="/usr/local/bundle" \
  PATH="/home/appuser/.local/bin:${PATH}" \
  UMASK=0027

WORKDIR /app

# Copy Ruby dependencies from builder stage
COPY --from=builder --chown=appuser:appgroup /usr/local/bundle /usr/local/bundle

# Copy application code and precompiled assets
COPY --chown=appuser:appgroup . .
COPY --from=builder --chown=appuser:appgroup /app/public/assets ./public/assets
COPY --from=builder --chown=appuser:appgroup /app/public/packs ./public/packs

# Switch to non-root user
USER appuser

# Create directories with secure permissions
RUN mkdir -p /app/log /app/tmp && \
  chmod 750 /app/log /app/tmp

EXPOSE 3000

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Run Rails application
STOPSIGNAL SIGTERM
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT STAGE - Hot reload environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM ruby:3.2-alpine AS development

# Install development dependencies
RUN apk add --no-cache \
  build-base \
  git \
  postgresql-dev \
  nodejs \
  yarn \
  tzdata \
  vim

WORKDIR /app

# Development environment configuration
ENV RAILS_ENV=development \
  BUNDLE_PATH="/usr/local/bundle"

COPY Gemfile Gemfile.lock ./

# Install all dependencies (including development)
RUN bundle install

COPY . .

# Development command with hot reload
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Build production image
# docker build --target runtime -t my-rails-app:prod .

# Example 2: Build development image
# docker build --target development -t my-rails-app:dev .

# Example 3: Build with custom arguments
# docker build \
#   --build-arg RAILS_ENV=production \
#   --build-arg BUILD_ID=$(git rev-parse --short HEAD) \
#   -t my-rails-app:$(git rev-parse --short HEAD) .

# Example 4: Run production container
# docker run -d -p 3000:3000 --name rails-app my-rails-app:prod

# Example 5: Run development container
# docker run -d -p 3000:3000 -v $(pwd):/app --name rails-dev my-rails-app:dev

# Best Practices:
# 1. Always use .dockerignore to exclude log/, tmp/, .git, etc.
# 2. Use specific Ruby versions (not 'latest')
# 3. Run health checks in production
# 4. Use multi-stage builds for smaller images
# 5. Set resource limits in docker-compose or Kubernetes

# Customization Notes:
# 1. Adjust database client based on your database (PostgreSQL, MySQL, etc.)
# 2. Modify health check endpoint as needed
# 3. Add environment variables for your application
# 4. Customize Gemfile for your dependencies
# 5. Consider adding Puma for production with multiple workers
