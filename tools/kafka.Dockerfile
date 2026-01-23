# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for Kafka
# Website: https://kafka.apache.org/
# Repository: https://github.com/apache/kafka
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Production-ready Apache Kafka message broker with security hardening
# · DESIGN PHILOSOPHY: Self-contained with security configurations
# · COMBINATION: Use standalone for Kafka deployments
# · SECURITY: Non-root user, authentication, encrypted communication
# · BEST PRACTICES: Resource limits, persistent storage, monitoring
# · OFFICIAL SOURCES: Kafka documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OpenJDK base for Kafka (Kafka requires Java)
# Using specific version for reproducible builds

FROM eclipse-temurin:17-jre-focal AS kafka

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Customize Kafka installation

ARG KAFKA_VERSION=3.6.1
ARG SCALA_VERSION=2.13
ARG KAFKA_HOME=/opt/kafka

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# INSTALLATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Download and install Kafka

WORKDIR /tmp

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download Kafka
RUN curl -fsSL "https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
    -o kafka.tgz && \
    tar -xzf kafka.tgz -C /opt && \
    mv "/opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}" "${KAFKA_HOME}" && \
    rm kafka.tgz

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create non-root user for security

RUN groupadd -r kafkagroup && \
    useradd -r -g kafkagroup -m -s /bin/false kafkauser

# Set permissions
RUN chown -R kafkauser:kafkagroup "${KAFKA_HOME}" && \
    chmod -R 750 "${KAFKA_HOME}"

WORKDIR "${KAFKA_HOME}"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create configuration directory and files

RUN mkdir -p /etc/kafka && \
    chown kafkauser:kafkagroup /etc/kafka

COPY --chown=kafkauser:kafkagroup server.properties /etc/kafka/
COPY --chown=kafkauser:kafkagroup zookeeper.properties /etc/kafka/

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Kafka configuration environment variables

ENV KAFKA_HOME="${KAFKA_HOME}"
ENV PATH="${KAFKA_HOME}/bin:${PATH}"
ENV KAFKA_LOG_DIRS="/var/lib/kafka"
ENV KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"
ENV KAFKA_OPTS="-Djava.security.auth.login.config=/etc/kafka/jaas.conf"

# Create data directory
RUN mkdir -p "${KAFKA_LOG_DIRS}" && \
    chown kafkauser:kafkagroup "${KAFKA_LOG_DIRS}"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECKS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Health checks for container orchestration

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD kafka-broker-api-versions.sh --bootstrap-server localhost:9092 || exit 1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PORTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Expose Kafka ports
# 9092: Kafka broker
# 9093: Kafka SSL
# 9094: Kafka SASL_SSL
# 9999: JMX monitoring

EXPOSE 9092 9093 9094 9999

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VOLUMES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Data volumes for persistence

VOLUME ["/var/lib/kafka", "/etc/kafka"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Start Kafka broker

USER kafkauser

ENTRYPOINT ["kafka-server-start.sh"]
CMD ["/etc/kafka/server.properties"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build Kafka image
# docker build -t my-kafka:3.6.1 .

# Example 2: Run standalone Kafka with embedded ZooKeeper
# docker run -d \
#   --name kafka-standalone \
#   -p 9092:9092 \
#   -e KAFKA_BROKER_ID=1 \
#   -e KAFKA_ZOOKEEPER_CONNECT=localhost:2181 \
#   my-kafka:3.6.1

# Example 3: Run with external ZooKeeper cluster
# docker run -d \
#   --name kafka-broker \
#   -p 9092:9092 \
#   -e KAFKA_BROKER_ID=1 \
#   -e KAFKA_ZOOKEEPER_CONNECT=zookeeper1:2181,zookeeper2:2181,zookeeper3:2181 \
#   my-kafka:3.6.1

# Example 4: Run with SSL encryption
# docker run -d \
#   --name kafka-ssl \
#   -p 9093:9093 \
#   -e KAFKA_SSL_ENABLED=true \
#   -v ./ssl:/etc/kafka/ssl \
#   my-kafka:3.6.1

# Example 5: Run with SASL authentication
# docker run -d \
#   --name kafka-sasl \
#   -p 9094:9094 \
#   -e KAFKA_SASL_ENABLED=true \
#   -e KAFKA_SASL_MECHANISM=PLAIN \
#   my-kafka:3.6.1

# Example 6: Run with Docker Compose
# docker-compose up -d

# Example 7: Run with resource limits and persistence
# docker run -d \
#   --name kafka-prod \
#   -p 9092:9092 \
#   --memory=2g \
#   --cpus=2 \
#   -v kafka-data:/var/lib/kafka \
#   -v kafka-config:/etc/kafka \
#   my-kafka:3.6.1

# Example 8: Run with JMX monitoring
# docker run -d \
#   --name kafka-monitored \
#   -p 9092:9092 \
#   -p 9999:9999 \
#   -e JMX_PORT=9999 \
#   -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false" \
#   my-kafka:3.6.1

# BEST PRACTICES
# ==============

# Security Best Practices:
# • Always use SSL/TLS encryption for production Kafka deployments
# • Implement SASL authentication for client connections
# • Use network policies to restrict access to Kafka brokers
# • Regularly rotate SSL certificates and authentication credentials
# • Monitor broker metrics and logs for security anomalies
# • Set appropriate retention policies for sensitive data
# • Enable topic compaction for critical topics
# • Use separate users for different Kafka operations

# Performance Optimization:
# • Adjust KAFKA_HEAP_OPTS based on available memory
# • Set appropriate partition counts for your workload
# • Configure replication factor for high availability
# • Tune batch sizes and linger.ms for producer performance
# • Monitor disk I/O and network throughput
# • Use compression for high-throughput topics
# • Implement proper monitoring and alerting

# Operations & Maintenance:
# • Use specific version tags for Kafka images (avoid 'latest')
# • Implement proper backup strategies for Kafka data
# • Monitor disk usage and set up automatic cleanup
# • Use health checks for container orchestration
# • Implement rolling updates for Kafka cluster maintenance
# • Set up centralized logging for all Kafka brokers
# • Regularly update Kafka and Java dependencies

# Kafka-Specific Considerations:
# • Configure appropriate number of partitions for your topics
# • Set proper replication factor for fault tolerance
# • Monitor consumer lag and rebalance events
# • Use Kafka Connect for data integration patterns
# • Implement Kafka Streams for stream processing
# • Set up proper monitoring with JMX or Prometheus
# • Use ACLs (Access Control Lists) for fine-grained permissions

# Cluster Deployment:
# • Use unique broker.id for each Kafka instance
# • Configure KAFKA_ADVERTISED_LISTENERS for external access
# • Use shared ZooKeeper ensemble for coordination
# • Implement rack awareness for data placement
# • Set up monitoring for cluster health and performance
# • Use configuration management for consistent deployment
# • Implement disaster recovery and failover strategies

# Development & Testing:
# • Use Docker Compose for local development environments
# • Implement integration tests with test containers
# • Use schema registry for Avro or Protobuf schemas
# • Set up development clusters with reduced resource requirements
# • Use tools like kcat for testing and debugging
# • Implement proper error handling and retry logic
# • Monitor development environments for performance issues
