# ==============================================================================
# Created by https://Dockerfile.io/
# Pattern TEMPLATE for Distroless Containers
# Website: https://github.com/GoogleContainerTools/distroless
# Repository: https://github.com/GoogleContainerTools/distroless
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Pattern
# · PURPOSE: Minimal container patterns using Google's Distroless base images
# · DESIGN PHILOSOPHY: Security-focused, minimal attack surface, no shell or package manager
# · COMBINATION: Use as final stage in multi-stage builds with language templates
# · SECURITY: No shell, minimal packages, non-root execution
# · BEST PRACTICES: Multi-stage builds, minimal dependencies, security scanning
# · OFFICIAL SOURCES: Distroless documentation and container security best practices
#
# IMPORTANT: Distroless images contain only your application and its runtime dependencies.
# They have no shell or package manager, making them more secure but harder to debug.

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DISTROLESS BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Available Distroless base images (choose based on your runtime needs):

# For static binaries (Go, Rust, C/C++):
# FROM gcr.io/distroless/static:nonroot

# For Node.js applications:
# FROM gcr.io/distroless/nodejs18:nonroot

# For Java applications:
# FROM gcr.io/distroless/java17:nonroot

# For Python applications:
# FROM gcr.io/distroless/python3:nonroot

# For .NET applications:
# FROM gcr.io/distroless/dotnet:nonroot

# Debug images (with shell, for debugging only):
# FROM gcr.io/distroless/nodejs18-debug:nonroot

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MULTI-STAGE BUILD PATTERN EXAMPLE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Example: Node.js application with Distroless final stage
# FROM node:18-alpine AS builder
# WORKDIR /app
# COPY package*.json ./
# RUN npm install --omit=dev
# COPY . .
# RUN npm run build
#
# FROM gcr.io/distroless/nodejs18:nonroot AS production
# WORKDIR /app
# COPY --from=builder --chown=nonroot:nonroot /app/dist ./dist
# COPY --from=builder --chown=nonroot:nonroot /app/package*.json ./
# USER nonroot
# CMD ["node", "dist/index.js"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Non-root user configuration (already set in Distroless images)
# USER nonroot

# Security context for Kubernetes (example annotations)
# LABEL security.context="nonroot:nonroot"
# LABEL security.seccomp="runtime/default"
# LABEL security.apparmor="runtime/default"

# Resource limits (set at runtime or in orchestration)
# ENV NODE_OPTIONS="--max-old-space-size=512"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEBUGGING CONSIDERATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# For debugging, use debug variants or ephemeral containers
# Debug variant example (has shell):
# FROM gcr.io/distroless/nodejs18-debug:nonroot

# Ephemeral container debugging (Kubernetes):
# kubectl debug -it pod-name --image=busybox --target=container-name

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES
# ==============
# 1. Node.js application with Distroless:
#    FROM node:18-alpine AS builder
#    WORKDIR /app
#    COPY package*.json ./
#    RUN npm install --omit=dev
#    COPY . .
#    RUN npm run build
#
#    FROM gcr.io/distroless/nodejs18:nonroot
#    COPY --from=builder --chown=nonroot:nonroot /app/dist ./dist
#    USER nonroot
#    CMD ["node", "dist/index.js"]
#
# 2. Go application with static Distroless:
#    FROM golang:1.21-alpine AS builder
#    WORKDIR /app
#    COPY . .
#    RUN CGO_ENABLED=0 go build -o app .
#
#    FROM gcr.io/distroless/static:nonroot
#    COPY --from=builder --chown=nonroot:nonroot /app/app .
#    USER nonroot
#    CMD ["./app"]
#
# 3. Java application with Distroless:
#    FROM maven:3.9-eclipse-temurin-17 AS builder
#    WORKDIR /app
#    COPY . .
#    RUN mvn clean package -DskipTests
#
#    FROM gcr.io/distroless/java17:nonroot
#    COPY --from=builder --chown=nonroot:nonroot /app/target/app.jar .
#    USER nonroot
#    CMD ["app.jar"]
#
# 4. Python application with Distroless:
#    FROM python:3.11-slim AS builder
#    WORKDIR /app
#    COPY requirements.txt .
#    RUN pip install --user --no-cache-dir -r requirements.txt
#    COPY . .
#
#    FROM gcr.io/distroless/python3:nonroot
#    COPY --from=builder --chown=nonroot:nonroot /root/.local /root/.local
#    COPY --from=builder --chown=nonroot:nonroot /app .
#    USER nonroot
#    CMD ["python", "app.py"]
#
# 5. Debug variant for troubleshooting:
#    FROM gcr.io/distroless/nodejs18-debug:nonroot
#    COPY --from=builder --chown=nonroot:nonroot /app/dist ./dist
#    USER nonroot
#    CMD ["node", "dist/index.js"]
#
# 6. Multi-architecture builds with Distroless:
#    FROM --platform=$BUILDPLATFORM node:18-alpine AS builder
#    WORKDIR /app
#    COPY package*.json ./
#    RUN npm install --omit=dev
#    COPY . .
#    RUN npm run build
#
#    FROM --platform=$TARGETPLATFORM gcr.io/distroless/nodejs18:nonroot
#    COPY --from=builder --chown=nonroot:nonroot /app/dist ./dist
#    USER nonroot
#    CMD ["node", "dist/index.js"]
#
# 7. Health checks with Distroless:
#    HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#      CMD ["node", "-e", "require('http').get('http://localhost:3000', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"]
#
# 8. Resource limits configuration:
#    ENV NODE_OPTIONS="--max-old-space-size=256"
#    ENV JAVA_TOOL_OPTIONS="-Xmx256m"

# BEST PRACTICES
# ==============
# Security:
# • Always use nonroot variants of Distroless images
# • No shell means reduced attack surface but harder debugging
# • Regular security scanning of both builder and final images
# • Use debug variants only for development/troubleshooting

# Performance:
# • Distroless images are typically smaller than Alpine-based images
# • Multi-stage builds essential for Distroless patterns
# • Copy only necessary files from builder stage
# • Use appropriate Distroless variant for your runtime

# Development:
# • Develop and test with standard images first
# • Switch to Distroless for production builds
# • Use debug variants when troubleshooting is needed
# • Implement comprehensive logging in your application

# Operations:
# • Health checks must be implemented in your application
# • Monitoring and logging must be application-level
# • Resource limits should be configured appropriately
# • Consider using ephemeral containers for debugging

# Maintenance:
# • Regularly update Distroless base images
# • Test with new versions of your runtime
# • Monitor for security vulnerabilities
# • Update build process as Distroless evolves

# Combination Patterns:
# • Combine with patterns/multi-stage.Dockerfile for optimal builds
# • Combine with patterns/security-hardened.Dockerfile for additional security
# • Combine with languages/*.Dockerfile for language-specific optimizations
# • Combine with tools/ monitoring tools for observability

# Distroless-Specific Considerations:
# • No package manager means all dependencies must be in builder stage
# • No shell means debugging requires alternative approaches
# • Smaller attack surface improves security posture
# • Ideal for production deployments where security is critical
# • Consider compatibility with your orchestration platform
