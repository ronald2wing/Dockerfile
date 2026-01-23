# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for Kotlin
# Website: https://kotlinlang.org/
# Repository: https://github.com/JetBrains/kotlin
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY:          Language
# · PURPOSE:           Kotlin runtime environment for modular combination
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION:       Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY:          No security patterns included - combine with security template
# · BEST PRACTICES:    Use with multi-stage builds for production deployments
# · OFFICIAL SOURCES:  Kotlin documentation and Docker best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OpenJDK for Kotlin compilation and execution
# Using specific version for reproducible builds

FROM eclipse-temurin:17-jdk-alpine AS builder

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Customize build behavior with these arguments

ARG GRADLE_VERSION=8.5
ARG KOTLIN_VERSION=1.9.0

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ENVIRONMENT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Install Gradle and setup build environment

WORKDIR /app

# Install Gradle wrapper or use system Gradle
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Copy Gradle wrapper files if available
COPY gradlew .
COPY gradle/wrapper/gradle-wrapper.properties gradle/wrapper/
COPY gradle/wrapper/gradle-wrapper.jar gradle/wrapper/

# Make gradlew executable
RUN chmod +x gradlew

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEPENDENCIES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Copy build configuration files

COPY build.gradle.kts .
COPY settings.gradle.kts .
COPY gradle.properties .

# Copy source code
COPY src ./src

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD PROCESS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Build Kotlin application

RUN ./gradlew build --no-daemon -x test

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Multi-stage build for optimized final image

FROM eclipse-temurin:17-jre-alpine AS runtime

WORKDIR /app

# Copy built artifact from builder stage
COPY --from=builder /app/build/libs/*.jar app.jar

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Environment variables and JVM options

ENV JAVA_OPTS="-Xmx512m -Xms256m"
ENV SPRING_PROFILES_ACTIVE="production"

# Health check for container orchestration
# HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
#     CMD curl -f http://localhost:8080/actuator/health || exit 1

# Expose application port (default for Spring Boot/Ktor)
EXPOSE 8080

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Start Kotlin application

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Basic Kotlin application build:
#    docker build -t kotlin-app -f kotlin.Dockerfile .
#
# 2. Development environment with mounted source code:
#    docker run -it --rm -v $(pwd):/app -p 8080:8080 kotlin-app ./gradlew bootRun
#
# 3. Build Kotlin project with custom Gradle version:
#    docker build --build-arg GRADLE_VERSION=8.6 -t kotlin-app .
#
# 4. Run Kotlin tests:
#    docker run -it --rm -v $(pwd):/app kotlin-app ./gradlew test
#
# 5. Production deployment with Spring Boot:
#    docker build -t kotlin-spring-app -f kotlin.Dockerfile .
#    docker run -d -p 8080:8080 --name kotlin-app kotlin-spring-app
#
# 6. Interactive debugging with JVM options:
#    docker run -it --rm -p 8080:8080 -e JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005" kotlin-app
#
# 7. Multi-stage build combining with pattern templates:
#    cat languages/kotlin.Dockerfile patterns/multi-stage.Dockerfile > Dockerfile
#    docker build -t optimized-kotlin-app .
#
# 8. Database integration with PostgreSQL:
#    cat languages/kotlin.Dockerfile tools/postgresql.Dockerfile > Dockerfile
#    docker build -t kotlin-postgres-app .

# BEST PRACTICES
# ==============
# • Security & Compliance:
#   - Always use version-pinned base images (openjdk:17-jdk-slim)
#   - Run as non-root user (kotlinuser) to minimize security risks
#   - Use slim or Alpine variants for reduced attack surface and image size
#   - Regularly update JDK, Gradle, and Kotlin versions for security patches
#
# • Performance & Optimization:
#   - Leverage Gradle build caching by mounting .gradle directory
#   - Use multi-stage builds to separate build dependencies from runtime
#   - Optimize JVM memory settings based on container resource limits
#   - Consider using GraalVM native image for faster startup times
#
# • Development & Operations:
#   - Mount local source code for development to enable hot-reload workflows
#   - Use Gradle wrapper for consistent builds across environments
#   - Configure proper health checks for container orchestration (Kubernetes, Docker Swarm)
#   - Set up logging and monitoring for JVM applications
#
# • Kotlin-Specific Considerations:
#   - Understand Kotlin's coroutine model for concurrent applications
#   - Configure Kotlin compiler options for optimal bytecode generation
#   - Use Kotlin's null safety features to reduce runtime exceptions
#   - Consider using Kotlin Multiplatform for cross-platform applications
#
# • Combination Patterns:
#   - Combine with frameworks/spring-boot.Dockerfile for Spring Boot applications
#   - Use with patterns/multi-stage.Dockerfile for optimized production builds
#   - Integrate with patterns/security-hardened.Dockerfile for enhanced security
#   - Combine with tools/postgresql.Dockerfile for database-backed applications
#   - Use with patterns/alpine.Dockerfile for smaller image sizes
