# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for Grafana
# Website: https://grafana.com/
# Repository: https://github.com/grafana/grafana
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Grafana monitoring and visualization platform
# · DESIGN PHILOSOPHY: Production-ready monitoring with security hardening
# · COMBINATION: Use with Prometheus, Loki, and other data sources
# · SECURITY: Authentication, HTTPS, data source security
# · BEST PRACTICES: Dashboard management, alerting, data source configuration
# · OFFICIAL SOURCES: Grafana documentation and Docker best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GRAFANA MONITORING PLATFORM
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM grafana/grafana:11.0

# Build arguments for configuration
ARG GRAFANA_VERSION=11.0
# SECURITY: GF_SECURITY_ADMIN_PASSWORD must be set via environment variable or build argument
# Example: --build-arg GF_SECURITY_ADMIN_PASSWORD=your_secure_password_here
ARG GF_SECURITY_ADMIN_PASSWORD=
ARG GF_SECURITY_ADMIN_USER=admin
ARG GF_INSTALL_PLUGINS=
ARG GF_SERVER_HTTP_PORT=3000
ARG GF_SERVER_PROTOCOL=http
ARG GF_SERVER_DOMAIN=localhost
ARG GF_SERVER_ROOT_URL=%(protocol)s://%(domain)s:%(http_port)s/
ARG GF_DATABASE_TYPE=sqlite3
ARG GF_PATHS_DATA=/var/lib/grafana
ARG GF_PATHS_LOGS=/var/log/grafana
ARG GF_PATHS_PLUGINS=/var/lib/grafana/plugins
ARG GF_PATHS_PROVISIONING=/etc/grafana/provisioning
ARG GRAFANA_USER=grafana
ARG GRAFANA_GROUP=grafana
ARG GRAFANA_UID=1000
ARG GRAFANA_GID=1000

# Environment variables for Grafana configuration
ENV GRAFANA_VERSION=${GRAFANA_VERSION} \
    GF_SECURITY_ADMIN_PASSWORD=${GF_SECURITY_ADMIN_PASSWORD} \
    GF_SECURITY_ADMIN_USER=${GF_SECURITY_ADMIN_USER} \
    GF_INSTALL_PLUGINS=${GF_INSTALL_PLUGINS} \
    GF_SERVER_HTTP_PORT=${GF_SERVER_HTTP_PORT} \
    GF_SERVER_PROTOCOL=${GF_SERVER_PROTOCOL} \
    GF_SERVER_DOMAIN=${GF_SERVER_DOMAIN} \
    GF_SERVER_ROOT_URL=${GF_SERVER_ROOT_URL} \
    GF_DATABASE_TYPE=${GF_DATABASE_TYPE} \
    GF_PATHS_DATA=${GF_PATHS_DATA} \
    GF_PATHS_LOGS=${GF_PATHS_LOGS} \
    GF_PATHS_PLUGINS=${GF_PATHS_PLUGINS} \
    GF_PATHS_PROVISIONING=${GF_PATHS_PROVISIONING} \
    GRAFANA_USER=${GRAFANA_USER} \
    GRAFANA_GROUP=${GRAFANA_GROUP} \
    GRAFANA_UID=${GRAFANA_UID} \
    GRAFANA_GID=${GRAFANA_GID}

# Create custom user and group if they don't exist
RUN if ! getent group ${GRAFANA_GID} > /dev/null; then \
        groupadd -g ${GRAFANA_GID} ${GRAFANA_GROUP}; \
    fi && \
    if ! getent passwd ${GRAFANA_UID} > /dev/null; then \
        useradd -l -u ${GRAFANA_UID} -g ${GRAFANA_GID} ${GRAFANA_USER}; \
    fi

# Create directories with proper permissions
RUN mkdir -p ${GF_PATHS_DATA} && \
    mkdir -p ${GF_PATHS_LOGS} && \
    mkdir -p ${GF_PATHS_PLUGINS} && \
    mkdir -p ${GF_PATHS_PROVISIONING} && \
    chown -R ${GRAFANA_USER}:${GRAFANA_GROUP} ${GF_PATHS_DATA} && \
    chown -R ${GRAFANA_USER}:${GRAFANA_GROUP} ${GF_PATHS_LOGS} && \
    chown -R ${GRAFANA_USER}:${GRAFANA_GROUP} ${GF_PATHS_PLUGINS} && \
    chown -R ${GRAFANA_USER}:${GRAFANA_GROUP} ${GF_PATHS_PROVISIONING} && \
    chmod -R 750 ${GF_PATHS_DATA} && \
    chmod -R 750 ${GF_PATHS_LOGS} && \
    chmod -R 750 ${GF_PATHS_PLUGINS} && \
    chmod -R 750 ${GF_PATHS_PROVISIONING}

# Copy custom configuration
COPY <<'EOF' /etc/grafana/grafana.ini
# Grafana configuration
[server]
protocol = ${GF_SERVER_PROTOCOL}
http_port = ${GF_SERVER_HTTP_PORT}
domain = ${GF_SERVER_DOMAIN}
root_url = ${GF_SERVER_ROOT_URL}
router_logging = false
enable_gzip = true
static_root_path = public

[security]
admin_user = ${GF_SECURITY_ADMIN_USER}
admin_password = ${GF_SECURITY_ADMIN_PASSWORD}
secret_key =
disable_gravatar = true
data_source_proxy_whitelist =
cookie_secure = false
cookie_samesite = lax
allow_embedding = false
strict_transport_security = true
strict_transport_security_max_age_seconds = 31536000
strict_transport_security_preload = true
strict_transport_security_subdomains = true
x_content_type_options = true
x_xss_protection = true

[database]
type = ${GF_DATABASE_TYPE}
path = ${GF_PATHS_DATA}/grafana.db
max_idle_conn = 2
max_open_conn = 0
conn_max_lifetime = 14400
log_queries = false

[analytics]
reporting_enabled = false
check_for_updates = false

[paths]
data = ${GF_PATHS_DATA}
logs = ${GF_PATHS_LOGS}
plugins = ${GF_PATHS_PLUGINS}
provisioning = ${GF_PATHS_PROVISIONING}

[log]
mode = console file
level = info

[alerting]
enabled = true
execute_alerts = true
error_or_timeout = alerting
nodata_or_nullvalues = no_data
concurrent_render_limit = 5

[panels]
disable_sanitize_html = false

[plugins]
enable_alpha = false
app_tls_skip_verify_insecure = false

[rendering]
server_url =
callback_url =
concurrent_render_request_limit = 30

[feature_toggles]
enable =
EOF

# Install additional plugins if specified
RUN if [ -n "${GF_INSTALL_PLUGINS}" ]; then \
        grafana-cli plugins install ${GF_INSTALL_PLUGINS}; \
    fi

# Declare persistent data volume
VOLUME /var/lib/grafana

# Switch to non-root user
USER ${GRAFANA_USER}

# Expose Grafana port
EXPOSE ${GF_SERVER_HTTP_PORT}

# Health check for Grafana
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${GF_SERVER_HTTP_PORT}/api/health || exit 1

# Start Grafana (inherits default CMD from parent image)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Run basic Grafana container:
#    docker run -d \
#      --name grafana \
#      -p 3000:3000 \
#      -v grafana_data:/var/lib/grafana \
#      grafana/grafana:11.0
#
# 2. Run with custom admin password:
#    docker run -d \
#      --name grafana \
#      -p 3000:3000 \
#      -e GF_SECURITY_ADMIN_PASSWORD=secure_password \
#      -v grafana_data:/var/lib/grafana \
#      grafana/grafana:11.0
#
# 3. Run with additional plugins:
#    docker run -d \
#      --name grafana \
#      -p 3000:3000 \
#      -e GF_INSTALL_PLUGINS="grafana-piechart-panel,grafana-clock-panel" \
#      -v grafana_data:/var/lib/grafana \
#      grafana/grafana:11.0
#
# 4. Run with custom configuration:
#    docker run -d \
#      --name grafana \
#      -p 3000:3000 \
#      -v ./custom.ini:/etc/grafana/grafana.ini \
#      -v grafana_data:/var/lib/grafana \
#      grafana/grafana:11.0
#
# 5. Run with provisioning configuration:
#    docker run -d \
#      --name grafana \
#      -p 3000:3000 \
#      -v ./provisioning:/etc/grafana/provisioning \
#      -v grafana_data:/var/lib/grafana \
#      grafana/grafana:11.0
#
# 6. Run with PostgreSQL database:
#    docker run -d \
#      --name grafana \
#      -p 3000:3000 \
#      -e GF_DATABASE_TYPE=postgres \
#      -e GF_DATABASE_HOST=postgres:5432 \
#      -e GF_DATABASE_NAME=grafana \
#      -e GF_DATABASE_USER=grafana \
#      -e GF_DATABASE_PASSWORD=secure_password \
#      -v grafana_data:/var/lib/grafana \
#      grafana/grafana:11.0
#
# 7. Run with SSL/TLS enabled:
#    docker run -d \
#      --name grafana \
#      -p 3000:3000 \
#      -e GF_SERVER_PROTOCOL=https \
#      -e GF_SERVER_CERT_FILE=/etc/ssl/grafana.crt \
#      -e GF_SERVER_CERT_KEY=/etc/ssl/grafana.key \
#      -v ./ssl:/etc/ssl \
#      -v grafana_data:/var/lib/grafana \
#      grafana/grafana:11.0
#
# 8. Build custom Grafana image:
#    docker build -t my-grafana:prod .

# BEST PRACTICES
# ==============
# • PASSWORD SECURITY: Always use strong, unique passwords for admin accounts
# • DATA PERSISTENCE: Use Docker volumes for persistent data storage
# • DATABASE CONFIGURATION: Use external database (PostgreSQL) for production
# • SSL/TLS ENCRYPTION: Enable HTTPS for secure communication in production
# • ACCESS CONTROL: Implement proper authentication and authorization
# • DASHBOARD MANAGEMENT: Use provisioning for automated dashboard deployment
# • ALERTING CONFIGURATION: Set up meaningful alerts for monitoring systems
# • PERFORMANCE MONITORING: Monitor Grafana performance and resource usage

# GRAFANA-SPECIFIC CONSIDERATIONS
# • DATA SOURCE MANAGEMENT: Securely configure data source credentials
# • DASHBOARD VERSIONING: Use version control for dashboard JSON definitions
# • PLUGIN MANAGEMENT: Only install trusted plugins from official sources
# • THEME CUSTOMIZATION: Customize appearance for organizational branding
# • USER MANAGEMENT: Implement LDAP/SSO for enterprise user management
# • BACKUP STRATEGY: Regular backups of dashboards and configuration

# SECURITY CONSIDERATIONS
# • ADMIN CREDENTIALS: Change default admin password immediately
# • NETWORK SECURITY: Restrict access to Grafana interface
# • DATA SOURCE SECURITY: Use read-only credentials for data sources
# • PLUGIN SECURITY: Audit third-party plugins for security vulnerabilities
# • AUDIT LOGGING: Enable audit logging for compliance requirements
# • RATE LIMITING: Implement rate limiting to prevent abuse

# PERFORMANCE OPTIMIZATION
# • DATABASE OPTIMIZATION: Use appropriate database for scale requirements
# • CACHE CONFIGURATION: Optimize caching for dashboard rendering
# • RESOURCE MANAGEMENT: Set appropriate memory and CPU limits
# • CONNECTION POOLING: Configure database connection pooling
# • QUERY OPTIMIZATION: Optimize data source queries for performance

# COMBINATION PATTERNS
# • Combine with tools/prometheus.Dockerfile for metrics visualization
# • Combine with tools/loki.Dockerfile for log aggregation and visualization
# • Combine with tools/tempo.Dockerfile for distributed tracing visualization
# • Combine with patterns/monitoring.Dockerfile for comprehensive monitoring
# • Combine with patterns/docker-compose.Dockerfile for monitoring stack deployment
