# ==============================================================================
# Created by https://Dockerfile.io/
# Pattern TEMPLATE for Docker Compose
# Website: https://docs.docker.com/compose/
# Repository: https://github.com/docker/compose
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Pattern
# · PURPOSE: Docker Compose integration patterns
# · DESIGN PHILOSOPHY: Modular patterns for Docker Compose workflows
# · COMBINATION: Combine with language or framework templates
# · SECURITY: Network isolation, volume security
# · BEST PRACTICES: Service definitions, network configurations
# · OFFICIAL SOURCES: Docker Compose documentation and best practices
#
# IMPORTANT: This template provides patterns for Docker Compose integration.

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DOCKER COMPOSE CONFIGURATION PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Pattern 1: Basic service definition
# services:
#   app:
#     build:
#       context: .
#       dockerfile: Dockerfile
#       args:
#         NODE_ENV: production
#     ports:
#       - "3000:3000"
#     environment:
#       - NODE_ENV=production
#     restart: unless-stopped

# Pattern 2: Multi-service application
# services:
#   app:
#     build: .
#     ports:
#       - "3000:3000"
#     depends_on:
#       - database
#       - cache
#
#   database:
#     image: postgres:15-alpine
#     environment:
#       POSTGRES_PASSWORD: example
#     volumes:
#       - postgres_data:/var/lib/postgresql/data
#
#   cache:
#     image: redis:7-alpine
#
#   nginx:
#     image: nginx:alpine
#     ports:
#       - "80:80"
#     volumes:
#       - ./nginx.conf:/etc/nginx/nginx.conf
#     depends_on:
#       - app
#
# volumes:
#   postgres_data:

# Pattern 3: Development with hot reload
# services:
#   app:
#     build:
#       context: .
#       target: development
#     ports:
#       - "3000:3000"
#     volumes:
#       - .:/app
#       - /app/node_modules
#     environment:
#       - NODE_ENV=development
#     command: npm run dev

# Pattern 4: Production with secrets
# services:
#   app:
#     build:
#       context: .
#       target: production
#     ports:
#       - "3000:3000"
#     environment:
#       - NODE_ENV=production
#     secrets:
#       - db_password
#     configs:
#       - app_config
#
# secrets:
#   db_password:
#     file: ./secrets/db_password.txt
#
# configs:
#   app_config:
#     file: ./config/app.config.json

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NETWORK CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Internal network for service communication
# networks:
#   internal:
#     driver: bridge
#     internal: true
#
# services:
#   app:
#     networks:
#       - internal
#   database:
#     networks:
#       - internal

# Multiple networks for segmentation
# networks:
#   frontend:
#     driver: bridge
#   backend:
#     driver: bridge
#     internal: true
#
# services:
#   web:
#     networks:
#       - frontend
#       - backend
#   api:
#     networks:
#       - backend
#   database:
#     networks:
#       - backend

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# VOLUME CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Named volumes for persistence
# volumes:
#   postgres_data:
#     driver: local
#   redis_data:
#     driver: local
#
# services:
#   database:
#     volumes:
#       - postgres_data:/var/lib/postgresql/data
#   cache:
#     volumes:
#       - redis_data:/data

# Bind mounts for development
# services:
#   app:
#     volumes:
#       - ./src:/app/src
#       - ./public:/app/public
#       - /app/node_modules  # anonymous volume for node_modules

# Tmpfs for temporary data
# services:
#   app:
#     tmpfs:
#       - /tmp
#       - /var/tmp

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RESOURCE MANAGEMENT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# CPU and memory limits
# services:
#   app:
#     deploy:
#       resources:
#         limits:
#           cpus: '1.0'
#           memory: 512M
#         reservations:
#           cpus: '0.5'
#           memory: 256M

# Restart policies
# services:
#   app:
#     restart: unless-stopped
#   database:
#     restart: always
#   cache:
#     restart: on-failure

# Health checks
# services:
#   app:
#     healthcheck:
#       test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
#       interval: 30s
#       timeout: 3s
#       retries: 3
#       start_period: 5s

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEPLOYMENT CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Docker Compose for production
# version: '3.8'
# services:
#   app:
#     image: myregistry/myapp:${TAG:-prod}
#     deploy:
#       replicas: 3
#       update_config:
#         parallelism: 2
#         delay: 10s
#       restart_policy:
#         condition: on-failure
#     environment:
#       - NODE_ENV=production
#     secrets:
#       - source: db_password
#         target: /run/secrets/db_password

# Docker Compose for development
# version: '3.8'
# services:
#   app:
#     build: .
#     ports:
#       - "3000:3000"
#     volumes:
#       - .:/app
#     environment:
#       - NODE_ENV=development
#       - DEBUG=*
#     command: npm run dev
#
#   database:
#     image: postgres:15-alpine
#     environment:
#       POSTGRES_PASSWORD: development
#     ports:
#       - "5432:5432"
#
#   redis:
#     image: redis:7-alpine
#     ports:
#       - "6379:6379"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENVIRONMENT-SPECIFIC CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Using environment variables in Compose
# services:
#   app:
#     image: myapp:${TAG:-prod}
#     environment:
#       DATABASE_URL: ${DATABASE_URL}
#       REDIS_URL: ${REDIS_URL}
#     ports:
#       - "${APP_PORT:-3000}:3000"

# Multiple Compose files
# docker-compose.yml (base)
# docker-compose.override.yml (development)
# docker-compose.prod.yml (production)

# Example: docker-compose.prod.yml
# services:
#   app:
#     restart: always
#     logging:
#       driver: "json-file"
#       options:
#         max-size: "10m"
#         max-file: "3"
#     deploy:
#       resources:
#         limits:
#           memory: 512M

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Basic development environment:
#    docker-compose up
#
# 2. Production deployment with multiple Compose files:
#    docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
#
# 3. Build and run services:
#    docker-compose build
#    docker-compose up
#
# 4. Service management commands:
#    docker-compose start
#    docker-compose stop
#    docker-compose restart
#    docker-compose logs -f
#
# 5. Scaling services horizontally:
#    docker-compose up --scale app=3
#
# 6. Development with hot reload:
#    docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
#
# 7. Production with secrets management:
#    docker-compose -f docker-compose.yml -f docker-compose.secrets.yml up -d
#
# 8. Multi-service application with database and cache:
#    cat patterns/docker-compose.Dockerfile > docker-compose.yml
#    # Customize the generated docker-compose.yml file
#    docker-compose up -d

# BEST PRACTICES
# ==============
# • Security & Compliance:
#   - Use specific image versions (avoid 'latest' tags)
#   - Implement proper network segmentation for service isolation
#   - Use Docker secrets for sensitive data instead of environment variables
#   - Regularly update base images and dependencies for security patches
#
# • Performance & Optimization:
#   - Set resource limits (CPU, memory) for production services
#   - Use named volumes for persistent data to improve I/O performance
#   - Implement health checks for all services to ensure reliability
#   - Configure logging drivers with rotation to manage disk space
#
# • Development & Operations:
#   - Separate development and production configurations using multiple Compose files
#   - Use environment variables for configuration to maintain environment parity
#   - Version control your Compose files alongside application code
#   - Test Compose configurations in CI/CD pipelines
#
# • Docker Compose-Specific Considerations:
#   - Understand Compose file syntax versions and compatibility
#   - Use depends_on for service dependencies but implement proper health checks
#   - Configure restart policies based on service criticality
#   - Use profiles for conditional service activation
#
# • Combination Patterns:
#   - Combine with language templates (node.Dockerfile, python.Dockerfile) for application configuration
#   - Use with patterns/multi-stage.Dockerfile for optimized build processes
#   - Integrate with patterns/security-hardened.Dockerfile for enhanced security
#   - Combine with tools templates (postgresql.Dockerfile, redis.Dockerfile) for service dependencies
#   - Use with patterns/ci-cd.Dockerfile for automated deployment pipelines
