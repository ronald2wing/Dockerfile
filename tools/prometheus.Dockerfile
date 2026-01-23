# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for Prometheus
# Website: https://prometheus.io/
# Repository: https://github.com/prometheus/prometheus
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Prometheus monitoring system and time series database
# · DESIGN PHILOSOPHY: Production-ready monitoring with security hardening
# · COMBINATION: Use with Grafana for visualization, exporters for metrics
# · SECURITY: Authentication, HTTPS, scrape target security
# · BEST PRACTICES: Retention policies, alerting rules, scrape configurations
# · OFFICIAL SOURCES: Prometheus documentation and Docker best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PROMETHEUS MONITORING SYSTEM
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM prom/prometheus:v2.51

# Build arguments for configuration
ARG PROMETHEUS_VERSION=v2.51
ARG PROMETHEUS_WEB_LISTEN_ADDRESS=:9090
ARG PROMETHEUS_WEB_EXTERNAL_URL=http://localhost:9090
ARG PROMETHEUS_STORAGE_TSDB_RETENTION_TIME=15d
ARG PROMETHEUS_STORAGE_TSDB_RETENTION_SIZE=0
ARG PROMETHEUS_STORAGE_TSDB_PATH=/prometheus
ARG PROMETHEUS_CONFIG_FILE=/etc/prometheus/prometheus.yml
ARG PROMETHEUS_RULE_FILES=/etc/prometheus/rules/*.yml
ARG PROMETHEUS_SCRAPE_INTERVAL=15s
ARG PROMETHEUS_EVALUATION_INTERVAL=15s
ARG PROMETHEUS_USER=prometheus
ARG PROMETHEUS_GROUP=prometheus
ARG PROMETHEUS_UID=1001
ARG PROMETHEUS_GID=1001

# Environment variables for Prometheus configuration
ENV PROMETHEUS_VERSION=${PROMETHEUS_VERSION} \
    PROMETHEUS_WEB_LISTEN_ADDRESS=${PROMETHEUS_WEB_LISTEN_ADDRESS} \
    PROMETHEUS_WEB_EXTERNAL_URL=${PROMETHEUS_WEB_EXTERNAL_URL} \
    PROMETHEUS_STORAGE_TSDB_RETENTION_TIME=${PROMETHEUS_STORAGE_TSDB_RETENTION_TIME} \
    PROMETHEUS_STORAGE_TSDB_RETENTION_SIZE=${PROMETHEUS_STORAGE_TSDB_RETENTION_SIZE} \
    PROMETHEUS_STORAGE_TSDB_PATH=${PROMETHEUS_STORAGE_TSDB_PATH} \
    PROMETHEUS_CONFIG_FILE=${PROMETHEUS_CONFIG_FILE} \
    PROMETHEUS_RULE_FILES=${PROMETHEUS_RULE_FILES} \
    PROMETHEUS_SCRAPE_INTERVAL=${PROMETHEUS_SCRAPE_INTERVAL} \
    PROMETHEUS_EVALUATION_INTERVAL=${PROMETHEUS_EVALUATION_INTERVAL} \
    PROMETHEUS_USER=${PROMETHEUS_USER} \
    PROMETHEUS_GROUP=${PROMETHEUS_GROUP} \
    PROMETHEUS_UID=${PROMETHEUS_UID} \
    PROMETHEUS_GID=${PROMETHEUS_GID}

# Create custom user and group if they don't exist
RUN if ! getent group ${PROMETHEUS_GID} > /dev/null; then \
        groupadd -g ${PROMETHEUS_GID} ${PROMETHEUS_GROUP}; \
    fi && \
    if ! getent passwd ${PROMETHEUS_UID} > /dev/null; then \
        useradd -u ${PROMETHEUS_UID} -g ${PROMETHEUS_GID} ${PROMETHEUS_USER}; \
    fi

# Create directories with proper permissions
RUN mkdir -p ${PROMETHEUS_STORAGE_TSDB_PATH} && \
    mkdir -p /etc/prometheus/rules && \
    mkdir -p /etc/prometheus/file_sd && \
    chown -R ${PROMETHEUS_USER}:${PROMETHEUS_GROUP} ${PROMETHEUS_STORAGE_TSDB_PATH} && \
    chown -R ${PROMETHEUS_USER}:${PROMETHEUS_GROUP} /etc/prometheus && \
    chmod -R 750 ${PROMETHEUS_STORAGE_TSDB_PATH} && \
    chmod -R 750 /etc/prometheus

# Copy custom configuration
COPY <<'EOF' ${PROMETHEUS_CONFIG_FILE}
# Prometheus configuration
global:
  scrape_interval: ${PROMETHEUS_SCRAPE_INTERVAL}
  evaluation_interval: ${PROMETHEUS_EVALUATION_INTERVAL}
  external_labels:
    monitor: 'prometheus-monitor'

# Rule files specifies a list of files from which rules are read
rule_files:
  - ${PROMETHEUS_RULE_FILES}

# Scrape configuration
scrape_configs:
  # Scrape Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
    scrape_interval: 5s

  # Example: Node exporter
  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']
    scrape_interval: 10s

  # Example: Docker daemon
  - job_name: 'docker'
    static_configs:
      - targets: ['docker-exporter:9323']
    scrape_interval: 15s

  # Example: Application metrics
  - job_name: 'application'
    static_configs:
      - targets: ['application:8080']
    scrape_interval: 15s
    metrics_path: '/metrics'

  # File-based service discovery example
  - job_name: 'file-sd'
    file_sd_configs:
      - files:
        - /etc/prometheus/file_sd/*.json
        refresh_interval: 5m

# Alerting configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

# Storage configuration
storage:
  tsdb:
    path: ${PROMETHEUS_STORAGE_TSDB_PATH}
    retention:
      time: ${PROMETHEUS_STORAGE_TSDB_RETENTION_TIME}
      size: ${PROMETHEUS_STORAGE_TSDB_RETENTION_SIZE}

# Web configuration
web:
  listen_address: ${PROMETHEUS_WEB_LISTEN_ADDRESS}
  external_url: ${PROMETHEUS_WEB_EXTERNAL_URL}
  page_title: "Prometheus Monitoring"
  max_connections: 512
  read_timeout: 5m
  enable_lifecycle: true
  enable_admin_api: true
EOF

# Copy example alert rules
COPY <<'EOF' /etc/prometheus/rules/alert_rules.yml
groups:
  - name: example
    rules:
      # Alert for any instance that is unreachable for > 1 minute
      - alert: InstanceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Instance {{ $labels.instance }} down"
          description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minute."

      # Alert for high memory usage
      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 90
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "{{ $labels.instance }} memory usage is {{ $value }}%"

      # Alert for high CPU usage
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "{{ $labels.instance }} CPU usage is {{ $value }}%"

      # Alert for disk space running low
      - alert: LowDiskSpace
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"} * 100) < 10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Low disk space on {{ $labels.instance }}"
          description: "{{ $labels.instance }} disk space is {{ $value }}% free"
EOF

# Declare persistent data volume
VOLUME /prometheus

# Switch to non-root user
USER ${PROMETHEUS_USER}

# Expose Prometheus port
EXPOSE 9090

# Health check for Prometheus
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:9090/-/healthy || exit 1

# Start Prometheus
CMD ["prometheus", \
    "--config.file=/etc/prometheus/prometheus.yml", \
    "--storage.tsdb.path=/prometheus", \
    "--web.console.libraries=/etc/prometheus/console_libraries", \
    "--web.console.templates=/etc/prometheus/consoles", \
    "--web.listen-address=:9090"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Basic Prometheus deployment:
#    docker build -t prometheus-server -f prometheus.Dockerfile .
#    docker run -p 9090:9090 -v prometheus-data:/prometheus --name prometheus prometheus-server
#
# 2. Production deployment with custom configuration:
#    docker build --build-arg PROMETHEUS_STORAGE_TSDB_RETENTION_TIME=30d -t prometheus-prod .
#    docker run -d -p 9090:9090 -v prometheus-data:/prometheus \
#      --restart unless-stopped --memory 2g --cpus 2 --name prometheus-prod prometheus-prod
#
# 3. Development with mounted configuration:
#    docker run -it --rm -p 9090:9090 -v $(pwd)/config:/etc/prometheus \
#      -v prometheus-dev-data:/prometheus --name prometheus-dev prometheus-server
#
# 4. High-availability deployment:
#    # Instance 1
#    docker run -d -p 9090:9090 -v prometheus-data-1:/prometheus --name prometheus-1 prometheus-server
#    # Instance 2
#    docker run -d -p 9091:9090 -v prometheus-data-2:/prometheus --name prometheus-2 prometheus-server
#
# 5. TLS-enabled deployment:
#    docker run -d -p 9090:9090 -v prometheus-data:/prometheus \
#      -v /path/to/certs:/etc/prometheus/certs --name prometheus-tls prometheus-server
#
# 6. Monitoring stack with Grafana:
#    cat tools/prometheus.Dockerfile tools/grafana.Dockerfile > Dockerfile
#    docker build -t monitoring-stack .
#
# 7. Custom scrape configuration:
#    docker run -d -p 9090:9090 -v prometheus-data:/prometheus \
#      -v $(pwd)/scrape_configs:/etc/prometheus/file_sd --name prometheus-custom prometheus-server
#
# 8. Alerting with Alertmanager:
#    cat tools/prometheus.Dockerfile tools/alertmanager.Dockerfile > Dockerfile
#    docker build -t alerting-stack .

# BEST PRACTICES
# ==============
# • Security & Compliance:
#   - Run Prometheus as non-root user to minimize security risks
#   - Enable authentication and authorization for production deployments
#   - Use TLS encryption for network communication
#   - Regularly update Prometheus versions for security patches
#
# • Performance & Optimization:
#   - Configure appropriate retention policies based on storage capacity
#   - Optimize scrape intervals based on metric frequency and importance
#   - Implement efficient alerting rules to reduce false positives
#   - Monitor Prometheus's own resource usage (CPU, memory, disk)
#
# • Development & Operations:
#   - Use named volumes for persistent time-series data storage
#   - Implement proper health checks for container orchestration
#   - Configure resource limits (CPU, memory) based on workload
#   - Set up monitoring and alerting for Prometheus performance
#
# • Prometheus-Specific Considerations:
#   - Understand Prometheus's pull-based monitoring model
#   - Design efficient metric naming conventions and labels
#   - Implement proper service discovery for dynamic environments
#   - Consider using Prometheus federation for multi-cluster monitoring
#
# • Combination Patterns:
#   - Combine with tools/grafana.Dockerfile for visualization and dashboards
#   - Use with tools/alertmanager.Dockerfile for alerting and notification
#   - Integrate with patterns/monitoring.Dockerfile for comprehensive monitoring
#   - Combine with patterns/security-hardened.Dockerfile for enhanced security
#   - Use with patterns/docker-compose.Dockerfile for multi-service deployments
