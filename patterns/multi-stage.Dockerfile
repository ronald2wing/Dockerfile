# ==============================================================================
# Created by https://Dockerfile.io/
# Pattern TEMPLATE for Multi-Stage Builds
# Website: https://docs.docker.com/
# Repository: https://github.com/docker-library/official-images
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Pattern
# · PURPOSE: Multi-stage build patterns for all projects
# · DESIGN PHILOSOPHY: Modular patterns for combination with language templates
# · COMBINATION: Combine with language or framework templates
# · SECURITY: Reduces attack surface by excluding build tools
# · BEST PRACTICES: Layer caching optimization, deterministic builds
# · OFFICIAL SOURCES: Docker documentation and community best practices
#
# IMPORTANT: Framework templates already include multi-stage patterns.
# Use this template with language templates for granular control.

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASIC TWO-STAGE PATTERN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Stage 1: Builder stage (includes build tools)
FROM base-image:tag AS stage-builder

# Set build arguments
ARG BUILD_ENV=production
ARG VERSION=1.0.0
ARG BUILD_ID=unknown

# Set environment variables
ENV NODE_ENV=${BUILD_ENV} \
    BUILD_VERSION=${VERSION} \
    BUILD_ID=${BUILD_ID}

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency files first for optimal layer caching
COPY package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev --no-audit --no-fund

# Copy application code
COPY . .

# Build application
RUN npm run build

# Stage 2: Runtime stage (minimal, production-only)
FROM base-image:alpine AS stage-runtime

# Create non-root user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -S -u 1001 -G appgroup appuser

# Set working directory
WORKDIR /app

# Copy built artifacts from builder stage with proper ownership
COPY --from=stage-builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=stage-builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=stage-builder --chown=appuser:appgroup /app/package*.json ./

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 3000

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["node", "dist/index.js"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# THREE-STAGE PATTERN (WITH TESTING)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Stage 1: Dependencies
FROM base-image:tag AS stage-deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

# Stage 2: Builder (with tests)
FROM stage-deps AS stage-builder-test
COPY . .
RUN npm run build && npm test  # Run build and tests together

# Stage 3: Runtime
FROM base-image:alpine AS stage-runtime-test
WORKDIR /app
COPY --from=stage-builder-test /app/dist ./dist
COPY --from=stage-builder-test /app/node_modules ./node_modules

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MULTI-ARCHITECTURE PATTERN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Build for multiple architectures using buildx
# Usage: docker buildx build --platform linux/amd64,linux/arm64 -t myapp:multi-arch .

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LANGUAGE-SPECIFIC PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Python multi-stage pattern
# FROM python:3.11-slim AS python-builder
# WORKDIR /app
# COPY requirements.txt .
# RUN pip install --user -r requirements.txt
# COPY . .
#
# FROM python:3.11-alpine AS python-runtime
# WORKDIR /app
# COPY --from=python-builder /root/.local /root/.local
# COPY --from=python-builder /app .
# ENV PATH=/root/.local/bin:$PATH

# Go multi-stage pattern
# FROM golang:1.21-alpine AS go-builder
# WORKDIR /app
# COPY go.mod go.sum ./
# RUN go mod download
# COPY . .
# RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .
#
# FROM alpine:3.19 AS go-runtime
# WORKDIR /app
# COPY --from=go-builder /app/main .
# CMD ["./main"]

# Java multi-stage pattern
# FROM maven:3.9-eclipse-temurin-17 AS java-builder
# WORKDIR /app
# COPY pom.xml .
# RUN mvn dependency:go-offline
# COPY src ./src
# RUN mvn clean package -DskipTests
#
# FROM eclipse-temurin:17-jre-alpine AS java-runtime
# WORKDIR /app
# COPY --from=java-builder /app/target/*.jar app.jar
# ENTRYPOINT ["java", "-jar", "/app.jar"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ADVANCED PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Pattern 1: Development stage
FROM base-image:tag AS stage-development
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
CMD ["npm", "run", "dev"]

# Pattern 2: Testing stage
FROM stage-development AS stage-testing
RUN npm test

# Pattern 3: Production stage (from testing - ensures tests passed)
FROM base-image:alpine AS stage-production
WORKDIR /app
COPY --from=stage-testing /app/dist ./dist
COPY --from=stage-testing /app/node_modules ./node_modules
CMD ["node", "dist/server.js"]

# Pattern 4: Security scan stage
FROM stage-production AS stage-security-scan
USER root
RUN apk add --no-cache curl jq
USER appuser
# Note: This stage doesn't have CMD/ENTRYPOINT - root access is temporary for tool installation

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build specific stage
# docker build --target stage-builder -t myapp:builder .

# Example 2: Build runtime only
# docker build --target stage-runtime -t myapp:runtime .

# Example 3: Build with arguments
# docker build \
#   --build-arg BUILD_ENV=production \
#   --build-arg VERSION=1.0.0 \
#   -t myapp:1.0.0 .

# Example 4: Multi-architecture build
# docker buildx build \
#   --platform linux/amd64,linux/arm64 \
#   -t myapp:multi-arch .

# Example 5: Development build
# docker build --target stage-development -t myapp:dev .

# Example 6: Test build
# docker build --target stage-testing -t myapp:test .

# Example 7: Complete combination with language template
# cat languages/node.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/security-hardened.Dockerfile > Dockerfile

# Example 8: Multi-stage with testing
# cat languages/python.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/ci-cd.Dockerfile > Dockerfile

# BEST PRACTICES
# ==============

# 1. Always use multi-stage builds for production deployments
# 2. Use specific base image versions (never use 'latest' tags)
# 3. Order instructions from least to most frequently changing for optimal caching
# 4. Combine RUN commands to reduce layer count and image size
# 5. Clean package manager caches in the same RUN command
# 6. Use alpine variants for smaller runtime images
# 7. Leverage build cache effectively by copying dependency files first
# 8. Test each stage independently to ensure quality
# 9. Use .dockerignore to exclude unnecessary files from build context
# 10. Scan final images for vulnerabilities before deployment

# 11. Security Considerations:
#    • Use non-root users in runtime stages
#    • Remove build tools from final images
#    • Scan images for vulnerabilities
#    • Use content trust for image verification

# 12. Performance Optimization:
#    • Use BuildKit for faster builds
#    • Implement layer caching strategies
#    • Use multi-architecture builds when needed
#    • Optimize Dockerfile instruction order

# 13. Combination Patterns:
#    • This template is designed to be combined with language/framework templates
#    • Always combine with security-hardened.Dockerfile for production
#    • Use ci-cd.Dockerfile for automated pipeline integration
#    • Consider adding monitoring.Dockerfile for observability

# 14. Template Customization:
#    • Replace base-image:tag with your specific base image
#    • Update package*.json patterns for your dependency files
#    • Modify npm commands to match your build/run commands
#    • Adapt language patterns for your technology stack
#    • Combine with language templates for complete solutions
