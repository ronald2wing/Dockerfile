# ==============================================================================
# Created by https://Dockerfile.io/
# Tool TEMPLATE for Apache Cassandra
# Website: https://cassandra.apache.org/
# Repository: https://github.com/apache/cassandra
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Tool
# · PURPOSE: Apache Cassandra NoSQL database with production configuration
# · DESIGN PHILOSOPHY: Distributed database optimized for scalability and availability
# · COMBINATION: Use for Cassandra database deployments
# · SECURITY: Authentication, encryption, network security
# · BEST PRACTICES: Cluster configuration, data replication, backup strategies
# · OFFICIAL SOURCES: Apache Cassandra documentation and Docker best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CASSANDRA DATABASE CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM cassandra:4.1

# Build arguments for configuration
ARG CASSANDRA_VERSION=4.1
ARG CASSANDRA_CLUSTER_NAME=Test Cluster
ARG CASSANDRA_DC=datacenter1
ARG CASSANDRA_RACK=rack1
ARG CASSANDRA_ENDPOINT_SNITCH=SimpleSnitch
ARG CASSANDRA_NUM_TOKENS=256
ARG CASSANDRA_SEEDS=cassandra
ARG CASSANDRA_LISTEN_ADDRESS=0.0.0.0
ARG CASSANDRA_BROADCAST_ADDRESS=
ARG CASSANDRA_RPC_ADDRESS=0.0.0.0
ARG CASSANDRA_BROADCAST_RPC_ADDRESS=
ARG CASSANDRA_USER=cassandra
ARG CASSANDRA_GROUP=cassandra
ARG CASSANDRA_UID=1001
ARG CASSANDRA_GID=1001

# Environment variables for Cassandra configuration
ENV CASSANDRA_VERSION=${CASSANDRA_VERSION} \
    CASSANDRA_CLUSTER_NAME=${CASSANDRA_CLUSTER_NAME} \
    CASSANDRA_DC=${CASSANDRA_DC} \
    CASSANDRA_RACK=${CASSANDRA_RACK} \
    CASSANDRA_ENDPOINT_SNITCH=${CASSANDRA_ENDPOINT_SNITCH} \
    CASSANDRA_NUM_TOKENS=${CASSANDRA_NUM_TOKENS} \
    CASSANDRA_SEEDS=${CASSANDRA_SEEDS} \
    CASSANDRA_LISTEN_ADDRESS=${CASSANDRA_LISTEN_ADDRESS} \
    CASSANDRA_BROADCAST_ADDRESS=${CASSANDRA_BROADCAST_ADDRESS} \
    CASSANDRA_RPC_ADDRESS=${CASSANDRA_RPC_ADDRESS} \
    CASSANDRA_BROADCAST_RPC_ADDRESS=${CASSANDRA_BROADCAST_RPC_ADDRESS} \
    MAX_HEAP_SIZE=1G \
    HEAP_NEWSIZE=200M \
    CASSANDRA_USER=${CASSANDRA_USER} \
    CASSANDRA_GROUP=${CASSANDRA_GROUP} \
    CASSANDRA_UID=${CASSANDRA_UID} \
    CASSANDRA_GID=${CASSANDRA_GID}

# Create custom user and group if they don't exist
RUN if ! getent group ${CASSANDRA_GID} > /dev/null; then \
        groupadd -g ${CASSANDRA_GID} ${CASSANDRA_GROUP}; \
    fi && \
    if ! getent passwd ${CASSANDRA_UID} > /dev/null; then \
        useradd -u ${CASSANDRA_UID} -g ${CASSANDRA_GID} ${CASSANDRA_USER}; \
    fi

# Create data directories with proper permissions
RUN mkdir -p /var/lib/cassandra/data && \
    mkdir -p /var/lib/cassandra/commitlog && \
    mkdir -p /var/lib/cassandra/saved_caches && \
    chown -R ${CASSANDRA_USER}:${CASSANDRA_GROUP} /var/lib/cassandra && \
    chmod -R 750 /var/lib/cassandra

# Copy custom configuration
COPY <<'EOF' /etc/cassandra/cassandra.yaml
# Cassandra configuration
cluster_name: '${CASSANDRA_CLUSTER_NAME}'
num_tokens: ${CASSANDRA_NUM_TOKENS}
hinted_handoff_enabled: true
max_hint_window_in_ms: 10800000
hinted_handoff_throttle_in_kb: 1024
max_hints_delivery_threads: 2
authenticator: PasswordAuthenticator
authorizer: CassandraAuthorizer
role_manager: CassandraRoleManager
roles_validity_in_ms: 2000
permissions_validity_in_ms: 2000
partitioner: org.apache.cassandra.dht.Murmur3Partitioner
data_file_directories:
    - /var/lib/cassandra/data
commitlog_directory: /var/lib/cassandra/commitlog
cdc_raw_directory: /var/lib/cassandra/cdc_raw
saved_caches_directory: /var/lib/cassandra/saved_caches
commitlog_sync: periodic
commitlog_sync_period_in_ms: 10000
commitlog_segment_size_in_mb: 32
seed_provider:
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          - seeds: "${CASSANDRA_SEEDS}"
concurrent_reads: 32
concurrent_writes: 32
concurrent_counter_writes: 32
concurrent_materialized_view_writes: 32
memtable_allocation_type: heap_buffers
index_summary_capacity_in_mb: 250
trickle_fsync: false
trickle_fsync_interval_in_kb: 10240
storage_port: 7000
ssl_storage_port: 7001
listen_address: ${CASSANDRA_LISTEN_ADDRESS}
broadcast_address: ${CASSANDRA_BROADCAST_ADDRESS}
start_native_transport: true
native_transport_port: 9042
start_rpc: true
rpc_address: ${CASSANDRA_RPC_ADDRESS}
broadcast_rpc_address: ${CASSANDRA_BROADCAST_RPC_ADDRESS}
rpc_port: 9160
rpc_keepalive: true
rpc_server_type: sync
thrift_framed_transport_size_in_mb: 15
incremental_backups: false
snapshot_before_compaction: false
auto_snapshot: true
tombstone_warn_threshold: 1000
tombstone_failure_threshold: 100000
column_index_size_in_kb: 64
batch_size_warn_threshold_in_kb: 5
batch_size_fail_threshold_in_kb: 50
unlogged_batch_across_partitions_warn_threshold: 10
compaction_throughput_mb_per_sec: 16
compaction_large_partition_warning_threshold_mb: 100
sstable_preemptive_open_interval_in_mb: 50
read_request_timeout_in_ms: 5000
range_request_timeout_in_ms: 10000
write_request_timeout_in_ms: 2000
counter_write_request_timeout_in_ms: 5000
cas_contention_timeout_in_ms: 1000
truncate_request_timeout_in_ms: 60000
request_timeout_in_ms: 10000
cross_node_timeout: false
endpoint_snitch: ${CASSANDRA_ENDPOINT_SNITCH}
dynamic_snitch_update_interval_in_ms: 100
dynamic_snitch_reset_interval_in_ms: 600000
dynamic_snitch_badness_threshold: 0.1
request_scheduler: org.apache.cassandra.scheduler.RoundRobinScheduler
server_encryption_options:
    internode_encryption: none
    keystore: conf/.keystore
    keystore_password: cassandra
    truststore: conf/.truststore
    truststore_password: cassandra
client_encryption_options:
    enabled: false
    optional: false
    keystore: conf/.keystore
    keystore_password: cassandra
internode_compression: all
inter_dc_tcp_nodelay: false
tracetype_query_ttl: 86400
tracetype_repair_ttl: 604800
gc_warn_threshold_in_ms: 1000
enable_user_defined_functions: false
enable_scripted_user_defined_functions: false
windows_timer_interval: 1
transparent_data_encryption_options:
    enabled: false
    chunk_length_kb: 64
    cipher: AES/CBC/PKCS5Padding
    key_alias: testing:1
    key_provider:
      - class_name: org.apache.cassandra.security.JKSKeyProvider
        parameters:
          - keystore: conf/.keystore
            keystore_password: cassandra
            store_type: JCEKS
            key_password: cassandra
tombstone_gc:
    - mode: timeout
      propagation_delay: 3600
EOF

# Declare persistent data volume
VOLUME /var/lib/cassandra

# Switch to non-root user
USER ${CASSANDRA_USER}

# Expose Cassandra ports
EXPOSE 7000 7001 7199 9042 9160

# Health check for Cassandra
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD nodetool status || exit 1

# Start Cassandra
CMD ["cassandra", "-f"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Build basic Cassandra image
# docker build -t my-cassandra:prod .

# Example 2: Build with custom configuration
# docker build \
#   --build-arg CASSANDRA_VERSION=4.1 \
#   --build-arg HEAP_NEWSIZE=512M \
#   --build-arg MAX_HEAP_SIZE=2G \
#   -t my-cassandra:4.1 .

# Example 3: Run Cassandra with persistent storage
# docker run -d \
#   -p 9042:9042 \
#   -p 7000:7000 \
#   -p 7001:7001 \
#   -p 7199:7199 \
#   -p 9160:9160 \
#   -v cassandra-data:/var/lib/cassandra \
#   --name cassandra-node \
#   --memory=4g \
#   --cpus=2.0 \
#   my-cassandra:prod

# Example 4: Run Cassandra cluster with 3 nodes
# docker run -d --name cassandra-node1 \
#   -e CASSANDRA_SEEDS=cassandra-node1,cassandra-node2,cassandra-node3 \
#   -e CASSANDRA_CLUSTER_NAME=MyCluster \
#   -p 9042:9042 \
#   my-cassandra:prod
#
# docker run -d --name cassandra-node2 \
#   -e CASSANDRA_SEEDS=cassandra-node1,cassandra-node2,cassandra-node3 \
#   my-cassandra:prod
#
# docker run -d --name cassandra-node3 \
#   -e CASSANDRA_SEEDS=cassandra-node1,cassandra-node2,cassandra-node3 \
#   my-cassandra:prod

# Example 5: Connect to Cassandra using cqlsh
# docker run -it --rm \
#   --network container:cassandra-node \
#   cassandra:4.1 cqlsh

# Example 6: Backup Cassandra data
# docker exec cassandra-node nodetool snapshot

# Example 7: Monitor Cassandra metrics
# docker exec cassandra-node nodetool cfstats

# Example 8: Production deployment with resource limits
# docker run -d \
#   -p 9042:9042 \
#   -v cassandra-data:/var/lib/cassandra \
#   -v cassandra-logs:/var/log/cassandra \
#   --name cassandra-prod \
#   --memory=8g \
#   --cpus=4.0 \
#   --restart unless-stopped \
#   my-cassandra:production

# BEST PRACTICES
# ==============

# Cassandra-Specific Best Practices:
# 1. Always configure appropriate heap sizes (HEAP_NEWSIZE and MAX_HEAP_SIZE)
# 2. Use persistent volumes for data directory (/var/lib/cassandra)
# 3. Configure proper seed nodes for cluster formation
# 4. Monitor disk space and compaction metrics regularly
# 5. Use appropriate consistency levels based on application requirements

# Security Best Practices:
# 1. Change default Cassandra credentials (cassandra/cassandra)
# 2. Enable authentication and authorization in production
# 3. Use SSL/TLS for client and internode communication
# 4. Regularly update Cassandra to get security patches
# 5. Limit network exposure (only expose necessary ports)

# Performance Best Practices:
# 1. Allocate sufficient memory (Cassandra is memory-intensive)
# 2. Use SSD storage for better I/O performance
# 3. Configure appropriate compaction strategy based on workload
# 4. Monitor and tune garbage collection settings
# 5. Use appropriate replication factor for data durability

# Operations Best Practices:
# 1. Implement regular backup strategy using nodetool snapshot
# 2. Monitor cluster health using nodetool status and metrics
# 3. Plan for regular maintenance (repair, cleanup, upgrades)
# 4. Use health checks for container orchestration
# 5. Implement proper logging and monitoring

# Combination Patterns:
# 1. Combine with tools/grafana.Dockerfile for monitoring visualization
# 2. Combine with tools/prometheus.Dockerfile for metrics collection
# 3. Combine with patterns/monitoring.Dockerfile for comprehensive monitoring
# 4. Combine with application templates for full-stack deployments
