# ==============================================================================
# Created by https://Dockerfile.io/
# Pattern TEMPLATE for Monitoring
# Website: https://docs.docker.com/
# Repository: https://github.com/docker-library/official-images
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Pattern
# · PURPOSE: Add monitoring, health checks, and observability to applications
# · DESIGN PHILOSOPHY: Modular patterns for combination with language/framework templates
# · COMBINATION: Combine with language or framework templates
# · SECURITY: Secure monitoring endpoints with authentication
# · BEST PRACTICES: Health checks, metrics exposure, structured logging
# · OFFICIAL SOURCES: Docker documentation and observability best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MONITORING CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# This section adds monitoring capabilities to your application
# Include these patterns in your Dockerfile for production monitoring

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECKS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Comprehensive health checks for container orchestration
# Note: Docker supports a single HEALTHCHECK — use the one that best fits your needs

# Application health check (adjust command based on your framework)
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:$${PORT:-3000}/health || exit 1

# Alternative: Liveness probe (is the application running?)
# HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
#     CMD curl -f http://localhost:3000/ || exit 1

# Alternative: Readiness probe (is the application ready to serve traffic?)
# HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
#     CMD curl -f http://localhost:3000/ready || exit 1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# METRICS EXPOSURE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Environment variables for metrics collection

# Prometheus metrics endpoint (common for many frameworks)
ENV METRICS_PORT=9090
ENV METRICS_PATH=/metrics

# OpenTelemetry configuration
ENV OTEL_SERVICE_NAME=${APP_NAME:-my-application}
ENV OTEL_RESOURCE_ATTRIBUTES=service.name=${APP_NAME:-my-application}
ENV OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317

# Application performance monitoring
ENV DD_AGENT_HOST=datadog-agent
ENV DD_TRACE_AGENT_PORT=8126
ENV DD_ENV=production

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# LOGGING CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Structured logging for better observability

# JSON logging for machine readability
ENV LOG_FORMAT=json
ENV LOG_LEVEL=info

# Log aggregation
ENV LOGSTASH_HOST=logstash
ENV LOGSTASH_PORT=5000

# Application logging
ENV NODE_ENV=production
ENV JAVA_TOOL_OPTIONS="-Dlogging.level.root=INFO -Dlogging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RESOURCE MONITORING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Resource limits and monitoring

# JVM memory settings (for Java applications)
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -XX:+PrintGCDetails -XX:+PrintGCDateStamps"

# Node.js memory settings
ENV NODE_OPTIONS="--max-old-space-size=512"

# Python memory settings
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MONITORING TOOLS INSTALLATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Install monitoring agents and tools (optional - include based on needs)

# For Node.js applications:
# RUN npm install --save prom-client dd-trace

# For Python applications:
# RUN pip install prometheus-client opentelemetry-sdk

# For Java applications:
# Add Micrometer or Dropwizard Metrics to your dependencies

# For Go applications:
# Add prometheus/client_golang to your dependencies

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY FOR MONITORING ENDPOINTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Security considerations for monitoring endpoints

# Basic authentication for metrics endpoints (example for nginx)
# ENV METRICS_USERNAME=admin
# ENV METRICS_PASSWORD=$(openssl rand -base64 32)

# IP whitelisting for monitoring endpoints
# ENV ALLOWED_METRICS_IPS="10.0.0.0/8,192.168.0.0/16"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Combine with framework template for monitoring:
#    cat frameworks/spring-boot.Dockerfile \
#        patterns/monitoring.Dockerfile > Dockerfile
#
# 2. Combine with multiple patterns:
#    cat frameworks/express.Dockerfile \
#        patterns/monitoring.Dockerfile \
#        patterns/security-hardened.Dockerfile > Dockerfile
#
# 3. Add health checks to existing application:
#    # Copy health check section from this template
#    HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
#        CMD curl -f http://localhost:${PORT:-3000}/health || exit 1
#
# 4. Configure metrics exposure:
#    # Add metrics environment variables
#    ENV METRICS_PORT=9090
#    ENV METRICS_PATH=/metrics
#
# 5. Set up structured logging:
#    ENV LOG_FORMAT=json
#    ENV LOG_LEVEL=info
#
# 6. Configure resource monitoring:
#    # Add JVM memory settings for Java applications
#    ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC"
#
# 7. Install monitoring tools:
#    # For Node.js applications
#    RUN npm install --save prom-client dd-trace
#
# 8. Secure monitoring endpoints:
#    # Add basic authentication for metrics
#    ENV METRICS_USERNAME=admin
#    ENV METRICS_PASSWORD=$(openssl rand -base64 32)

# BEST PRACTICES
# ==============
# • HEALTH MONITORING: Implement comprehensive health checks for container orchestration
# • METRICS COLLECTION: Expose standardized metrics endpoints for monitoring systems
# • STRUCTURED LOGGING: Use JSON format for machine-readable log aggregation
# • RESOURCE MANAGEMENT: Set appropriate memory and CPU limits for applications
# • PERFORMANCE MONITORING: Implement application performance monitoring (APM)
# • DISTRIBUTED TRACING: Use OpenTelemetry for end-to-end request tracing
# • SECURITY HARDENING: Secure monitoring endpoints with authentication and encryption
# • ALERTING CONFIGURATION: Set up meaningful alerts based on key performance indicators

# MONITORING-SPECIFIC CONSIDERATIONS
# • METRICS CARDINALITY: Be mindful of metrics cardinality to avoid performance issues
# • TRACE SAMPLING: Implement appropriate trace sampling rates (1-10% for production)
# • LOG RETENTION: Define log retention policies based on compliance requirements
# • MONITORING STACK: Choose appropriate monitoring tools (Prometheus, Grafana, etc.)
# • OBSERVABILITY: Focus on metrics, logs, and traces for comprehensive observability

# SECURITY CONSIDERATIONS
# • ENDPOINT PROTECTION: Never expose monitoring endpoints publicly without authentication
# • DATA ENCRYPTION: Use TLS/SSL for monitoring data in transit
# • ACCESS CONTROL: Implement role-based access control for monitoring systems
# • CREDENTIAL MANAGEMENT: Regularly rotate monitoring credentials and API keys
# • AUDIT LOGGING: Maintain audit logs for monitoring system access and configuration changes

# PERFORMANCE OPTIMIZATION
# • METRICS AGGREGATION: Aggregate metrics to reduce storage and query overhead
# • LOG SAMPLING: Implement log sampling for high-volume applications
# • DATA COMPRESSION: Compress monitoring data in transit and at rest
# • RETENTION POLICIES: Define appropriate data retention periods for monitoring data
# • QUERY OPTIMIZATION: Optimize monitoring queries for performance and efficiency

# COMBINATION PATTERNS
# • Combine with patterns/security-hardened.Dockerfile for secure monitoring
# • Combine with patterns/docker-compose.Dockerfile for monitoring stack deployment
# • Combine with tools/prometheus.Dockerfile for metrics collection
# • Combine with tools/grafana.Dockerfile for visualization
# • Combine with any framework template for application-specific monitoring
