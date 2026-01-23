# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for TypeScript
# Website: https://www.typescriptlang.org/
# Repository: https://github.com/microsoft/TypeScript
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: TypeScript compilation and runtime configuration for Docker containers
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: Use with multi-stage builds for production deployments
# · OFFICIAL SOURCES: TypeScript documentation and Docker best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Choose appropriate base image based on your needs:

# Option 1: Alpine (smallest)
FROM node:18-alpine

# Option 2: Slim (Debian-based, smaller than full)
# FROM node:18-slim

# Option 3: Full (includes build tools)
# FROM node:18

# Option 4: Specific version with SHA
# FROM node:18-alpine@sha256:abc123...

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG NODE_ENV=production
ARG NODE_VERSION=18
ARG BUILD_ID=unknown
ARG TSC_COMPILE_ON_ERROR=false

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV NODE_ENV=${NODE_ENV} \
  BUILD_ID=${BUILD_ID} \
  TSC_COMPILE_ON_ERROR=${TSC_COMPILE_ON_ERROR} \
  npm_config_update_notifier=false \
  npm_config_cache=/tmp/.npm \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8 \
  NODE_OPTIONS="--max-old-space-size=4096"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# WORKDIR SETUP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WORKDIR /app

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEPENDENCY MANAGEMENT PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Pattern 1: Production dependencies only
COPY package*.json ./
RUN npm install --omit=dev && \
  npm cache clean --force

# Pattern 2: All dependencies (for development)
# COPY package*.json ./
# RUN npm ci && \
#     npm cache clean --force

# Pattern 3: With TypeScript and dev dependencies
# COPY package*.json ./
# RUN npm ci && \
#     npm cache clean --force

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TYPE SCRIPT COMPILATION PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Copy TypeScript configuration
COPY tsconfig.json ./

# Copy TypeScript source code
COPY src ./src

# Pattern 1: Compile TypeScript to JavaScript
RUN npx tsc --project tsconfig.json

# Pattern 2: Compile with error handling
# RUN if [ "$TSC_COMPILE_ON_ERROR" = "true" ]; then \
#     npx tsc --project tsconfig.json || true; \
#   else \
#     npx tsc --project tsconfig.json; \
#   fi

# Pattern 3: Watch mode for development (uncomment for development stage)
# CMD ["npx", "tsc", "--project", "tsconfig.json", "--watch"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APPLICATION DEPLOYMENT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COPY . .

# Build application (if needed)
RUN npm run build --if-present

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Expose port (customize for your application)
EXPOSE 3000

# Create logs directory
RUN mkdir -p /app/logs && chmod 755 /app/logs

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT & COMMAND OPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Option 1: Direct node execution with compiled JavaScript
# ENTRYPOINT ["node"]
# CMD ["dist/index.js"]

# Option 2: ts-node execution (for development)
# ENTRYPOINT ["npx", "ts-node"]
# CMD ["src/index.ts"]

# Option 3: npm script execution
# ENTRYPOINT ["npm"]
# CMD ["start"]

# Option 4: Custom entrypoint script
# COPY entrypoint.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/entrypoint.sh
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# CMD ["node", "dist/index.js"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build basic TypeScript image
# docker build -t my-typescript-app:v1.0.0 .

# Example 2: Build with custom arguments
# docker build \
#   --build-arg NODE_VERSION=18 \
#   --build-arg NODE_ENV=production \
#   --build-arg BUILD_ID=$(git rev-parse --short HEAD) \
#   -t my-typescript-app:$(git rev-parse --short HEAD) .

# Example 3: Run TypeScript application
# docker run -d \
#   -p 3000:3000 \
#   --name typescript-app \
#   --memory=512m \
#   --cpus=1.0 \
#   my-typescript-app:v1.0.0

# Example 4: Development with volume mounting
# docker run -d \
#   -p 3000:3000 \
#   -v $(pwd):/app \
#   --name typescript-dev \
#   my-typescript-app:dev

# Example 5: Test execution
# docker run --rm my-typescript-app:test npm test

# Example 6: Shell access for debugging
# docker run -it --rm my-typescript-app:v1.0.0 /bin/sh

# Example 7: Combine with pattern templates
# cat languages/typescript.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/security-hardened.Dockerfile > Dockerfile

# Example 8: Production deployment with monitoring
# cat languages/typescript.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/security-hardened.Dockerfile \
#     patterns/monitoring.Dockerfile > Dockerfile

# BEST PRACTICES
# ==============

# 1. Always pin Node.js and TypeScript versions
# 2. Use .dockerignore to exclude node_modules, dist, .git, etc.
# 3. Use multi-stage builds for production deployments
# 4. Run as non-root user in production for security
# 5. Use health checks for container orchestration
# 6. Clean package caches to reduce image size
# 7. Use environment variables for configuration
# 8. Implement proper logging and monitoring

# TypeScript-Specific Considerations:
# • Compile TypeScript to JavaScript during build stage
# • Use type checking in CI/CD pipeline
# • Configure tsconfig.json appropriately for Docker
# • Use source maps for debugging in development
# • Implement proper error handling and type safety

# Security Recommendations:
# 1. Always combine with security-hardened template for production
# 2. Scan for vulnerabilities with npm audit or snyk
# 3. Use dependency isolation and version pinning
# 4. Regularly update dependencies for security patches
# 5. Use secrets management for sensitive data

# Performance Optimization:
# 1. Optimize TypeScript compilation with incremental builds
# 2. Use appropriate base images (Alpine for smaller size)
# 3. Implement connection pooling where applicable
# 4. Use build cache effectively
# 5. Minimize layer count through command combination

# Development Configuration:
# • Install development dependencies including TypeScript
# • Use TypeScript tools: typescript, ts-node, nodemon
# • Enable hot reload for development
# • Configure source maps for debugging
# • Set up testing with TypeScript support

# Health Check Options:
# 1. HTTP health check: Check /health endpoint
# 2. Process health check: Verify Node.js process is running
# 3. Custom health check: Implement application-specific checks

# Combination Patterns:
# 1. This template is designed to be combined with pattern templates
# 2. Always combine with security-hardened.Dockerfile for production
# 3. Use multi-stage.Dockerfile for optimized builds
# 4. Consider adding monitoring.Dockerfile for observability
# 5. Add ci-cd.Dockerfile for automated pipeline integration
