# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Astro
# Website: https://astro.build/
# Repository: https://github.com/withastro/astro
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Astro application with security hardening
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security
# · COMBINATION: Use standalone for complete Astro applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: Astro documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Application compilation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS builder

# Build arguments for environment configuration
ARG NODE_ENV=production
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown

# Environment variables for build process
ENV NODE_ENV=${NODE_ENV} \
  BUILD_ID=${BUILD_ID} \
  COMMIT_SHA=${COMMIT_SHA} \
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

# Build Astro application
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
  npm_config_update_notifier=false \
  UMASK=0027

WORKDIR /app

# Copy built artifacts from builder stage with proper ownership
COPY --from=builder --chown=appuser:appgroup /app/package*.json ./
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/public ./public

# Create directories with secure permissions
RUN mkdir -p /app/logs /app/tmp && \
  chown -R appuser:appgroup /app/logs /app/tmp && \
  chmod 750 /app/logs /app/tmp

# Switch to non-root user
USER appuser

EXPOSE 4321

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:4321', (r) => { \
  process.exit(r.statusCode === 200 ? 0 : 1); \
  }).on('error', () => process.exit(1))"

# Serve static build with npx serve
STOPSIGNAL SIGTERM
ENTRYPOINT ["npx", "serve", "-s", "dist"]
CMD ["-l", "4321"]

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
# docker build --target runtime -t my-astro-app:prod .

# Example 2: Build development image
# docker build --target development -t my-astro-app:dev .

# Example 3: Build with custom arguments
# docker build \
#   --build-arg NODE_ENV=production \
#   --build-arg BUILD_ID=$(git rev-parse --short HEAD) \
#   -t my-astro-app:$(git rev-parse --short HEAD) .

# Example 4: Run production container
# docker run -d -p 4321:4321 --name astro-app my-astro-app:prod

# Example 5: Run development container
# docker run -d -p 4321:4321 -v $(pwd):/app --name astro-dev my-astro-app:dev

# Example 6: Build with adapter-specific configuration
# docker build \
#   --build-arg ADAPTER=node \
#   -t my-astro-app:node .

# Best Practices:
# 1. Always use .dockerignore to exclude node_modules, .git, dist, etc.
# 2. Use specific Node.js versions (not 'latest')
# 3. Run health checks in production
# 4. Use multi-stage builds for smaller images
# 5. Set resource limits in docker-compose or Kubernetes

# Customization Notes:
# 1. Adjust exposed ports based on your Astro configuration
# 2. Modify health check endpoint as needed
# 3. Add environment variables for your application
# 4. Customize build commands for your Astro setup
# 5. Consider using different adapters (node, static, netlify, etc.)

# Astro Adapter Support:
# This template supports all Astro adapters. For adapter-specific configurations:
# 1. Node adapter: Uses the runtime stage above
# 2. Static adapter: Builds to static files served by npx serve
# 3. Netlify/Vercel adapters: May require additional runtime configuration

# Package Manager Support:
# This template automatically detects and uses:
# - npm (default)
# - yarn (if yarn.lock exists)
# - pnpm (if pnpm-lock.yaml exists)
