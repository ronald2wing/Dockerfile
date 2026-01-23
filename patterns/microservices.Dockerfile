# ==============================================================================
# Created by https://Dockerfile.io/
# Pattern TEMPLATE for Microservices Architecture
# Website: https://microservices.io/
# Repository: https://github.com/microservices
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Pattern
# · PURPOSE: Patterns for building microservices with Docker
# · DESIGN PHILOSOPHY: Reusable patterns for microservices architecture
# · COMBINATION: Combine with language and framework templates
# · SECURITY: Service isolation, network security, API gateways
# · BEST PRACTICES: Circuit breakers, service discovery, distributed tracing
# · OFFICIAL SOURCES: Microservices patterns documentation

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MICROSERVICE BASE PATTERN - Foundation for all microservices
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# This section provides the base pattern for microservices
# Combine with language templates (e.g., languages/node.Dockerfile)

# Base image selection - use specific version for reproducibility
# FROM node:18-alpine  # Example for Node.js microservices
# FROM python:3.11-alpine  # Example for Python microservices
# FROM eclipse-temurin:17-jdk-alpine  # Example for Java microservices

# Build arguments for microservice configuration
ARG SERVICE_NAME=unknown-service
ARG SERVICE_VERSION=1.0.0
ARG SERVICE_PORT=3000
ARG ENVIRONMENT=production

# Environment variables for service configuration
ENV SERVICE_NAME=${SERVICE_NAME} \
    SERVICE_VERSION=${SERVICE_VERSION} \
    SERVICE_PORT=${SERVICE_PORT} \
    ENVIRONMENT=${ENVIRONMENT} \
    NODE_ENV=${ENVIRONMENT} \
    PYTHONUNBUFFERED=1 \
    JAVA_OPTS="-XX:+UseContainerSupport"

# Labels for service discovery and orchestration
LABEL maintainer="Dockerfile.io" \
      description="Microservice: ${SERVICE_NAME}" \
      version="${SERVICE_VERSION}" \
      environment="${ENVIRONMENT}" \
      service.name="${SERVICE_NAME}" \
      service.port="${SERVICE_PORT}" \
      source="https://github.com/ronald2wing/Dockerfile"

# Create non-root user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -S -u 1001 -G appgroup appuser

# Set working directory
WORKDIR /app

# Copy application files (to be completed by combining with language template)
# COPY package*.json ./  # For Node.js
# COPY requirements.txt ./  # For Python
# COPY pom.xml ./  # For Java

# Install dependencies (to be completed by combining with language template)
# RUN npm ci --omit=dev  # For Node.js
# RUN pip install -r requirements.txt  # For Python
# RUN mvn clean package  # For Java

# Copy application source code
# COPY src/ ./src/
# COPY *.py ./  # For Python
# COPY *.java ./  # For Java

# Build application (to be completed by combining with language template)
# RUN npm run build  # For Node.js
# RUN python -m compileall .  # For Python
# RUN javac *.java  # For Java

# Set permissions
RUN chown -R appuser:appgroup /app && \
    chmod -R 750 /app

# Switch to non-root user
USER appuser

# Expose service port
EXPOSE ${SERVICE_PORT:-3000}

# Health check for service discovery
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:$${SERVICE_PORT}/health || exit 1

# Service entrypoint (to be completed by combining with language template)
# CMD ["node", "src/server.js"]  # For Node.js
# CMD ["python", "app.py"]  # For Python
# CMD ["java", "-jar", "app.jar"]  # For Java

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# API GATEWAY PATTERN - For routing and API management
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# This pattern can be combined with tools/nginx.Dockerfile or tools/traefik.Dockerfile

# API Gateway configuration example
# Use with: cat patterns/microservices.Dockerfile tools/nginx.Dockerfile > Dockerfile

# API Gateway environment variables
ENV GATEWAY_PORT=8080 \
    GATEWAY_NAME=api-gateway \
    ROUTING_CONFIG=/etc/nginx/conf.d/default.conf \
    UPSTREAM_SERVICES=service1:3000,service2:3001,service3:3002

# API Gateway labels
LABEL gateway.name="${GATEWAY_NAME}" \
      gateway.port="${GATEWAY_PORT}" \
      gateway.type="nginx"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SERVICE DISCOVERY PATTERN - For dynamic service registration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# This pattern enables service discovery in microservices architecture

# Service discovery configuration
ENV DISCOVERY_SERVER=consul:8500 \
    DISCOVERY_ENABLED=true \
    SERVICE_CHECK_INTERVAL=10s \
    SERVICE_CHECK_TIMEOUT=5s

# Service registration command (example for Consul)
# RUN echo '#!/bin/sh\n\
# consul agent -config-dir=/etc/consul.d &\n\
# sleep 5\n\
# consul services register -name=${SERVICE_NAME} -port=${SERVICE_PORT} -address=$(hostname -i)\n\
# exec "$@"' > /entrypoint.sh && chmod +x /entrypoint.sh

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CIRCUIT BREAKER PATTERN - For resilience and fault tolerance
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Circuit breaker configuration for resilient microservices

ENV CIRCUIT_BREAKER_ENABLED=true \
    CIRCUIT_BREAKER_FAILURE_THRESHOLD=5 \
    CIRCUIT_BREAKER_TIMEOUT=30000 \
    CIRCUIT_BREAKER_RESET_TIMEOUT=60000

# Circuit breaker implementation would be in application code
# This provides environment variables for configuration

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DISTRIBUTED TRACING PATTERN - For observability
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Distributed tracing configuration for microservices observability

ENV TRACING_ENABLED=true \
    TRACING_SERVER=jaeger:6831 \
    TRACING_SAMPLING_RATE=0.1 \
    TRACING_SERVICE_NAME=${SERVICE_NAME}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Create Node.js microservice
# cat patterns/microservices.Dockerfile languages/node.Dockerfile > Dockerfile
# docker build --build-arg SERVICE_NAME=user-service -t user-service .

# Example 2: Create Python microservice
# cat patterns/microservices.Dockerfile languages/python.Dockerfile > Dockerfile
# docker build --build-arg SERVICE_NAME=payment-service -t payment-service .

# Example 3: Create Java microservice
# cat patterns/microservices.Dockerfile languages/java.Dockerfile > Dockerfile
# docker build --build-arg SERVICE_NAME=order-service -t order-service .

# Example 4: Create microservice with API Gateway
# cat patterns/microservices.Dockerfile tools/nginx.Dockerfile > Dockerfile
# docker build --build-arg GATEWAY_NAME=api-gateway -t api-gateway .

# Example 5: Create monitored microservice
# cat patterns/microservices.Dockerfile patterns/monitoring.Dockerfile > Dockerfile
# docker build -t monitored-microservice .

# Example 6: Create microservice with security hardening
# cat patterns/microservices.Dockerfile patterns/security-hardened.Dockerfile > Dockerfile
# docker build --build-arg SERVICE_NAME=secure-service -t secure-service .

# Example 7: Create microservice with distributed tracing
# cat patterns/microservices.Dockerfile patterns/monitoring.Dockerfile > Dockerfile
# docker build --build-arg SERVICE_NAME=tracing-service -t tracing-service .

# Example 8: Complete microservices stack with Docker Compose
# docker-compose up -d

# BEST PRACTICES
# ==============

# Architecture Best Practices:
# • Design services around business capabilities, not technical layers
# • Implement API Gateway for routing, authentication, and rate limiting
# • Use service discovery for dynamic service registration and discovery
# • Implement circuit breakers for resilience and fault tolerance
# • Use distributed tracing for observability across service boundaries
# • Design stateless services for horizontal scalability
# • Implement proper service boundaries with clear APIs
# • Use event-driven architecture for loose coupling

# Security Best Practices:
# • Implement service-to-service authentication and authorization
# • Use API Gateway for centralized security policies
# • Implement network segmentation and service mesh for security
# • Use secrets management for sensitive configuration
# • Implement proper logging and monitoring for security events
# • Use TLS for all service-to-service communication
# • Implement rate limiting and DDoS protection
# • Regularly audit service permissions and access controls

# Performance Optimization:
# • Implement caching strategies at multiple levels
# • Use connection pooling for database and external service calls
# • Implement proper load balancing across service instances
# • Use asynchronous communication for non-critical operations
# • Monitor and optimize database queries and external API calls
# • Implement proper resource limits and quotas
# • Use content delivery networks for static assets
# • Implement compression for network payloads

# Operations & Maintenance:
# • Use specific version tags for all service images
# • Implement blue-green or canary deployment strategies
# • Use health checks and readiness probes for service orchestration
# • Implement automated rollback mechanisms
# • Monitor service metrics and implement alerting
# • Use centralized logging for all services
# • Implement automated testing for service integrations
# • Regularly update dependencies and base images

# Microservices-Specific Considerations:
# • Configure appropriate timeouts and retry policies
# • Implement idempotent operations for reliability
# • Use correlation IDs for request tracing
# • Implement proper error handling and fallback strategies
# • Design for eventual consistency where appropriate
# • Use message queues for reliable asynchronous communication
# • Implement proper service versioning and backward compatibility
# • Monitor service dependencies and failure modes

# Development & Testing:
# • Use Docker Compose for local development environments
# • Implement contract testing for service interfaces
# • Use service virtualization for external dependencies
# • Implement comprehensive integration testing
# • Use canary testing in staging environments
# • Monitor performance under realistic load patterns
# • Implement chaos engineering for resilience testing
# • Use automated deployment pipelines
