# ==============================================================================
# Created by https://Dockerfile.io/
# Framework TEMPLATE for Spring Boot
# Website: https://spring.io/projects/spring-boot
# Repository: https://github.com/spring-projects/spring-boot
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Framework
# · PURPOSE: Production-ready Spring Boot application with security hardening
# · DESIGN PHILOSOPHY: Self-contained with multi-stage builds and security
# · COMBINATION: Use standalone for complete Spring Boot applications
# · SECURITY: Non-root user, Alpine base, health monitoring
# · BEST PRACTICES: Layer caching, dependency optimization, production defaults
# · OFFICIAL SOURCES: Spring Boot documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Application compilation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM maven:3.9-eclipse-temurin-17-alpine AS builder

# Build arguments for environment configuration
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG MAVEN_OPTS="-DskipTests"

# Environment variables for build process
ENV BUILD_ID=${BUILD_ID} \
  COMMIT_SHA=${COMMIT_SHA} \
  MAVEN_OPTS=${MAVEN_OPTS} \
  MAVEN_CONFIG=/root/.m2

WORKDIR /app

# Copy Maven configuration files first for optimal layer caching
COPY pom.xml ./
COPY mvnw ./
COPY .mvn .mvn

# Download dependencies (cached layer)
RUN mvn dependency:go-offline -B

COPY src ./src

RUN mvn clean package -DskipTests

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Production deployment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM eclipse-temurin:17-jre-alpine AS runtime

# Security: Create non-root user
RUN addgroup -g 1001 -S appgroup && \
  adduser -S -u 1001 -G appgroup appuser

# Production environment configuration
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0" \
  SPRING_PROFILES_ACTIVE=production \
  UMASK=0027

WORKDIR /app

# Copy built JAR from builder stage
COPY --from=builder --chown=appuser:appgroup /app/target/*.jar app.jar

# Create directories with secure permissions
RUN mkdir -p /app/logs /app/tmp && \
  chown -R appuser:appgroup /app/logs /app/tmp && \
  chmod 750 /app/logs /app/tmp

# Switch to non-root user
USER appuser

EXPOSE 8080

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Default command to run Spring Boot application
STOPSIGNAL SIGTERM
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT STAGE - Hot reload environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM maven:3.9-eclipse-temurin-17-alpine AS development

WORKDIR /app

# Copy Maven configuration files
COPY pom.xml ./
COPY mvnw ./
COPY .mvn .mvn

# Download dependencies
RUN mvn dependency:go-offline -B

COPY src ./src

# Development environment variables
ENV SPRING_PROFILES_ACTIVE=development \
  MAVEN_OPTS="-Dspring-boot.run.profiles=development"

# Development command with Spring Boot DevTools
CMD ["mvn", "spring-boot:run"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ALTERNATIVE CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Option 1: Gradle build instead of Maven
# FROM gradle:7.6-jdk17-alpine AS builder
# WORKDIR /app
# COPY gradle* ./
# COPY build.gradle ./
# COPY settings.gradle ./
# COPY src ./src
# RUN gradle build --no-daemon

# Option 2: Native image with GraalVM
# FROM ghcr.io/graalvm/native-image:ol8-java17-22 AS builder
# WORKDIR /app
# COPY . .
# RUN native-image -jar target/*.jar --no-fallback -H:Name=app

# Option 3: JLink for custom JRE
# RUN $JAVA_HOME/bin/jlink \
#   --add-modules java.base,java.logging,java.xml,java.naming,java.sql,java.management \
#   --strip-debug \
#   --no-man-pages \
#   --no-header-files \
#   --compress=2 \
#   --output /opt/jre-minimal

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Build production image
# docker build --target runtime -t my-spring-app:prod .

# Example 2: Build development image
# docker build --target development -t my-spring-app:dev .

# Example 3: Build with custom arguments
# docker build \
#   --build-arg BUILD_ID=$(git rev-parse --short HEAD) \
#   --build-arg MAVEN_OPTS="-DskipTests -Dspring.profiles.active=prod" \
#   -t my-spring-app:$(git rev-parse --short HEAD) .

# Example 4: Run production container
# docker run -d -p 8080:8080 --name spring-app my-spring-app:prod

# Example 5: Run development container with volume mount
# docker run -d -p 8080:8080 -v $(pwd):/app --name spring-dev my-spring-app:dev

# Best Practices:
# 1. Always use .dockerignore to exclude target/, .git, etc.
# 2. Use specific Java versions (not 'latest')
# 3. Run health checks in production (Spring Actuator)
# 4. Use multi-stage builds for smaller images
# 5. Set resource limits in docker-compose or Kubernetes

# Customization Notes:
# 1. Adjust JVM memory settings based on container resources
# 2. Modify exposed ports based on your application
# 3. Customize health check endpoint (Spring Actuator)
# 4. Add environment variables for database connections
# 5. Configure logging appropriately for containerized environments
