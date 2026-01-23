# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for SvelteKit
# Website: https://kit.svelte.dev/
# Repository: https://github.com/sveltejs/kit
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready SvelteKit application with security hardening
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security
# · COMBINATION: Use standalone for complete SvelteKit applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: SvelteKit documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Application compilation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS builder

# Build arguments for environment configuration
ARG NODE_ENV=production
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG ORIGIN=https://localhost:3000

# Environment variables for build process
ENV NODE_ENV=${NODE_ENV} \
  BUILD_ID=${BUILD_ID} \
  COMMIT_SHA=${COMMIT_SHA} \
  ORIGIN=${ORIGIN} \
  npm_config_update_notifier=false \
  npm_config_cache=/tmp/.npm

WORKDIR /app

# Copy dependency files first for optimal layer caching
COPY package*.json ./
COPY pnpm-lock.yaml* ./
COPY yarn.lock* ./

# Install dependencies based on package manager
RUN if [ -f "pnpm-lock.yaml" ]; then \
      npm install -g pnpm && \
      pnpm install --frozen-lockfile --prod; \
    elif [ -f "yarn.lock" ]; then \
      npm install -g yarn && \
      yarn install --frozen-lockfile --production; \
    else \
      npm install --omit=dev; \
    fi && \
    npm cache clean --force

COPY . .

# Build SvelteKit application
RUN if [ -f "pnpm-lock.yaml" ]; then \
      pnpm run build; \
    elif [ -f "yarn.lock" ]; then \
      yarn run build; \
    else \
      npm run build; \
    fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Production deployment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS runtime

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S -u 1001 -G appgroup appuser

# Production environment configuration
ENV NODE_ENV=production \
  ORIGIN=https://localhost:3000 \
  npm_config_update_notifier=false \
  UMASK=0027

WORKDIR /app

# Copy built artifacts from builder stage with proper ownership
COPY --from=builder --chown=appuser:appgroup /app/package*.json ./
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/build ./build
COPY --from=builder --chown=appuser:appgroup /app/static ./static

# Create directories with secure permissions
RUN mkdir -p /app/logs /app/tmp && \
  chown -R appuser:appgroup /app/logs /app/tmp && \
  chmod 750 /app/logs /app/tmp

# Switch to non-root user
USER appuser

EXPOSE 3000

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (r) => { \
  process.exit(r.statusCode === 200 ? 0 : 1); \
  }).on('error', () => process.exit(1))"

# Start SvelteKit production server
STOPSIGNAL SIGTERM
ENTRYPOINT ["node", "build/index.js"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT STAGE - Hot reload environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS development

WORKDIR /app

COPY package*.json ./
COPY pnpm-lock.yaml* ./
COPY yarn.lock* ./

# Install all dependencies (including dev dependencies)
RUN if [ -f "pnpm-lock.yaml" ]; then \
      npm install -g pnpm && \
      pnpm install --frozen-lockfile; \
    elif [ -f "yarn.lock" ]; then \
      npm install -g yarn && \
      yarn install --frozen-lockfile; \
    else \
      npm ci; \
    fi

COPY . .

# Development command with hot reload
CMD if [ -f "pnpm-lock.yaml" ]; then \
      pnpm run dev; \
    elif [ -f "yarn.lock" ]; then \
      yarn run dev; \
    else \
      npm run dev; \
    fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Build production image
# docker build --target runtime -t my-sveltekit-app:prod .

# Example 2: Build development image
# docker build --target development -t my-sveltekit-app:dev .

# Example 3: Build with custom arguments
# docker build \
#   --build-arg NODE_ENV=production \
#   --build-arg BUILD_ID=$(git rev-parse --short HEAD) \
#   --build-arg ORIGIN=https://example.com \
#   -t my-sveltekit-app:$(git rev-parse --short HEAD) .

# Example 4: Run production container
# docker run -d -p 3000:3000 --name sveltekit-app my-sveltekit-app:prod

# Example 5: Run development container
# docker run -d -p 3000:3000 -v $(pwd):/app --name sveltekit-dev my-sveltekit-app:dev

# Example 6: Build with adapter-specific configuration
# docker build \
#   --build-arg ADAPTER=node \
#   -t my-sveltekit-app:node .

# Best Practices:
# 1. Always use .dockerignore to exclude node_modules, .git, build, etc.
# 2. Use specific Node.js versions (not 'latest')
# 3. Run health checks in production
# 4. Use multi-stage builds for smaller images
# 5. Set resource limits in docker-compose or Kubernetes

# Customization Notes:
# 1. Adjust exposed ports based on your SvelteKit configuration
# 2. Modify health check endpoint as needed
# 3. Add environment variables for your application
# 4. Customize build commands for your SvelteKit setup
# 5. Consider using different adapters (node, static, vercel, etc.)

# SvelteKit Adapter Support:
# This template supports all SvelteKit adapters. For adapter-specific configurations:
# 1. Node adapter: Uses the runtime stage above
# 2. Static adapter: Builds to static files served by npx serve
# 3. Vercel/Netlify adapters: May require additional runtime configuration

# Package Manager Support:
# This template automatically detects and uses:
# - npm (default)
# - yarn (if yarn.lock exists)
# - pnpm (if pnpm-lock.yaml exists)

# Adapter Configuration:
# The template uses the default Node adapter.
# To use a different adapter, install and configure it in your SvelteKit project.

# SSR vs Static Generation:
# For static generation, use SvelteKit's static adapter and serve static files.
# For SSR, use the Node adapter as configured above.

# Environment Variables:
# SvelteKit uses Vite for environment variables. Prefix public variables with PUBLIC_
# Private variables should be set at runtime or through build arguments.
