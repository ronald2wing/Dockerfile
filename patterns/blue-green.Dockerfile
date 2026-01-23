# ==============================================================================
# Created by https://Dockerfile.io/
# Pattern TEMPLATE for Blue-Green Deployments
# Website: https://dockerfile.io/
# Repository: https://github.com/ronald2wing/Dockerfile
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Pattern
# · PURPOSE: Implement blue-green deployment strategy for risk-free releases
# · DESIGN PHILOSOPHY: Maintain two identical environments (blue and green)
# · COMBINATION: Combine with any application Dockerfile
# · SECURITY: Database migrations, data consistency
# · BEST PRACTICES: Traffic switching, rollback capability, smoke testing
# · OFFICIAL SOURCES: Docker documentation and deployment strategies

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BLUE-GREEN DEPLOYMENT PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# This template provides patterns for blue-green deployments.
# Blue-green deployment maintains two identical production environments.

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PATTERN 1: DOCKER COMPOSE BLUE-GREEN SETUP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# docker-compose.blue-green.yml example:
# ```yaml
# version: '3.8'
#
# services:
#   # Blue environment (current production)
#   app-blue:
#     build: .
#     image: myapp:blue
#     container_name: myapp-blue
#     ports:
#       - "8081:8080"  # Internal port for load balancer
#     environment:
#       - APP_COLOR=blue
#       - DATABASE_URL=postgresql://user:pass@db/app
#     healthcheck:
#       test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
#       interval: 30s
#       timeout: 3s
#       retries: 3
#       start_period: 30s
#     networks:
#       - app-network
#       - lb-network
#
#   # Green environment (new deployment)
#   app-green:
#     build: .
#     image: myapp:green
#     container_name: myapp-green
#     ports:
#       - "8082:8080"  # Internal port for load balancer
#     environment:
#       - APP_COLOR=green
#       - DATABASE_URL=postgresql://user:pass@db/app
#     healthcheck:
#       test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
#       interval: 30s
#       timeout: 3s
#       retries: 3
#       start_period: 30s
#     networks:
#       - app-network
#       - lb-network
#
#   # Load balancer (switches between blue and green)
#   load-balancer:
#     image: nginx:alpine
#     container_name: app-lb
#     ports:
#       - "80:80"
#       - "443:443"
#     volumes:
#       - ./nginx.conf:/etc/nginx/nginx.conf:ro
#       - ./ssl:/etc/nginx/ssl:ro
#     depends_on:
#       - app-blue
#       - app-green
#     networks:
#       - lb-network
#
#   # Database (shared between blue and green)
#   database:
#     image: postgres:15-alpine
#     container_name: app-db
#     environment:
#       - POSTGRES_USER=appuser
#       - POSTGRES_PASSWORD=apppass
#       - POSTGRES_DB=appdb
#     volumes:
#       - postgres-data:/var/lib/postgresql/data
#     networks:
#       - app-network
#
# volumes:
#   postgres-data:
#
# networks:
#   app-network:
#     driver: bridge
#   lb-network:
#     driver: bridge
# ```

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PATTERN 2: NGINX LOAD BALANCER CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# nginx.conf for blue-green switching:
# ```nginx
# events {
#   worker_connections 1024;
# }
#
# http {
#   upstream blue_backend {
#     server app-blue:8080 max_fails=3 fail_timeout=30s;
#   }
#
#   upstream green_backend {
#     server app-green:8080 max_fails=3 fail_timeout=30s;
#   }
#
#   upstream active_backend {
#     # Default to blue
#     server app-blue:8080 max_fails=3 fail_timeout=30s;
#   }
#
#   # Split testing endpoint (for canary releases)
#   split_clients "${remote_addr}${http_user_agent}" $backend_selector {
#     95%     blue_backend;
#     5%      green_backend;
#   }
#
#   server {
#     listen 80;
#     server_name app.example.com;
#
#     # Main traffic goes to active backend
#     location / {
#       proxy_pass http://active_backend;
#       proxy_set_header Host $host;
#       proxy_set_header X-Real-IP $remote_addr;
#       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#       proxy_set_header X-Forwarded-Proto $scheme;
#       proxy_set_header X-Backend $upstream_addr;
#
#       # Health check headers
#       add_header X-Backend-Color $upstream_addr;
#     }
#
#     # Admin endpoint to switch between blue/green
#     location /admin/switch {
#       allow 10.0.0.0/8;  # Internal network only
#       deny all;
#
#       # Switch to blue
#       if ($arg_color = blue) {
#         set $active_backend blue_backend;
#         return 200 "Switched to blue\n";
#       }
#
#       # Switch to green
#       if ($arg_color = green) {
#         set $active_backend green_backend;
#         return 200 "Switched to green\n";
#       }
#
#       # Current status
#       return 200 "Current active: $active_backend\n";
#     }
#
#     # Health check endpoints
#     location /health/blue {
#       proxy_pass http://blue_backend/health;
#     }
#
#     location /health/green {
#       proxy_pass http://green_backend/health;
#     }
#   }
# }
# ```

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PATTERN 3: DEPLOYMENT SCRIPT FOR BLUE-GREEN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# deploy-blue-green.sh example:
# ```bash
# #!/bin/bash
# set -e
#
# # Configuration
# CURRENT_COLOR=$(curl -s http://localhost/admin/switch | grep -o 'blue\|green')
# NEW_COLOR="green"
#
# if [ "$CURRENT_COLOR" = "green" ]; then
#   NEW_COLOR="blue"
# fi
#
# echo "Current environment: $CURRENT_COLOR"
# echo "Deploying to: $NEW_COLOR"
#
# # Build new image
# docker build -t myapp:$NEW_COLOR .
#
# # Stop and remove old container for new color
# docker stop myapp-$NEW_COLOR 2>/dev/null || true
# docker rm myapp-$NEW_COLOR 2>/dev/null || true
#
# # Start new container
# docker run -d \
#   --name myapp-$NEW_COLOR \
#   --network app-network \
#   -p 8080:8080 \
#   -e APP_COLOR=$NEW_COLOR \
#   myapp:$NEW_COLOR
#
# # Wait for new container to be healthy
# echo "Waiting for $NEW_COLOR to be healthy..."
# for i in {1..30}; do
#   if docker inspect --format='{{.State.Health.Status}}' myapp-$NEW_COLOR | grep -q healthy; then
#     echo "$NEW_COLOR is healthy"
#     break
#   fi
#   sleep 2
# done
#
# # Run smoke tests on new environment
# echo "Running smoke tests on $NEW_COLOR..."
# if curl -f http://localhost:8080/health; then
#   echo "Smoke tests passed"
# else
#   echo "Smoke tests failed, aborting deployment"
#   exit 1
# fi
#
# # Switch traffic to new environment
# echo "Switching traffic to $NEW_COLOR..."
# curl -X POST "http://localhost/admin/switch?color=$NEW_COLOR"
#
# # Wait for old connections to drain
# sleep 30

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# Example 1: Basic blue-green deployment setup
# docker build -t my-app:blue .
# docker build -t my-app:green .

# Example 2: Deploy blue version
# docker run -d \
#   --name my-app-blue \
#   -p 8080:8080 \
#   -e APP_COLOR=blue \
#   --health-cmd="curl -f http://localhost:8080/health || exit 1" \
#   --health-interval=30s \
#   my-app:blue

# Example 3: Deploy green version
# docker run -d \
#   --name my-app-green \
#   -p 8081:8080 \
#   -e APP_COLOR=green \
#   --health-cmd="curl -f http://localhost:8080/health || exit 1" \
#   --health-interval=30s \
#   my-app:green

# Example 4: Switch traffic from blue to green
# # First, update load balancer configuration
# # Then, stop blue container after traffic drains
# docker stop my-app-blue

# Example 5: Automated blue-green deployment script
# # See the deployment script example above for complete implementation

# Example 6: Rollback from green to blue
# # Update load balancer back to blue
# # Start blue container if stopped
# docker start my-app-blue
# # Stop green container after traffic drains
# docker stop my-app-green

# Example 7: Canary deployment (gradual traffic shift)
# # Deploy new version to small percentage of traffic
# # Monitor metrics and errors
# # Gradually increase traffic if metrics look good

# Example 8: Production deployment with monitoring
# docker run -d \
#   --name my-app-production \
#   -p 443:8080 \
#   -e APP_COLOR=blue \
#   --restart unless-stopped \
#   --memory=512m \
#   --cpus=1.0 \
#   my-app:production

# BEST PRACTICES
# ==============

# Blue-Green Deployment Best Practices:
# 1. Always maintain two identical environments (blue and green)
# 2. Use health checks to ensure new deployment is healthy before switching
# 3. Implement smoke tests to validate new deployment
# 4. Use feature flags to control feature rollout independently of deployment
# 5. Monitor key metrics during and after deployment

# Traffic Switching Best Practices:
# 1. Use load balancers or service meshes for traffic routing
# 2. Implement gradual traffic shifting (canary deployments)
# 3. Monitor error rates and latency during switch
# 4. Have automatic rollback mechanisms in case of failures
# 5. Test rollback procedures regularly

# Safety & Reliability Best Practices:
# 1. Always test deployments in staging environment first
# 2. Keep previous version running until new version is verified
# 3. Implement comprehensive monitoring and alerting
# 4. Use database migrations that are backward compatible
# 5. Have documented rollback procedures

# Automation Best Practices:
# 1. Automate deployment process end-to-end
# 2. Use infrastructure as code for environment consistency
# 3. Implement automated testing at all levels (unit, integration, e2e)
# 4. Use configuration management for environment-specific settings
# 5. Automate rollback procedures

# Monitoring & Observability:
# 1. Monitor application metrics (response time, error rate, throughput)
# 2. Monitor infrastructure metrics (CPU, memory, disk, network)
# 3. Implement distributed tracing for request flow analysis
# 4. Set up alerts for abnormal behavior
# 5. Use log aggregation for debugging and analysis

# Combination Patterns:
# 1. Combine with patterns/zero-downtime.Dockerfile for comprehensive deployment strategies
# 2. Combine with patterns/monitoring.Dockerfile for production monitoring
# 3. Combine with patterns/ci-cd.Dockerfile for automated deployment pipelines
# 4. Combine with application templates for complete deployment solutions
# # Stop old environment
# echo "Stopping old environment: $CURRENT_COLOR"
# docker stop myapp-$CURRENT_COLOR
#
# echo "Blue-green deployment completed successfully"
# ```

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PATTERN 4: DATABASE MIGRATION STRATEGY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Database migrations in blue-green deployments:
#
# 1. **Backward Compatible Changes:**
#    - Add new columns with NULL defaults
#    - Don't remove or rename existing columns
#    - Use feature flags for new functionality
#
# 2. **Migration Script:**
# ```sql
# -- Phase 1: Add new column (backward compatible)
# ALTER TABLE users ADD COLUMN IF NOT EXISTS new_column VARCHAR(255) DEFAULT NULL;
#
# -- Phase 2: Migrate data (run in background)
# UPDATE users SET new_column = computed_value WHERE new_column IS NULL;
#
# -- Phase 3: Remove old column (after blue-green switch)
# -- ALTER TABLE users DROP COLUMN old_column;
# ```
#
# 3. **Application Code:**
# ```python
# # Feature flag for new functionality
# NEW_FEATURE_ENABLED = os.getenv('NEW_FEATURE', 'false').lower() == 'true'
#
# def get_user_data(user_id):
#     if NEW_FEATURE_ENABLED:
#         # Use new column
#         return query_new_column(user_id)
#     else:
#         # Use old column
#         return query_old_column(user_id)
# ```

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PATTERN 5: MONITORING AND OBSERVABILITY
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Monitoring configuration for blue-green:
#
# 1. **Metrics Collection:**
# ```yaml
# # prometheus.yml
# scrape_configs:
#   - job_name: 'app-blue'
#     static_configs:
#       - targets: ['app-blue:8080']
#     labels:
#       environment: 'blue'
#
#   - job_name: 'app-green'
#     static_configs:
#       - targets: ['app-green:8080']
#     labels:
#       environment: 'green'
# ```
#
# 2. **Alert Rules:**
# ```yaml
# groups:
#   - name: app-alerts
#     rules:
#       - alert: HighErrorRate
#         expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
#         for: 2m
#         labels:
#           severity: warning
#         annotations:
#           summary: "High error rate detected"
#           description: "Error rate is above 5% for environment {{ $labels.environment }}"
# ```

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PATTERN 6: ROLLBACK PROCEDURE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Rollback script for blue-green deployments:
# ```bash
# #!/bin/bash
# set -e
#
# CURRENT_COLOR=$(curl -s http://localhost/admin/switch | grep -o 'blue\|green')
# ROLLBACK_COLOR="blue"
#
# if [ "$CURRENT_COLOR" = "blue" ]; then
#   ROLLBACK_COLOR="green"
# fi
#
# echo "Current environment: $CURRENT_COLOR"
# echo "Rolling back to: $ROLLBACK_COLOR"
#
# # Check if rollback environment is healthy
# if docker inspect --format='{{.State.Health.Status}}' myapp-$ROLLBACK_COLOR | grep -q healthy; then
#   echo "$ROLLBACK_COLOR environment is healthy, proceeding with rollback"
# else
#   echo "$ROLLBACK_COLOR environment is not healthy, cannot rollback"
#   exit 1
# fi
#
# # Switch traffic back
# curl -X POST "http://localhost/admin/switch?color=$ROLLBACK_COLOR"
#
# # Wait for traffic to drain
# sleep 30
#
# # Stop failed environment
# docker stop myapp-$CURRENT_COLOR
#
# echo "Rollback completed successfully to $ROLLBACK_COLOR"
# ```

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# IMPLEMENTATION GUIDELINES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# To implement blue-green deployments:

# 1. **Infrastructure Requirements:**
#    - Two identical environments (blue and green)
#    - Load balancer with traffic switching capability
#    - Shared database or backward-compatible migrations
#    - Sufficient resources to run both environments

# 2. **Application Requirements:**
#    - Stateless design where possible
#    - Session externalization (Redis, database)
#    - Health check endpoints
#    - Feature flags for gradual rollout

# 3. **Deployment Process:**
#    - Deploy to inactive environment
#    - Run smoke tests
#    - Switch traffic
#    - Monitor for issues
#    - Keep previous environment for rollback

# 4. **Testing Strategy:**
#    - Smoke tests on new environment
#    - Canary releases (percentage-based traffic)
#    - A/B testing for new features
#    - Performance comparison between environments

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ADVANTAGES OF BLUE-GREEN DEPLOYMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 1. **Zero Downtime:** No interruption to users
# 2. **Instant Rollback:** Switch back to previous version
# 3. **Reduced Risk:** Test new version before traffic switch
# 4. **Simplified Recovery:** Previous version always available
# 5. **Easy Testing:** Run tests on live environment without affecting users

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONSIDERATIONS AND LIMITATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 1. **Resource Requirements:** Double the infrastructure
# 2. **Database Migrations:** Require backward compatibility
# 3. **Session State:** Need external session storage
# 4. **Configuration Management:** Both environments need same config
# 5. **Cost:** Higher infrastructure costs

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Combine with your application Dockerfile:

# Example: Application with blue-green support
# ```dockerfile
# FROM node:18-alpine
#
# # Install application
# COPY . .
# RUN npm ci --only=production
#
# # Health check for blue-green deployments
# HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
#   CMD node -e "require('http').get('http://localhost:3000/health', (r) => { process.exit(r.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"
#
# # Environment variable for blue/green identification
# ENV APP_COLOR=blue
#
# CMD ["node", "server.js"]
# ```

# Example: Docker Compose for development
# ```yaml
# version: '3.8'
# services:
#   app-blue:
#     build: .
#     environment:
#       - APP_COLOR=blue
#     ports:
#       - "8081:3000"
#
#   app-green:
#     build: .
#     environment:
#       - APP_COLOR=green
#     ports:
#       - "8082:3000"
#
#   load-balancer:
#     image: nginx:alpine
#     ports:
#       - "8080:80"
#     volumes:
#       - ./nginx-blue-green.conf:/etc/nginx/nginx.conf:ro
# ```

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TROUBLESHOOTING
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Common issues and solutions:

# 1. **Traffic not switching properly:**
#    - Check load balancer configuration
#    - Verify health checks are passing
#    - Test switch endpoint manually

# 2. **Database migration issues:**
#    - Ensure backward compatibility
#    - Test migrations on staging first
#    - Have rollback scripts ready

# 3. **Session state lost:**
#    - Implement external session storage
#    - Use sticky sessions in load balancer
#    - Consider stateless authentication (JWT)

# 4. **Performance differences:**
#    - Monitor both environments
#    - Compare metrics before switching
#    - Run load tests on new environment

# 5. **Configuration drift:**
#    - Use configuration management
#    - Store config in environment variables
#    - Use same config for both environments

# Remember: Blue-green deployments are most effective when combined with
# comprehensive testing, monitoring, and rollback procedures. Always test
# your deployment process in a staging environment before production use.
