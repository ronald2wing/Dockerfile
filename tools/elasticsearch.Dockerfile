# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for Elasticsearch
# Website: https://www.elastic.co/elasticsearch/
# Repository: https://github.com/elastic/elasticsearch
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Production-ready Elasticsearch deployment with security hardening
# · DESIGN PHILOSOPHY: Self-contained with security configurations
# · COMBINATION: Use standalone for Elasticsearch deployments
# · SECURITY: Non-root user, memory limits, secure defaults
# · BEST PRACTICES: Resource limits, persistent storage, monitoring
# · OFFICIAL SOURCES: Elasticsearch documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Choose appropriate Elasticsearch version based on your needs:

FROM elasticsearch:8.12

# Alternative: Specific version with SHA
# FROM elasticsearch:8.12@sha256:abc123...

# Alternative: Elasticsearch with OpenSearch compatibility
# FROM elasticsearch:7.17

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG ELASTICSEARCH_VERSION=8.12
ARG CLUSTER_NAME=elasticsearch
ARG NODE_NAME=elasticsearch-node
ARG DISCOVERY_TYPE=single-node

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV ELASTICSEARCH_VERSION=${ELASTICSEARCH_VERSION} \
  CLUSTER_NAME=${CLUSTER_NAME} \
  NODE_NAME=${NODE_NAME} \
  DISCOVERY_TYPE=${DISCOVERY_TYPE} \
  ES_JAVA_OPTS="-Xms512m -Xmx512m" \
  xpack.security.enabled=true \
  xpack.security.http.ssl.enabled=false \
  xpack.security.transport.ssl.enabled=false \
  bootstrap.memory_lock=true \
  discovery.type=${DISCOVERY_TYPE} \
  network.host=0.0.0.0 \
  UMASK=0027

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CRITICAL: Security-hardened configuration for production

# Create custom elasticsearch user with specific UID/GID
RUN groupadd -g 1000 elasticsearch && \
    useradd -u 1000 -g 1000 -d /usr/share/elasticsearch elasticsearch

# Set proper permissions
RUN chown -R elasticsearch:elasticsearch /usr/share/elasticsearch && \
    chmod -R 750 /usr/share/elasticsearch

# Switch to elasticsearch user
USER elasticsearch

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURATION FILES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Copy custom configuration files
COPY --chown=elasticsearch:elasticsearch elasticsearch.yml /usr/share/elasticsearch/config/
COPY --chown=elasticsearch:elasticsearch jvm.options /usr/share/elasticsearch/config/
COPY --chown=elasticsearch:elasticsearch log4j2.properties /usr/share/elasticsearch/config/

# Create data and logs directories with secure permissions
RUN mkdir -p /usr/share/elasticsearch/data /usr/share/elasticsearch/logs && \
    chmod 750 /usr/share/elasticsearch/data /usr/share/elasticsearch/logs

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PLUGINS INSTALLATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Install essential plugins (uncomment as needed)

# Analysis plugins
# RUN elasticsearch-plugin install analysis-icu
# RUN elasticsearch-plugin install analysis-smartcn
# RUN elasticsearch-plugin install analysis-kuromoji

# Monitoring and management plugins
# RUN elasticsearch-plugin install repository-s3
# RUN elasticsearch-plugin install discovery-ec2

# Security plugins (for older versions)
# RUN elasticsearch-plugin install x-pack

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Declare persistent data volume
VOLUME /usr/share/elasticsearch/data

# Expose Elasticsearch ports
EXPOSE 9200  # HTTP REST API
EXPOSE 9300  # Transport protocol

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:9200/_cluster/health || exit 1

# Default command
CMD ["elasticsearch"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Run single node Elasticsearch
# docker run -d \
#   --name elasticsearch \
#   -p 9200:9200 -p 9300:9300 \
#   -e "discovery.type=single-node" \
#   -e "ES_JAVA_OPTS=-Xms1g -Xmx1g" \
#   -v es-data:/usr/share/elasticsearch/data \
#   my-elasticsearch:prod

# Example 2: Run with custom configuration
# docker run -d \
#   --name elasticsearch \
#   -p 9200:9200 -p 9300:9300 \
#   -e "CLUSTER_NAME=my-cluster" \
#   -e "NODE_NAME=node-1" \
#   -e "ES_JAVA_OPTS=-Xms2g -Xmx2g" \
#   -v es-data:/usr/share/elasticsearch/data \
#   -v ./elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
#   my-elasticsearch:prod

# Example 3: Run in Docker Compose with Kibana
# version: '3.8'
# services:
#   elasticsearch:
#     build: .
#     environment:
#       - discovery.type=single-node
#       - ES_JAVA_OPTS=-Xms1g -Xmx1g
#     ports:
#       - "9200:9200"
#     volumes:
#       - es-data:/usr/share/elasticsearch/data
#   kibana:
#     image: kibana:8.12
#     ports:
#       - "5601:5601"
#     environment:
#       - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
# volumes:
#   es-data:

# Example 4: Multi-node cluster setup
# docker run -d \
#   --name es-node-1 \
#   -p 9200:9200 -p 9300:9300 \
#   -e "CLUSTER_NAME=es-cluster" \
#   -e "NODE_NAME=node-1" \
#   -e "discovery.seed_hosts=es-node-2,es-node-3" \
#   -e "cluster.initial_master_nodes=node-1,node-2,node-3" \
#   -e "ES_JAVA_OPTS=-Xms2g -Xmx2g" \
#   -v es-data-1:/usr/share/elasticsearch/data \
#   my-elasticsearch:prod

# Example 5: CI/CD test with security enabled
# docker build --no-cache -t elasticsearch:test .
# docker run --rm \
#   -e "discovery.type=single-node" \
#   -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
#   elasticsearch:test

# Best Practices:
# 1. Always set memory limits (ES_JAVA_OPTS) based on available system memory
# 2. Use persistent volumes for data directory
# 3. Enable security features in production
# 4. Monitor cluster health and performance
# 5. Set resource limits in docker-compose or Kubernetes

# Security Recommendations:
# 1. Enable TLS/SSL for transport and HTTP layers
# 2. Set strong passwords for built-in users
# 3. Use role-based access control (RBAC)
# 4. Regularly update Elasticsearch versions
# 5. Monitor for security vulnerabilities

# Performance Tuning:
# 1. Adjust heap size based on available memory (recommended: 50% of available RAM)
# 2. Set appropriate thread pool sizes
# 3. Configure indices and shards appropriately
# 4. Use SSD storage for better I/O performance
# 5. Monitor and adjust JVM garbage collection settings
