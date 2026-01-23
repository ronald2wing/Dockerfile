# ==============================================================================
# Created by https://Dockerfile.io/
# Pattern TEMPLATE for Zero-Downtime Deployments
# Website: https://dockerfile.io/
# Repository: https://github.com/ronald2wing/Dockerfile
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Pattern
# · PURPOSE: Enable zero-downtime deployments with health checks and graceful shutdown
# · DESIGN PHILOSOPHY: Maintain service availability during updates and deployments
# · COMBINATION: Combine with any application Dockerfile
# · SECURITY: Proper signal handling, connection draining
# · BEST PRACTICES: Health checks, readiness probes, graceful shutdown
# · OFFICIAL SOURCES: Docker documentation and Kubernetes deployment patterns

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ZERO-DOWNTIME DEPLOYMENT PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# This template provides patterns and configurations for zero-downtime deployments.
# Combine these patterns with your application Dockerfile to ensure availability.

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PATTERN 1: GRACEFUL SHUTDOWN HANDLER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Add to your application to handle SIGTERM signals gracefully
#
# Example implementation (Node.js):
# ```javascript
# process.on('SIGTERM', () => {
#   console.log('Received SIGTERM, starting graceful shutdown');
#   server.close(() => {
#     console.log('Server closed, exiting process');
#     process.exit(0);
#   });
#
#   // Force shutdown after timeout
#   setTimeout(() => {
#     console.log('Graceful shutdown timeout, forcing exit');
#     process.exit(1);
#   }, 30000);
# });
# ```
#
# Example implementation (Python):
# ```python
# import signal
# import sys
#
# def graceful_shutdown(signum, frame):
#     print("Received signal {}, starting graceful shutdown".format(signum))
#     # Cleanup logic here
#     sys.exit(0)
#
# signal.signal(signal.SIGTERM, graceful_shutdown)
# signal.signal(signal.SIGINT, graceful_shutdown)
# ```

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PATTERN 2: HEALTH CHECK CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Health checks for container orchestration systems
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:$${APP_PORT}/health || exit 1

# Alternative: Separate liveness and readiness probes
# Liveness: Is the application running?
# HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
#     CMD curl -f http://localhost:${APP_PORT}/health/live || exit 1
#
# Readiness: Is the application ready to serve traffic?
# HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
#     CMD curl -f http://localhost:${APP_PORT}/health/ready || exit 1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PATTERN 3: CONNECTION DRAINING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Implement connection draining in your application:
#
# 1. Track active connections
# 2. Stop accepting new connections when draining starts
# 3. Wait for existing connections to complete
# 4. Close remaining connections after timeout
#
# Example pattern:
# - Set a "draining" flag when SIGTERM received
# - Return 503 Service Unavailable for new requests
# - Allow existing requests to complete
# - Close server after all connections finished or timeout

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PATTERN 4: ROLLING UPDATE CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Docker Compose example for rolling updates:
# ```yaml
# version: '3.8'
# services:
#   app:
#     build: .
#     deploy:
#       replicas: 3
#       update_config:
#         parallelism: 1      # Update one instance at a time
#         delay: 10s          # Wait 10s between updates
#         order: start-first  # Start new before stopping old
#         failure_action: rollback
#       rollback_config:
#         parallelism: 0      # Rollback all at once
#         order: stop-first
#       restart_policy:
#         condition: on-failure
#         delay: 5s
#         max_attempts: 3
#         window: 120s
# ```

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PATTERN 5: MULTI-STAGE DEPLOYMENT SCRIPT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Example deployment script for zero-downtime updates:
# ```bash
# #!/bin/bash
# set -e
#
# # Build new image
# docker build -t myapp:${NEW_VERSION} .
#
# # Create new container without starting it
# docker create --name myapp-new \
#   --network myapp-network \
#   -p 8080:8080 \
#   myapp:${NEW_VERSION}
#
# # Start new container
# docker start myapp-new
#
# # Wait for new container to be healthy
# while ! docker inspect --format='{{.State.Health.Status}}' myapp-new | grep -q healthy; do
#   sleep 1
# done
#
# # Stop and remove old container
# docker stop myapp-old && docker rm myapp-old
#
# # Rename new container to old name
# docker rename myapp-new myapp-old
# ```

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PATTERN 6: LOAD BALANCER INTEGRATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Nginx configuration for zero-downtime deployments:
# ```nginx
# upstream app_backend {
#   server app1:8080 max_fails=3 fail_timeout=30s;
#   server app2:8080 max_fails=3 fail_timeout=30s;
#   server app3:8080 max_fails=3 fail_timeout=30s backup;
#
#   # Health check
#   check interval=3000 rise=2 fall=3 timeout=1000;
# }
#
# server {
#   listen 80;
#
#   location / {
#     proxy_pass http://app_backend;
#     proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
#     proxy_connect_timeout 2s;
#     proxy_read_timeout 30s;
#     proxy_send_timeout 30s;
#   }
#
#   location /health {
#     access_log off;
#     return 200 "healthy\n";
#   }
# }
# ```

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Basic pattern usage
# docker build -t my-app:v1.0.0 .

# Example 2: Pattern combination with application
# cat languages/node.Dockerfile \
#     patterns/zero-downtime.Dockerfile > Dockerfile

# Example 3: Multiple pattern combination
# cat languages/python.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/security-hardened.Dockerfile \
#     patterns/zero-downtime.Dockerfile > Dockerfile

# Example 4: Framework with zero-downtime pattern
# cat frameworks/express.Dockerfile \
#     patterns/zero-downtime.Dockerfile > Dockerfile

# Example 5: Production deployment with zero-downtime
# docker build --target runtime -t my-app:prod .

# Example 6: Docker Compose with zero-downtime configuration
# version: '3.8'
# services:
#   app:
#     build:
#       context: .
#       dockerfile: Dockerfile
#     ports:
#       - "8080:8080"
#     healthcheck:
#       test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
#       interval: 30s
#       timeout: 3s
#       retries: 3
#       start_period: 10s
#     deploy:
#       replicas: 3
#       update_config:
#         parallelism: 1
#         delay: 10s
#         order: start-first

# Example 7: Kubernetes deployment with zero-downtime
# kubectl apply -f deployment.yaml

# Example 8: Custom zero-downtime configuration
# docker build \
#   --build-arg HEALTH_CHECK_INTERVAL=60s \
#   --build-arg START_PERIOD=30s \
#   -t my-app:custom-zd .

# BEST PRACTICES
# ==============

# 1. Always implement graceful shutdown signal handling (SIGTERM)
# 2. Create health check endpoints (/health, /health/live, /health/ready)
# 3. Implement connection tracking and draining mechanisms
# 4. Design applications to be stateless where possible
# 5. Test zero-downtime deployments in staging before production

# Zero-Downtime Specific Considerations:
# • Implement HEALTHCHECK instructions in Dockerfile
# • Configure proper resource limits (memory, CPU)
# • Use read-only filesystem where possible
# • Run as non-root user for security
# • Implement rolling update strategies
# • Configure liveness and readiness probes
# • Set up pod disruption budgets
# • Implement resource quotas

# Implementation Guidelines:
# 1. Register signal handlers early in application startup
# 2. Test graceful shutdown with `docker stop --time=30 container_name`
# 3. Monitor application logs for shutdown messages
# 4. Increase health check `start-period` to allow application startup
# 5. Implement separate liveness and readiness probes
# 6. Configure connection draining for smooth updates
# 7. Use `start-first` update order for minimal disruption
# 8. Configure load balancer health checks appropriately

# Monitoring and Observability:
# • Track application metrics (request rate, error rate, latency)
# • Monitor container metrics (CPU, memory, network)
# • Collect deployment metrics (rollout status, success rate)
# • Set up alerting for deployment failures
# • Implement logging for deployment events

# Troubleshooting Common Issues:
# 1. Application doesn't respond to SIGTERM: Check signal handler registration
# 2. Health checks fail during deployment: Increase start-period or implement readiness probes
# 3. Connection errors during updates: Implement connection draining
# 4. Rollback takes too long: Keep previous image versions available
# 5. Deployment failures: Monitor metrics and implement fast rollback strategies

# Customization Notes:
# 1. Adjust health check intervals based on application requirements
# 2. Modify connection draining timeouts for your workload
# 3. Configure rolling update parameters for your orchestration platform
# 4. Implement application-specific graceful shutdown logic
# 5. Add monitoring for zero-downtime deployment effectiveness
