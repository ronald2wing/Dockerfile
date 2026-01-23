# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for Node.js
# Website: https://nodejs.org/
# Repository: https://github.com/nodejs/node
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: Node.js runtime configuration for Docker containers
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: Use with multi-stage builds for production deployments
# · OFFICIAL SOURCES: Node.js documentation and Docker best practices

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

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV NODE_ENV=${NODE_ENV} \
  BUILD_ID=${BUILD_ID} \
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

# Pattern 3: With audit fix
# COPY package*.json ./
# RUN npm install --omit=dev && \
#     npm audit fix --only=prod --force || true && \
#     npm cache clean --force

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
# Option 1: Direct node execution
# ENTRYPOINT ["node"]
# CMD ["server.js"]

# Option 2: npm script execution
# ENTRYPOINT ["npm"]
# CMD ["start"]

# Option 3: Custom entrypoint script
# COPY entrypoint.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/entrypoint.sh
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# CMD ["node", "server.js"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECK OPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Option 1: HTTP health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD node -e "require('http').get('http://localhost:3000/health', (r) => { \
#         process.exit(r.statusCode === 200 ? 0 : 1); \
#     }).on('error', () => process.exit(1))"

# Option 2: Process health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD pgrep node || exit 1

# Option 3: Custom health check script
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD /app/scripts/healthcheck.sh

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Development-specific configurations (uncomment as needed)

# Install development dependencies
# RUN npm ci --only=development

# Install global tools
# RUN npm install -g nodemon ts-node typescript

# Development command with hot reload
# CMD ["npm", "run", "dev"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PERFORMANCE OPTIMIZATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Uncomment optimizations as needed:

# Increase kernel limits for high-performance applications
# RUN echo "fs.file-max = 100000" >> /etc/sysctl.conf && \
#     echo "net.core.somaxconn = 1024" >> /etc/sysctl.conf

# Set ulimits
# RUN ulimit -n 65536

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Basic build
# docker build -t nodejs-app .
# docker run -p 3000:3000 nodejs-app

# Example 2: Build with custom arguments
# docker build \
#   --build-arg NODE_VERSION=20 \
#   --build-arg NODE_ENV=production \
#   -t nodejs:1.0.0 .

# Example 3: Multi-stage build
# cat languages/node.Dockerfile patterns/multi-stage.Dockerfile > Dockerfile
# docker build -t nodejs-multi-stage .

# Example 4: With security hardening
# cat languages/node.Dockerfile patterns/security-hardened.Dockerfile > Dockerfile
# docker build -t nodejs-secure .

# Example 5: Complete production setup
# cat languages/node.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/security-hardened.Dockerfile \
#     patterns/docker-compose.Dockerfile > Dockerfile

# Example 6: Development environment
# cat languages/node.Dockerfile patterns/development.Dockerfile > Dockerfile
# docker build -t nodejs-dev .

# Example 7: CI/CD integration
# cat languages/node.Dockerfile patterns/ci-cd.Dockerfile > Dockerfile
# docker build \
#   --build-arg CI=true \
#   --build-arg CI_COMMIT_SHA=$CI_COMMIT_SHA \
#   -t nodejs:$CI_COMMIT_SHA .

# Example 8: With monitoring
# cat languages/node.Dockerfile patterns/monitoring.Dockerfile > Dockerfile
# docker build -t nodejs-monitored .

# BEST PRACTICES
# ==============

# 1. Node.js Language Best Practices:
#    • Use specific version tags for base images (not 'latest')
#    • Implement multi-stage builds for production
#    • Run as non-root user in production environments
#    • Clean npm cache to reduce image size
#    • Use environment variables for configuration
#    • Implement health checks for container orchestration
#    • Scan images for vulnerabilities before deployment
#    • Use .dockerignore to exclude unnecessary files
#    • Follow Node.js coding standards and conventions
#    • Implement proper error handling and logging

# 2. Security Considerations:
#    • This template provides Node.js runtime configuration
#    • Combine with patterns/security-hardened.Dockerfile for security
#    • Use secrets management for sensitive data
#    • Implement proper input validation
#    • Use HTTPS/TLS for network communication
#    • Regularly update Node.js runtime and dependencies
#    • Follow principle of least privilege
#    • Monitor for security vulnerabilities

# 3. Performance Optimization:
#    • Use Alpine variants for smaller images when possible
#    • Implement layer caching optimization
#    • Use multi-stage builds to exclude build tools
#    • Optimize dependency installation order
#    • Use appropriate resource limits
#    • Implement connection pooling for database access
#    • Use caching strategies for improved performance
#    • Profile and optimize application code

# 4. Development Workflow:
#    • Use development patterns for local development
#    • Implement hot reload for faster iteration
#    • Configure debugging for IDE integration
#    • Use Docker Compose for multi-service setups
#    • Implement automated testing
#    • Use linting and static analysis tools
#    • Follow Node.js development patterns

# 5. Combination Patterns:
#    • This template is designed to be combined with pattern templates
#    • Always combine with security-hardened.Dockerfile for production
#    • Use multi-stage.Dockerfile for build optimization
#    • Add monitoring.Dockerfile for observability
#    • Implement CI/CD patterns for automated deployment
#    • Consider framework templates for complete applications
