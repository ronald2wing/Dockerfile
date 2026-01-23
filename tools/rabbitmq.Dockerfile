# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for RabbitMQ
# Website: https://www.rabbitmq.com/
# Repository: https://github.com/rabbitmq/rabbitmq-server
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Production-ready RabbitMQ message broker with security hardening
# · DESIGN PHILOSOPHY: Self-contained with security configurations
# · COMBINATION: Use standalone for RabbitMQ deployments
# · SECURITY: Non-root user, secure credentials, TLS/SSL support
# · BEST PRACTICES: Persistent volumes, clustering, monitoring, resource limits
# · OFFICIAL SOURCES: RabbitMQ documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Official RabbitMQ image with management plugin
# Using specific version for reproducible builds

FROM rabbitmq:3.13-management-alpine

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Customize RabbitMQ installation

ARG RABBITMQ_VERSION=3.13.0
ARG ERLANG_VERSION=25.3.2

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Environment variables for secure configuration

ENV RABBITMQ_DATA_DIR=/var/lib/rabbitmq
ENV RABBITMQ_CONFIG_FILE=/etc/rabbitmq/rabbitmq.conf
ENV RABBITMQ_CONF_ENV_FILE=/etc/rabbitmq/rabbitmq-env.conf
ENV RABBITMQ_LOGS=/var/log/rabbitmq
ENV RABBITMQ_SASL_LOGS=/var/log/rabbitmq/sasl.log

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PLUGINS AND EXTENSIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Enable additional plugins for production use

RUN rabbitmq-plugins enable --offline \
    rabbitmq_management \
    rabbitmq_management_agent \
    rabbitmq_prometheus \
    rabbitmq_peer_discovery_k8s \
    rabbitmq_auth_backend_ldap \
    rabbitmq_sharding \
    rabbitmq_consistent_hash_exchange \
    rabbitmq_event_exchange

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURATION FILES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create configuration directory

RUN mkdir -p /etc/rabbitmq && \
    chown rabbitmq:rabbitmq /etc/rabbitmq

COPY rabbitmq.conf /etc/rabbitmq/
COPY definitions.json /etc/rabbitmq/
COPY enabled_plugins /etc/rabbitmq/

# Set permissions
RUN chown rabbitmq:rabbitmq /etc/rabbitmq/* && \
    chmod 640 /etc/rabbitmq/*

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SSL/TLS CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create SSL directory and set up certificates (if provided)

RUN mkdir -p /etc/rabbitmq/ssl && \
    chown rabbitmq:rabbitmq /etc/rabbitmq/ssl && \
    chmod 750 /etc/rabbitmq/ssl

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECKS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Health checks for container orchestration

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD rabbitmq-diagnostics -q ping || exit 1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PORTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Expose RabbitMQ ports

EXPOSE 5672   # AMQP protocol
EXPOSE 15672  # Management UI
EXPOSE 15692  # Prometheus metrics
EXPOSE 25672  # Erlang distribution
EXPOSE 4369   # Erlang port mapper
EXPOSE 5671   # AMQP SSL
EXPOSE 15671  # Management UI SSL

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VOLUMES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Data volumes for persistence

VOLUME ["/var/lib/rabbitmq", "/var/log/rabbitmq", "/etc/rabbitmq/ssl"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Start RabbitMQ server

ENTRYPOINT ["docker-entrypoint.sh"]
USER rabbitmq
CMD ["rabbitmq-server"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Basic RabbitMQ deployment:
#    docker build -t rabbitmq-server -f rabbitmq.Dockerfile .
#    docker run -p 5672:5672 -p 15672:15672 --name rabbitmq rabbitmq-server
#
# 2. Production deployment with custom credentials:
#    docker build -t rabbitmq-prod .
#    docker run -d -p 5672:5672 -p 15672:15672 \
#      -e RABBITMQ_DEFAULT_USER=admin \
#      -e RABBITMQ_DEFAULT_PASS=securepassword \
#      -v rabbitmq-data:/var/lib/rabbitmq \
#      --restart unless-stopped --memory 2g --cpus 2 --name rabbitmq-prod rabbitmq-prod
#
# 3. Development with mounted configuration:
#    docker run -it --rm -p 5672:5672 -p 15672:15672 \
#      -v $(pwd)/config:/etc/rabbitmq \
#      -v rabbitmq-dev-data:/var/lib/rabbitmq --name rabbitmq-dev rabbitmq-server
#
# 4. SSL/TLS enabled deployment:
#    docker run -d -p 5671:5671 -p 15671:15671 \
#      -v ./ssl:/etc/rabbitmq/ssl \
#      -v rabbitmq-data:/var/lib/rabbitmq --name rabbitmq-tls rabbitmq-server
#
# 5. High-availability cluster deployment:
#    # Node 1
#    docker run -d -p 5672:5672 -p 15672:15672 \
#      -e RABBITMQ_ERLANG_COOKIE=secret-cookie \
#      -e RABBITMQ_NODENAME=rabbit@node1 \
#      -v rabbitmq-data-1:/var/lib/rabbitmq --name rabbitmq-1 rabbitmq-server
#    # Node 2
#    docker run -d -p 5673:5672 -p 15673:15672 \
#      -e RABBITMQ_ERLANG_COOKIE=secret-cookie \
#      -e RABBITMQ_NODENAME=rabbit@node2 \
#      -v rabbitmq-data-2:/var/lib/rabbitmq --name rabbitmq-2 rabbitmq-server
#
# 6. Monitoring stack with Prometheus:
#    cat tools/rabbitmq.Dockerfile tools/prometheus.Dockerfile > Dockerfile
#    docker build -t rabbitmq-monitoring .
#
# 7. Message processing pipeline:
#    cat tools/rabbitmq.Dockerfile languages/python.Dockerfile > Dockerfile
#    docker build -t rabbitmq-python-processor .
#
# 8. Complete messaging solution:
#    cat tools/rabbitmq.Dockerfile patterns/microservices.Dockerfile > Dockerfile
#    docker build -t messaging-microservices .

# BEST PRACTICES
# ==============
# • Security & Compliance:
#   - Always change default credentials (guest/guest) in production
#   - Use SSL/TLS encryption for network communication
#   - Set secure Erlang cookie value and keep it confidential
#   - Implement network policies to restrict access to RabbitMQ ports
#   - Regularly update RabbitMQ and Erlang for security patches
#
# • Performance & Optimization:
#   - Configure appropriate memory limits (RABBITMQ_VM_MEMORY_HIGH_WATERMARK)
#   - Set disk free limits to prevent disk space exhaustion
#   - Monitor queue depths and connection counts for performance tuning
#   - Implement appropriate exchange types based on use case patterns
#
# • Development & Operations:
#   - Use named volumes for persistent message storage
#   - Implement proper health checks for container orchestration
#   - Configure resource limits (CPU, memory) based on workload
#   - Set up monitoring for queue depths, connection counts, and message rates
#
# • RabbitMQ-Specific Considerations:
#   - Understand AMQP protocol and RabbitMQ's messaging patterns
#   - Implement dead letter exchanges for error handling and message recovery
#   - Set message TTL (time-to-live) where appropriate to prevent queue buildup
#   - Implement queue length limits to prevent memory exhaustion
#   - Use appropriate exchange types (direct, topic, fanout, headers)
#
# • Combination Patterns:
#   - Combine with tools/prometheus.Dockerfile for metrics collection
#   - Use with patterns/monitoring.Dockerfile for comprehensive monitoring
#   - Integrate with patterns/security-hardened.Dockerfile for enhanced security
#   - Combine with patterns/docker-compose.Dockerfile for multi-service deployments
#   - Use with languages/python.Dockerfile for message processing applications
