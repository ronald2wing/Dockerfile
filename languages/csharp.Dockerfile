# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for C#/.NET
# Website: https://dotnet.microsoft.com/
# Repository: https://github.com/dotnet/runtime
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: C#/.NET runtime configuration for Docker containers
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: Use with multi-stage builds for production deployments
# · OFFICIAL SOURCES: .NET documentation and Docker best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Choose appropriate base image based on your needs:

# Option 1: .NET SDK for building (includes runtime)
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS builder

# Option 2: .NET Runtime only (for runtime stage)
# FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime

# Option 3: Specific version with SHA
# FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine@sha256:abc123...

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG DOTNET_VERSION=8.0
ARG BUILD_CONFIGURATION=Release
ARG BUILD_ID=unknown
ARG TARGET_FRAMEWORK=net8.0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV DOTNET_VERSION=${DOTNET_VERSION} \
  BUILD_CONFIGURATION=${BUILD_CONFIGURATION} \
  BUILD_ID=${BUILD_ID} \
  TARGET_FRAMEWORK=${TARGET_FRAMEWORK} \
  DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  DOTNET_NOLOGO=1 \
  DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1 \
  ASPNETCORE_ENVIRONMENT=Production \
  ASPNETCORE_URLS=http://+:8080 \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# WORKDIR SETUP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WORKDIR /app

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEPENDENCY MANAGEMENT PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Copy project files
COPY *.sln ./
COPY */*.csproj ./
COPY */*/*.csproj ./

# Restore dependencies
RUN for file in $(ls *.csproj); do \
      mkdir -p ${file%.*} && \
      mv $file ${file%.*}/; \
    done

RUN dotnet restore

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APPLICATION BUILD PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COPY . .

# Pattern 1: Build solution
RUN dotnet build -c ${BUILD_CONFIGURATION} --no-restore

# Pattern 2: Publish application
RUN dotnet publish -c ${BUILD_CONFIGURATION} --no-build -o /app/publish

# Pattern 3: Build specific project
# RUN dotnet build ./MyProject/MyProject.csproj -c ${BUILD_CONFIGURATION} --no-restore

# Pattern 4: Publish with runtime identifier
# RUN dotnet publish -c ${BUILD_CONFIGURATION} --no-build -o /app/publish -r linux-musl-x64

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE (Multi-stage build example)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime

WORKDIR /app

# Copy published application
COPY --from=builder /app/publish .

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Expose port (default ASP.NET Core port)
EXPOSE 8080

# Create logs directory
RUN mkdir -p /app/logs && chmod 755 /app/logs

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT & COMMAND OPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Option 1: Direct .NET execution
ENTRYPOINT ["dotnet", "YourApplication.dll"]

# Option 2: Custom entrypoint script
# COPY entrypoint.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/entrypoint.sh
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# CMD ["dotnet", "YourApplication.dll"]

# Option 3: With environment configuration
# ENTRYPOINT ["dotnet", "YourApplication.dll", "--environment", "Production"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECK OPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Option 1: HTTP health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Option 2: Process health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD pgrep dotnet || exit 1

# Option 3: Custom health check script
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD /app/scripts/healthcheck.sh

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Development-specific configurations (uncomment as needed)

# Development environment
# ENV ASPNETCORE_ENVIRONMENT=Development

# Development command with watch
# CMD ["dotnet", "watch", "run", "--urls", "http://0.0.0.0:8080"]

# Install development tools
# RUN dotnet tool install --global dotnet-ef

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PERFORMANCE OPTIMIZATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Uncomment optimizations as needed:

# Enable ReadyToRun compilation
# RUN dotnet publish -c ${BUILD_CONFIGURATION} --no-build -o /app/publish -p:PublishReadyToRun=true

# Enable tiered compilation
# ENV DOTNET_TieredCompilation=1

# Enable server GC
# ENV DOTNET_gcServer=1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build production image
# docker build -t my-csharp-app:prod .

# Example 2: Build with custom build configuration
# docker build --build-arg BUILD_CONFIGURATION=Release -t my-csharp-app:prod .

# Example 3: Run development with hot reload
# docker run -d -p 8080:8080 -v $(pwd):/app --name csharp-dev my-csharp-app:dev

# Example 4: Run production with resource limits
# docker run -d \
#   -p 8080:8080 \
#   --restart unless-stopped \
#   --memory 512m \
#   --cpus 1.0 \
#   --name csharp-app \
#   my-csharp-app:prod

# Example 5: Run with Docker Compose
# docker-compose up -d

# Example 6: Build for multiple architectures
# docker buildx build --platform linux/amd64,linux/arm64 -t my-csharp-app:multi-arch .

# Example 7: Run with health check verification
# docker run -d -p 8080:8080 --health-cmd="curl -f http://localhost:8080/health || exit 1" --name csharp-app my-csharp-app:prod

# Example 8: Combine with security template
# cat languages/csharp.Dockerfile patterns/security-hardened.Dockerfile > Dockerfile

# BEST PRACTICES
# ==============

# Security Best Practices:
# • Always use non-root user for runtime execution
# • Use specific base image versions (avoid 'latest' tags)
# • Set appropriate file permissions for application directories
# • Regularly update .NET runtime and Alpine dependencies
# • Scan images for vulnerabilities using tools like Trivy or Grype

# Performance Optimization:
# • Use multi-stage builds to minimize final image size
# • Leverage layer caching by copying .csproj files first
# • Use Alpine base images for smaller footprint when compatible
# • Set appropriate resource limits (memory, CPU) in production
# • Enable ReadyToRun compilation for faster startup

# Development Workflow:
# • Use separate development and production Dockerfiles or targets
# • Mount source code as volume for hot reload during development
# • Set up proper .dockerignore to exclude bin, obj, .git
# • Use Docker Compose for local development with databases
# • Implement health checks for container orchestration

# Production Deployment:
# • Use specific version tags for production images
# • Implement proper logging with structured JSON format
# • Set up automated builds and security scanning
# • Use container orchestration (Kubernetes, Docker Swarm) for scaling
# • Implement zero-downtime deployment strategies

# C#/.NET-Specific Considerations:
# • Choose appropriate base image (Alpine for size, Debian for compatibility)
# • Configure appropriate garbage collection settings for your workload
# • Set up proper exception handling and logging
# • Implement health checks for database connections and external services
# • Use environment-specific configuration files
