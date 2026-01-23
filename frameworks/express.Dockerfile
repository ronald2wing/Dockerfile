# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Express
# Website: https://expressjs.com/
# Repository: https://github.com/expressjs/express
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Express API server with security hardening
# · DESIGN PHILOSOPHY: Minimal, secure, and production-focused with multi-stage builds
# · COMBINATION: Use standalone for Express APIs and microservices
# · SECURITY: Non-root user, security headers, request validation
# · BEST PRACTICES: Helmet.js integration, rate limiting, logging, health checks
# · OFFICIAL SOURCES: Express documentation and Node.js security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Dependency installation
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

# Install production dependencies only
RUN npm ci --omit=dev && \
  npm cache clean --force

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
  UMASK=0027 \
  PORT=3000

WORKDIR /app

# Copy built artifacts from builder stage with proper ownership
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --chown=appuser:appgroup package*.json ./
COPY --chown=appuser:appgroup . .

# Create directories with secure permissions
RUN mkdir -p /app/logs /app/tmp && \
  chown -R appuser:appgroup /app/logs /app/tmp && \
  chmod 750 /app/logs /app/tmp

# Switch to non-root user
USER appuser

EXPOSE 3000

# Health check for API server
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => { \
  process.exit(r.statusCode === 200 ? 0 : 1); \
  }).on('error', () => process.exit(1))"

# Start Express application
STOPSIGNAL SIGTERM
CMD ["node", "server.js"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT STAGE - Hot reload environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS development

# Set development environment variables
ENV NODE_ENV=development \
  npm_config_update_notifier=false

WORKDIR /app

COPY package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm ci

COPY . .

# Development command with nodemon for hot reload
CMD ["npx", "nodemon", "server.js"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TESTING STAGE - Unit and integration testing
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM node:18-alpine AS testing

# Set testing environment variables
ENV NODE_ENV=test

WORKDIR /app

COPY package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm ci

COPY . .

# Test command
CMD ["npm", "test"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Build production image
# docker build --target runtime -t my-express-api:prod .

# Example 2: Build development image
# docker build --target development -t my-express-api:dev .

# Example 3: Build testing image
# docker build --target testing -t my-express-api:test .

# Example 4: Run production container
# docker run -d -p 3000:3000 --name express-api my-express-api:prod

# Example 5: Run development container with hot reload
# docker run -d -p 3000:3000 -v $(pwd):/app --name express-dev my-express-api:dev

# Example 6: Run tests
# docker run --rm my-express-api:test

# Recommended Express server.js structure:
# const express = require('express');
# const helmet = require('helmet');
# const cors = require('cors');
# const rateLimit = require('express-rate-limit');
# const morgan = require('morgan');
#
# const app = express();
# const port = process.env.PORT || 3000;
#
# // Security middleware
# app.use(helmet());
# app.use(cors());
# app.use(express.json());
# app.use(express.urlencoded({ extended: true }));
#
# // Rate limiting
# const limiter = rateLimit({
#   windowMs: 15 * 60 * 1000, // 15 minutes
#   max: 100 // limit each IP to 100 requests per windowMs
# });
# app.use('/api/', limiter);
#
# // Logging
# app.use(morgan('combined'));
#
# // Health check endpoint
# app.get('/health', (req, res) => {
#   res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
# });
#
# // Your routes here
# app.get('/', (req, res) => {
#   res.json({ message: 'Express API is running' });
# });
#
# // Error handling middleware
# app.use((err, req, res, next) => {
#   console.error(err.stack);
#   res.status(500).json({ error: 'Something went wrong!' });
# });
#
# app.listen(port, () => {
#   console.log(`Server running on port ${port}`);
# });

# Recommended package.json dependencies:
# {
#   "dependencies": {
#     "express": "^4.18.0",
#     "helmet": "^7.0.0",
#     "cors": "^2.8.5",
#     "express-rate-limit": "^6.0.0",
#     "morgan": "^1.10.0"
#   },
#   "devDependencies": {
#     "nodemon": "^2.0.0",
#     "jest": "^29.0.0",
#     "supertest": "^6.0.0"
#   }
# }

# Best Practices:
# 1. Always use .dockerignore to exclude node_modules, .git, logs, etc.
# 2. Implement proper error handling and logging
# 3. Use environment variables for configuration
# 4. Set up request validation and sanitization
# 5. Implement rate limiting to prevent abuse
# 6. Use HTTPS in production (terminate at reverse proxy)
# 7. Set up monitoring and alerting
# 8. Implement proper CORS configuration

# Customization Notes:
# 1. Adjust Node.js version based on your project requirements
# 2. Modify security middleware configuration as needed
# 3. Add database connections and connection pooling
# 4. Implement authentication and authorization
# 5. Add request/response compression
# 6. Set up distributed tracing for microservices
# 7. Configure graceful shutdown handling
