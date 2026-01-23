# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Nuxt
# Website: https://nuxt.com/
# Repository: https://github.com/nuxt/nuxt
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Nuxt application with security hardening
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security
# · COMBINATION: Use standalone for complete Nuxt applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: Nuxt documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Application compilation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS builder

# Build arguments for environment configuration
ARG NODE_ENV=production
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG NUXT_PUBLIC_BASE_URL=/

# Environment variables for build process
ENV NODE_ENV=${NODE_ENV} \
  BUILD_ID=${BUILD_ID} \
  COMMIT_SHA=${COMMIT_SHA} \
  NUXT_PUBLIC_BASE_URL=${NUXT_PUBLIC_BASE_URL} \
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

# Build Nuxt application
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
  NUXT_PUBLIC_BASE_URL=/ \
  npm_config_update_notifier=false \
  UMASK=0027

WORKDIR /app

# Copy built artifacts from builder stage with proper ownership
COPY --from=builder --chown=appuser:appgroup /app/package*.json ./
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/.output ./.output
COPY --from=builder --chown=appuser:appgroup /app/public ./public

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

# Start Nuxt production server
STOPSIGNAL SIGTERM
ENTRYPOINT ["node", ".output/server/index.mjs"]

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
# docker build --target runtime -t my-nuxt-app:prod .

# Example 2: Build development image
# docker build --target development -t my-nuxt-app:dev .

# Example 3: Build with custom arguments
# docker build \
#   --build-arg NODE_ENV=production \
#   --build-arg BUILD_ID=$(git rev-parse --short HEAD) \
#   --build-arg NUXT_PUBLIC_BASE_URL=https://example.com \
#   -t my-nuxt-app:$(git rev-parse --short HEAD) .

# Example 4: Run production container
# docker run -d -p 3000:3000 --name nuxt-app my-nuxt-app:prod

# Example 5: Run development container
# docker run -d -p 3000:3000 -v $(pwd):/app --name nuxt-dev my-nuxt-app:dev

# Example 6: Build with Nitro preset configuration
# docker build \
#   --build-arg NITRO_PRESET=node \
#   -t my-nuxt-app:node .

# Best Practices:
# 1. Always use .dockerignore to exclude node_modules, .git, .output, etc.
# 2. Use specific Node.js versions (not 'latest')
# 3. Run health checks in production
# 4. Use multi-stage builds for smaller images
# 5. Set resource limits in docker-compose or Kubernetes

# Customization Notes:
# 1. Adjust exposed ports based on your Nuxt configuration
# 2. Modify health check endpoint as needed
# 3. Add environment variables for your application
# 4. Customize build commands for your Nuxt setup
# 5. Consider using different Nitro presets (node, vercel, netlify, etc.)

# Nuxt 3 Features:
# This template supports Nuxt 3 with Nitro server engine.
# For Nuxt 2, adjust the build and runtime commands accordingly.

# Package Manager Support:
# This template automatically detects and uses:
# - npm (default)
# - yarn (if yarn.lock exists)
# - pnpm (if pnpm-lock.yaml exists)

# Nitro Preset Configuration:
# The template uses the default Nitro preset.
# To use a different preset, set the NITRO_PRESET build argument.

# SSR vs Static Generation:
# For static generation, use Nuxt's generate command and serve static files.
# For SSR, use the runtime stage as configured above.
