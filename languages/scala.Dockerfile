# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for Scala
# Website: https://www.scala-lang.org/
# Repository: https://github.com/scala/scala
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: Scala runtime environment for modular combination
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: Version pinning, layer optimization, dependency management
# · OFFICIAL SOURCES: Scala documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE - Scala runtime with essential dependencies
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM eclipse-temurin:17-jdk-alpine

# Build arguments for environment configuration
ARG SCALA_VERSION=2.13.12
ARG SBT_VERSION=1.9.7
ARG JAVA_VERSION=17

# Environment variables for runtime
ENV SCALA_VERSION=${SCALA_VERSION} \
    SBT_VERSION=${SBT_VERSION} \
    JAVA_VERSION=${JAVA_VERSION} \

    SBT_OPTS="-Xmx2G -XX:+UseG1GC -XX:+UseStringDeduplication" \
    JAVA_OPTS="-Xmx2G -XX:+UseG1GC" \
    JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport"

# Install Scala and sbt
RUN apk add --no-cache \
    bash \
    curl \
    git \
    openssl && \
    curl -fsSL "https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" | \
    tar -xz -C /usr/local && \
    ln -s /usr/local/scala-${SCALA_VERSION}/bin/scala /usr/local/bin/scala && \
    ln -s /usr/local/scala-${SCALA_VERSION}/bin/scalac /usr/local/bin/scalac && \
    ln -s /usr/local/scala-${SCALA_VERSION}/bin/scaladoc /usr/local/bin/scaladoc && \
    curl -fsSL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | \
    tar -xz -C /usr/local && \
    ln -s /usr/local/sbt/bin/sbt /usr/local/bin/sbt


WORKDIR /app


# Default command (can be overridden)
CMD ["scala", "-version"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Basic Scala application build:
#    docker build -t my-scala-app .
#
# 2. Build with custom Scala version:
#    docker build --build-arg SCALA_VERSION=3.3.1 -t my-scala-app .
#
# 3. Build with custom sbt version:
#    docker build --build-arg SBT_VERSION=1.9.8 -t my-scala-app .
#
# 4. Run Scala REPL interactively:
#    docker run -it --rm my-scala-app scala
#
# 5. Compile Scala source file:
#    docker run --rm -v $(pwd):/app my-scala-app scalac Main.scala
#
# 6. Run compiled Scala class:
#    docker run --rm -v $(pwd):/app my-scala-app scala Main
#
# 7. Use sbt for project management:
#    docker run --rm -v $(pwd):/app my-scala-app sbt compile
#
# 8. Multi-stage build with this template:
#    # Use this template as base stage, then add your application build

# BEST PRACTICES
# ==============
# • VERSION PINNING: Always pin Scala, sbt, and JDK versions for reproducibility
# • LAYER OPTIMIZATION: Structure Dockerfile to maximize layer caching
# • DEPENDENCY MANAGEMENT: Use sbt for dependency resolution and caching
# • SECURITY CONFIGURATION: Always run as non-root user in production
# • RESOURCE MANAGEMENT: Configure JVM memory limits based on container resources
# • BUILD OPTIMIZATION: Use sbt incremental compilation for faster builds
# • TESTING INTEGRATION: Integrate sbt test phase in CI/CD pipeline
# • MONITORING: Add health checks for long-running Scala applications

# SCALA-SPECIFIC CONSIDERATIONS
# • JVM TUNING: Adjust JVM options based on application requirements
# • SBT CACHING: Leverage sbt's incremental compilation and dependency caching
# • SCALA 2/3 COMPATIBILITY: Be aware of compatibility between Scala versions
# • METALS INTEGRATION: Consider IDE support for better development experience

# COMBINATION PATTERNS
# • Combine with patterns/multi-stage.Dockerfile for optimized production builds
# • Combine with patterns/security-hardened.Dockerfile for enhanced security
# • Combine with frameworks/play-framework.Dockerfile for web applications
# • Combine with tools/postgresql.Dockerfile for database applications
