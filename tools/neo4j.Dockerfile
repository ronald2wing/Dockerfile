# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for Neo4j
# Website: https://neo4j.com/
# Repository: https://github.com/neo4j/neo4j
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Production-ready Neo4j graph database
# · DESIGN PHILOSOPHY: Graph database with security hardening and performance tuning
# · COMBINATION: Use standalone for Neo4j database containers
# · SECURITY: Non-root user, secure defaults, authentication
# · BEST PRACTICES: Volume persistence, query optimization, resource limits
# · OFFICIAL SOURCES: Neo4j documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BASE IMAGE SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM neo4j:5.15-community

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ARG NEO4J_VERSION=5.15
ARG BUILD_ID=unknown

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENV NEO4J_VERSION=${NEO4J_VERSION} \
  BUILD_ID=${BUILD_ID} \
  # NEO4J_AUTH must be set via environment variable for security
  # Example: -e NEO4J_AUTH=neo4j/your_secure_password_here
  NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
  NEO4J_PLUGINS='["apoc", "graph-data-science"]' \
  NEO4J_dbms_memory_pagecache_size=1G \
  NEO4J_dbms_memory_heap_initial__size=2G \
  NEO4J_dbms_memory_heap_max__size=4G \
  NEO4J_dbms_security_procedures_unrestricted=apoc.*,gds.* \
  NEO4J_dbms_connector_bolt_listen__address=:7687 \
  NEO4J_dbms_connector_http_listen__address=:7474 \
  NEO4J_dbms_connector_https_listen__address=:7473 \
  NEO4J_dbms_default__listen__address=0.0.0.0 \
  NEO4J_dbms_security_auth__minimum__password__length=8 \
  NEO4J_dbms_security_auth__cache__ttl=10m \
  NEO4J_dbms_logs_debug_level=INFO \
  NEO4J_dbms_transaction_timeout=5m \
  TZ=UTC

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Neo4j already runs as non-root user 'neo4j' in official image

# Additional security hardening
RUN chmod 750 /var/lib/neo4j && \
  chmod 750 /var/log/neo4j && \
  chmod 750 /etc/neo4j

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PLUGIN INSTALLATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APOC and Graph Data Science plugins are installed via NEO4J_PLUGINS env var
# Additional plugins can be downloaded and installed here if needed

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURATION FILES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Copy custom configuration files (if needed)
# COPY neo4j.conf /etc/neo4j/neo4j.conf.d/
# COPY apoc.conf /etc/neo4j/apoc.conf.d/

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VOLUME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Persistent data volume
VOLUME ["/data"]

# Log volume
VOLUME ["/logs"]

# Configuration volume
VOLUME ["/conf"]

# Import volume
VOLUME ["/import"]

# Plugins volume
VOLUME ["/plugins"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CHECK
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:7474 || exit 1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PORTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Bolt protocol (default: 7687)
EXPOSE 7687

# HTTP interface (default: 7474)
EXPOSE 7474

# HTTPS interface (default: 7473)
EXPOSE 7473

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTRYPOINT AND COMMAND
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ENTRYPOINT ["tini", "-g", "--"]
USER neo4j
CMD ["/startup/docker-entrypoint.sh", "neo4j"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES
# ==============
# 1. Basic Neo4j container:
#    docker run -d --name neo4j \
#      -p 7474:7474 -p 7687:7687 \
#      -e NEO4J_AUTH=neo4j/securepassword \
#      neo4j:5.15-community
#
# 2. With persistent volumes:
#    docker run -d --name neo4j \
#      -p 7474:7474 -p 7687:7687 \
#      -v neo4j_data:/data \
#      -v neo4j_logs:/logs \
#      -v neo4j_conf:/conf \
#      -v neo4j_import:/import \
#      -e NEO4J_AUTH=neo4j/securepassword \
#      neo4j:5.15-community
#
# 3. With APOC and Graph Data Science plugins:
#    docker run -d --name neo4j \
#      -p 7474:7474 -p 7687:7687 \
#      -e NEO4J_AUTH=neo4j/securepassword \
#      -e NEO4J_PLUGINS='["apoc", "graph-data-science"]' \
#      neo4j:5.15-community
#
# 4. With resource limits:
#    docker run -d --name neo4j \
#      -p 7474:7474 -p 7687:7687 \
#      --memory=8g --cpus=2 \
#      -e NEO4J_dbms_memory_heap_max__size=6G \
#      -e NEO4J_dbms_memory_pagecache_size=2G \
#      -e NEO4J_AUTH=neo4j/securepassword \
#      neo4j:5.15-community
#
# 5. Health check verification:
#    docker run -d --name neo4j-test \
#      -p 7474:7474 \
#      -e NEO4J_AUTH=neo4j/testpass \
#      neo4j:5.15-community
#    docker inspect --format='{{.State.Health.Status}}' neo4j-test
#
# 6. Connect via cypher-shell:
#    docker exec -it neo4j cypher-shell -u neo4j -p securepassword
#
# 7. Load sample data:
#    echo "CREATE (n:Person {name: 'Alice', age: 30});" | \
#    docker exec -i neo4j cypher-shell -u neo4j -p securepassword
#
# 8. Backup and restore:
#    # Backup
#    docker exec neo4j neo4j-admin database backup --to-path=/backups neo4j
#
#    # Restore
#    docker exec neo4j neo4j-admin database restore --from-path=/backups neo4j

# BEST PRACTICES
# ==============
# Security:
# • Always use strong passwords for Neo4j authentication
# • Enable TLS for Bolt and HTTP connections in production
# • Use network policies to restrict database access
# • Regularly update Neo4j versions for security patches

# Performance:
# • Configure appropriate heap and page cache sizes
# • Use SSD storage for better I/O performance
# • Monitor query performance and create indexes
# • Consider using Neo4j Enterprise for clustering

# Data Management:
# • Create appropriate indexes for frequently queried properties
# • Use constraints for data integrity
# • Implement data retention policies for graph data
# • Regular backups of graph databases

# Operations:
# • Health checks ensure database availability
# • Resource limits prevent memory exhaustion
# • Logging configured for query analysis
# • Monitoring for graph algorithm performance

# Maintenance:
# • Regular vacuuming of graph storage
# • Update statistics for query optimization
# • Monitor system metrics for performance insights
# • Regular testing of backup and restore procedures

# Combination Patterns:
# • Combine with frameworks/*.Dockerfile for application integration
# • Combine with patterns/monitoring.Dockerfile for observability
# • Combine with tools/grafana.Dockerfile for visualization
# • Combine with languages/python.Dockerfile for data science workflows

# Neo4j-Specific Considerations:
# • Graph database optimized for relationship queries
# • Cypher query language for graph patterns
# • APOC library for extended procedures and functions
# • Graph Data Science library for algorithms and ML
# • Consider clustering for high availability and scalability
# • Bloom for graph visualization and exploration
