# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for Ruby
# Website: https://www.ruby-lang.org/
# Repository: https://github.com/ruby/ruby
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: Ruby runtime configuration for Docker containers
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: Use with multi-stage builds for production deployments
# · OFFICIAL SOURCES: Ruby documentation and Docker best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Choose appropriate base image based on your needs:

# Option 1: Alpine (smallest)
FROM ruby:3.2-alpine

# Option 2: Slim (Debian-based, smaller than full)
# FROM ruby:3.2-slim

# Option 3: Full (includes build tools)
# FROM ruby:3.2

# Option 4: Specific version with SHA
# FROM ruby:3.2-alpine@sha256:abc123...

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG RUBY_VERSION=3.2
ARG BUNDLE_WITHOUT="development test"
ARG RAILS_ENV=production
ARG NODE_ENV=production

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV RUBY_VERSION=${RUBY_VERSION} \
  BUNDLE_WITHOUT=${BUNDLE_WITHOUT} \
  RAILS_ENV=${RAILS_ENV} \
  NODE_ENV=${NODE_ENV} \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_APP_CONFIG="${BUNDLE_PATH}" \
  BUNDLE_BIN="${BUNDLE_PATH}/bin" \
  GEM_HOME="${BUNDLE_PATH}" \
  PATH="${BUNDLE_BIN}:${PATH}" \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8

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
  postgresql-dev \
  sqlite-dev \
  tzdata \
  nodejs \
  yarn \
  git

# For Debian-based images, use:
# RUN apt-get update && apt-get install -y --no-install-recommends \
#   build-essential \
#   ca-certificates \
#   libpq-dev \
#   libsqlite3-dev \
#   tzdata \
#   nodejs \
#   yarn \
#   git \
#   && rm -rf /var/lib/apt/lists/*

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUNDLER CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Configure bundler for production
RUN bundle config set --global without "${BUNDLE_WITHOUT}" && \
  bundle config set --global deployment 'true' && \
  bundle config set --global frozen 'true' && \
  bundle config set --global no-cache 'true' && \
  bundle config set --global clean 'true'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEPENDENCY MANAGEMENT PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COPY Gemfile Gemfile.lock ./

# Pattern 1: Production dependencies only
RUN bundle install --jobs=$(nproc) --retry=3

# Pattern 2: Development dependencies
# RUN bundle install --jobs=$(nproc) --retry=3 --with development test

# Pattern 3: Without specific groups
# RUN bundle install --jobs=$(nproc) --retry=3 --without development test

# Pattern 4: With specific path
# RUN bundle install --jobs=$(nproc) --retry=3 --path vendor/bundle

# Copy package.json for JavaScript dependencies (if using Rails with Webpacker/Propshaft)
COPY package.json yarn.lock* ./
RUN yarn install --frozen-lockfile --non-interactive --production=false

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APPLICATION DEPLOYMENT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COPY . .

# Precompile assets (for Rails applications)
RUN bundle exec rails assets:precompile --trace

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Expose port (customize for your application)
EXPOSE 3000

# Create logs and tmp directories
RUN mkdir -p /app/log /app/tmp /app/storage && \
  chmod -R 755 /app/log /app/tmp /app/storage

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT & COMMAND OPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Option 1: Rails server
# ENTRYPOINT ["bundle", "exec"]
# CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]

# Option 2: Puma server (recommended for production)
# ENTRYPOINT ["bundle", "exec"]
# CMD ["puma", "-C", "config/puma.rb"]

# Option 3: Rack application
# ENTRYPOINT ["bundle", "exec"]
# CMD ["rackup", "-o", "0.0.0.0", "-p", "3000"]

# Option 4: Custom entrypoint script
# COPY entrypoint.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/entrypoint.sh
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECK OPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Option 1: HTTP health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
#     CMD curl -f http://localhost:3000/health || exit 1

# Option 2: Rails health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
#     CMD bundle exec rails runner "exit(ActiveRecord::Base.connection ? 0 : 1)" || exit 1

# Option 3: Custom health check script
# HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
#     CMD /app/scripts/healthcheck.sh

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Development-specific configurations (uncomment as needed)

# Install development dependencies
# RUN bundle install --jobs=$(nproc) --retry=3 --with development test

# Install debugging tools
# RUN gem install byebug pry

# Development command with hot reload
# CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PERFORMANCE OPTIMIZATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Uncomment optimizations as needed:

# Clean up build dependencies
# RUN apk del build-base

# Remove cache files
# RUN rm -rf /tmp/* /var/tmp/* /usr/share/doc/*

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Basic Ruby application build:
#    docker build -t ruby-app -f ruby.Dockerfile .
#
# 2. Development environment with mounted source code:
#    docker run -it --rm -v $(pwd):/app -p 3000:3000 ruby-app bundle exec rails server -b 0.0.0.0
#
# 3. Build Ruby project with custom Ruby version:
#    docker build --build-arg RUBY_VERSION=3.2 -t ruby-app .
#
# 4. Run Ruby tests:
#    docker run -it --rm -v $(pwd):/app ruby-app bundle exec rspec
#
# 5. Production deployment with Rails:
#    docker build -t rails-app -f ruby.Dockerfile .
#    docker run -d -p 3000:3000 --name rails-app rails-app
#
# 6. Interactive debugging with byebug:
#    docker run -it --rm -p 3000:3000 ruby-app bundle exec rails console
#
# 7. Multi-stage build combining with pattern templates:
#    cat languages/ruby.Dockerfile patterns/multi-stage.Dockerfile > Dockerfile
#    docker build -t optimized-ruby-app .
#
# 8. Database integration with PostgreSQL:
#    cat languages/ruby.Dockerfile tools/postgresql.Dockerfile > Dockerfile
#    docker build -t ruby-postgres-app .

# BEST PRACTICES
# ==============
# • Security & Compliance:
#   - Always use version-pinned base images (ruby:3.2-alpine)
#   - Run as non-root user to minimize security risks
#   - Use Alpine Linux for smaller attack surface and reduced image size
#   - Regularly update Ruby, Bundler, and gem versions for security patches
#
# • Performance & Optimization:
#   - Leverage Bundler caching by mounting bundle directory
#   - Use multi-stage builds to separate build dependencies from runtime
#   - Optimize Ruby garbage collection settings based on container resource limits
#   - Consider using Puma for production web server with thread pooling
#
# • Development & Operations:
#   - Mount local source code for development to enable hot-reload workflows
#   - Use Bundler for consistent gem versions across environments
#   - Configure proper health checks for container orchestration (Kubernetes, Docker Swarm)
#   - Set up logging and monitoring for Ruby applications (Rails, Sinatra, etc.)
#
# • Ruby-Specific Considerations:
#   - Understand Ruby's garbage collection for memory-intensive applications
#   - Configure Ruby's thread and fiber settings for concurrent applications
#   - Use Ruby's metaprogramming features judiciously in containerized environments
#   - Consider using Ruby's native extensions for performance-critical operations
#
# • Combination Patterns:
#   - Combine with frameworks/rails.Dockerfile for Rails applications
#   - Use with patterns/multi-stage.Dockerfile for optimized production builds
#   - Integrate with patterns/security-hardened.Dockerfile for enhanced security
#   - Combine with tools/postgresql.Dockerfile for database-backed applications
#   - Use with patterns/alpine.Dockerfile for smaller image sizes
