# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for Java
# Website: https://java.com/
# Repository: https://github.com/openjdk/jdk
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: Java runtime configuration for Docker containers
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: Use with multi-stage builds for production deployments
# · OFFICIAL SOURCES: Java documentation and Docker best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Choose appropriate base image based on your needs:

# Option 1: Eclipse Temurin JDK (recommended - official OpenJDK distribution)
FROM eclipse-temurin:17-jdk

# Option 2: Eclipse Temurin JRE (runtime only, smaller)
# FROM eclipse-temurin:17-jre

# Option 3: Alpine variant (smallest)
# FROM eclipse-temurin:17-jdk-alpine

# Option 4: Specific version with SHA
# FROM eclipse-temurin:17-jdk@sha256:abc123...

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG JAVA_VERSION=17
ARG JAVA_ENV=production
ARG BUILD_ID=unknown

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV JAVA_VERSION=${JAVA_VERSION} \
  JAVA_ENV=${JAVA_ENV} \
  BUILD_ID=${BUILD_ID} \
  JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0" \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# WORKDIR SETUP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WORKDIR /app

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APPLICATION DEPLOYMENT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Copy application JAR file
COPY target/*.jar app.jar

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Expose port (customize for your application)
EXPOSE 8080

# Create logs directory
RUN mkdir -p /app/logs && chmod 755 /app/logs

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT & COMMAND OPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Option 1: Simple JAR execution
# ENTRYPOINT ["java", "-jar", "app.jar"]

# Option 2: With Java options
# ENTRYPOINT ["java", "$JAVA_OPTS", "-jar", "app.jar"]

# Option 3: Spring Boot specific
# ENTRYPOINT ["java", \
#   "-Djava.security.egd=file:/dev/./urandom", \
#   "-XX:+UseContainerSupport", \
#   "-XX:MaxRAMPercentage=75.0", \
#   "-jar", "app.jar"]

# Option 4: Custom entrypoint script
# COPY entrypoint.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/entrypoint.sh
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# CMD ["java", "-jar", "app.jar"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECK OPTIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Option 1: HTTP health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD curl -f http://localhost:8080/actuator/health || exit 1

# Option 2: Process health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD pgrep java || exit 1

# Option 3: Custom health check script
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD /app/scripts/healthcheck.sh

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Development-specific configurations (uncomment as needed)

# Install Maven for building
# RUN apt-get update && apt-get install -y maven

# Development command with debugging
# CMD ["java", \
#   "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005", \
#   "-jar", "app.jar"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PERFORMANCE OPTIMIZATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Uncomment optimizations as needed:

# Add JVM performance options
# ENV JAVA_OPTS="-XX:+UseContainerSupport \
#   -XX:MaxRAMPercentage=75.0 \
#   -XX:+UseG1GC \
#   -XX:MaxGCPauseMillis=200 \
#   -XX:ParallelGCThreads=2 \
#   -XX:ConcGCThreads=2 \
#   -XX:InitiatingHeapOccupancyPercent=35"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Basic build
# docker build -t java-app .
# docker run -p 8080:8080 java-app

# Example 2: Build with custom arguments
# docker build \
#   --build-arg VERSION=1.0.0 \
#   --build-arg ENVIRONMENT=production \
#   -t java:1.0.0 .

# Example 3: Multi-stage build
# cat languages/java.Dockerfile patterns/multi-stage.Dockerfile > Dockerfile
# docker build -t java-multi-stage .

# Example 4: With security hardening
# cat languages/java.Dockerfile patterns/security-hardened.Dockerfile > Dockerfile
# docker build -t java-secure .

# Example 5: Complete production setup
# cat languages/java.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/security-hardened.Dockerfile \
#     patterns/docker-compose.Dockerfile > Dockerfile

# Example 6: Development environment
# cat languages/java.Dockerfile patterns/development.Dockerfile > Dockerfile
# docker build -t java-dev .

# Example 7: CI/CD integration
# cat languages/java.Dockerfile patterns/ci-cd.Dockerfile > Dockerfile
# docker build \
#   --build-arg CI=true \
#   --build-arg CI_COMMIT_SHA=$CI_COMMIT_SHA \
#   -t java:$CI_COMMIT_SHA .

# Example 8: With monitoring
# cat languages/java.Dockerfile patterns/monitoring.Dockerfile > Dockerfile
# docker build -t java-monitored .

# BEST PRACTICES
# ==============

# 1. Java Language Best Practices:
#    • Use specific version tags for base images (not 'latest')
#    • Implement multi-stage builds for production
#    • Run as non-root user in production environments
#    • Clean package manager caches to reduce image size
#    • Use environment variables for configuration
#    • Implement health checks for container orchestration
#    • Scan images for vulnerabilities before deployment
#    • Use .dockerignore to exclude unnecessary files
#    • Follow Java coding standards and conventions
#    • Implement proper error handling and logging

# 2. Security Considerations:
#    • This template provides Java runtime configuration
#    • Combine with patterns/security-hardened.Dockerfile for security
#    • Use secrets management for sensitive data
#    • Implement proper input validation
#    • Use HTTPS/TLS for network communication
#    • Regularly update Java runtime and dependencies
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
#    • Follow Java development patterns

# 5. Combination Patterns:
#    • This template is designed to be combined with pattern templates
#    • Always combine with security-hardened.Dockerfile for production
#    • Use multi-stage.Dockerfile for build optimization
#    • Add monitoring.Dockerfile for observability
#    • Implement CI/CD patterns for automated deployment
#    • Consider framework templates for complete applications
