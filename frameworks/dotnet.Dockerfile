# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for .NET Core
# Website: https://dotnet.microsoft.com/
# Repository: https://github.com/dotnet/core
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready .NET Core application with security hardening
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security
# · COMBINATION: Use standalone for complete .NET Core applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: .NET Core documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Application compilation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS builder

# Build arguments for environment configuration
ARG BUILD_CONFIGURATION=Release
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown

# Environment variables for build process
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  DOTNET_NOLOGO=1 \
  BUILD_CONFIGURATION=${BUILD_CONFIGURATION} \
  BUILD_ID=${BUILD_ID} \
  COMMIT_SHA=${COMMIT_SHA}

WORKDIR /src

# Copy project files first for optimal layer caching
COPY *.csproj ./
RUN dotnet restore

COPY . .

# Build application
RUN dotnet build -c ${BUILD_CONFIGURATION} --no-restore

# Publish application
RUN dotnet publish -c ${BUILD_CONFIGURATION} --no-build -o /app/publish

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Production deployment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S -u 1001 -G appgroup appuser

# Production environment configuration
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  DOTNET_NOLOGO=1 \
  ASPNETCORE_URLS=http://+:8080 \
  ASPNETCORE_ENVIRONMENT=Production \
  UMASK=0027

WORKDIR /app

# Copy published application from builder stage
COPY --from=builder --chown=appuser:appgroup /app/publish .

# Switch to non-root user
USER appuser

# Create directories with secure permissions
RUN mkdir -p /app/logs /app/tmp && \
  chmod 750 /app/logs /app/tmp

EXPOSE 8080

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Run .NET Core application
STOPSIGNAL SIGTERM
ENTRYPOINT ["dotnet", "YourApp.dll"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT STAGE - Hot reload environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS development

WORKDIR /src

# Development environment configuration
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  DOTNET_NOLOGO=1 \
  ASPNETCORE_ENVIRONMENT=Development

# Copy project files
COPY *.csproj ./
RUN dotnet restore

COPY . .

# Development command with hot reload
CMD ["dotnet", "watch", "run", "--urls", "http://0.0.0.0:8080"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Build production image
# docker build --target runtime -t my-dotnet-app:prod .

# Example 2: Build development image
# docker build --target development -t my-dotnet-app:dev .

# Example 3: Build with custom arguments
# docker build \
#   --build-arg BUILD_CONFIGURATION=Release \
#   --build-arg BUILD_ID=$(git rev-parse --short HEAD) \
#   -t my-dotnet-app:$(git rev-parse --short HEAD) .

# Example 4: Run production container
# docker run -d -p 8080:8080 --name dotnet-app my-dotnet-app:prod

# Example 5: Run development container
# docker run -d -p 8080:8080 -v $(pwd):/src --name dotnet-dev my-dotnet-app:dev

# Best Practices:
# 1. Always use .dockerignore to exclude bin/, obj/, .git, etc.
# 2. Use specific .NET versions (not 'latest')
# 3. Run health checks in production
# 4. Use multi-stage builds for smaller images
# 5. Set resource limits in docker-compose or Kubernetes

# Customization Notes:
# 1. Replace "YourApp.dll" with your actual DLL name
# 2. Adjust exposed ports based on your application
# 3. Modify health check endpoint as needed
# 4. Add environment variables for your application
# 5. Customize build configuration for your project
