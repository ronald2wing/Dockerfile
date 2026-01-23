# ==============================================================================
# Created by https://Dockerfile.io/
# Pattern TEMPLATE for Development with Hot Reload
# Website: https://dockerfile.io/
# Repository: https://github.com/ronald2wing/Dockerfile
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Pattern
# · PURPOSE: Development environment configuration with hot reload capabilities
# · DESIGN PHILOSOPHY: Modular patterns for combination with language templates
# · COMBINATION: Combine with language templates for development setup
# · SECURITY: Development-focused, less restrictive than production
# · BEST PRACTICES: Volume mounting, live reload, debugging tools
# · OFFICIAL SOURCES: Docker development best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT ENVIRONMENT CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Development-specific environment variables
ENV NODE_ENV=development \
  DEBUG=true \
  WATCH_MODE=true \
  HOT_RELOAD=true

# Development tools and utilities
RUN apt-get update && apt-get install -y \
  curl \
  wget \
  git \
  vim \
  htop \
  && rm -rf /var/lib/apt/lists/*

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HOT RELOAD CONFIGURATIONS BY LANGUAGE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Node.js/JavaScript Hot Reload
# Install nodemon for automatic restart on file changes
RUN npm install -g nodemon

# Example nodemon configuration
# COPY nodemon.json .
# CMD ["nodemon", "server.js"]

# Python Hot Reload
# Install watchdog for file monitoring
RUN pip install watchdog

# Example Python hot reload with uvicorn
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

# Go Hot Reload
# Install air for Go hot reload
RUN go install github.com/cosmtrek/air@v1.51.0

# Example air configuration
# COPY .air.toml .
# CMD ["air"]

# Ruby Hot Reload
# Install rerun for Ruby file monitoring
RUN gem install rerun

# Example Ruby hot reload
# CMD ["rerun", "--pattern", "**/*.rb", "rails", "server"]

# Java Hot Reload (Spring Boot DevTools)
# Spring Boot DevTools automatically enables hot reload
# Ensure devtools dependency is in pom.xml or build.gradle

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEBUGGING TOOLS CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Node.js debugging
EXPOSE 9229  # Node.js debug port

# Python debugging
EXPOSE 5678  # Python debug port

# Java debugging
EXPOSE 5005  # Java debug port

# Go debugging
EXPOSE 2345  # Go debug port

# Install debugging tools
RUN npm install -g node-inspect || true
RUN pip install debugpy || true

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT VOLUME CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Create directories for volume mounting
RUN mkdir -p /app/src /app/tests /app/logs

# Set permissions for development (less restrictive than production)
RUN chmod 755 /app /app/src /app/tests /app/logs

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT DEPENDENCIES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Pattern for installing development dependencies

# Node.js development dependencies
# RUN npm install --only=development

# Python development dependencies
# RUN pip install -r requirements-dev.txt

# Go development tools
# RUN go get -u golang.org/x/tools/cmd/goimports
# RUN go get -u github.com/golangci/golangci-lint/cmd/golangci-lint

# Ruby development dependencies
# RUN bundle install --with development test

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TESTING TOOLS CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Install testing frameworks and tools

# Node.js testing
RUN npm install -g jest mocha chai sinon || true

# Python testing
RUN pip install pytest pytest-cov pytest-mock || true

# Go testing
RUN go install github.com/stretchr/testify/assert || true

# Ruby testing
RUN gem install rspec minitest || true

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT COMMAND PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Choose appropriate development command based on your language:

# Node.js development with hot reload
# CMD ["npm", "run", "dev"]

# Node.js with nodemon
# CMD ["nodemon", "server.js"]

# Python development with hot reload
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

# Go development with air
# CMD ["air"]

# Ruby development with rerun
# CMD ["rerun", "--pattern", "**/*.rb", "rails", "server"]

# Java/Spring Boot development
# CMD ["./mvnw", "spring-boot:run"]

# .NET Core development with watch
# CMD ["dotnet", "watch", "run"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT HEALTH CHECK
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Development health check (less frequent than production)
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=2 \
  CMD curl -f http://localhost:${PORT:-3000}/health || exit 1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMBINATION GUIDANCE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Combine with language templates for complete development setup:
# 1. Start with your language template (e.g., languages/node.Dockerfile)
# 2. Add this template for development configuration
# 3. Add patterns/development.Dockerfile for additional development tools

# Example combination for Node.js development:
# cat languages/node.Dockerfile \
#     patterns/hot-reload.Dockerfile \
#     patterns/development.Dockerfile > Dockerfile

# Example Docker Compose for development:
# version: '3.8'
# services:
#   app:
#     build:
#       context: .
#       dockerfile: Dockerfile
#     volumes:
#       - ./src:/app/src
#       - ./tests:/app/tests
#     ports:
#       - "3000:3000"
#       - "9229:9229"  # Debug port
#     environment:
#       - NODE_ENV=development
#       - DEBUG=true

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Run development container with volume mounting
# docker run -d \
#   --name myapp-dev \
#   -p 3000:3000 \
#   -p 9229:9229 \
#   -v $(pwd)/src:/app/src \
#   -v $(pwd)/tests:/app/tests \
#   -e NODE_ENV=development \
#   myapp:dev

# Example 2: Development with Docker Compose
# docker-compose -f docker-compose.dev.yml up

# Example 3: Debugging with VS Code
# Add to .vscode/launch.json:
# {
#   "version": "0.2.0",
#   "configurations": [
#     {
#       "type": "node",
#       "request": "attach",
#       "name": "Docker: Attach to Node",
#       "port": 9229,
#       "address": "localhost",
#       "localRoot": "${workspaceFolder}",
#       "remoteRoot": "/app"
#     }
#   ]
# }

# Example 4: Multi-service hot reload with container dependencies
# version: '3.8'
# services:
#   api:
#     build:
#       context: .
#       dockerfile: Dockerfile.hotreload
#     volumes:
#       - ./src:/app/src
#     depends_on:
#       - redis
#     ports:
#       - "3000:3000"
#       - "9229:9229"
#   redis:
#     image: redis:7-alpine
#     ports:
#       - "6379:6379"

# Example 5: CI/CD pipeline with hot reload testing
# docker build --build-arg NODE_ENV=test --no-cache -t myapp:test .
# docker run --rm myapp:test npm run test -- --watchAll=false

# Best Practices for Development:
# 1. Use volume mounting for source code to enable live editing
# 2. Enable debugging ports for IDE integration
# 3. Use .dockerignore to exclude build artifacts and node_modules
# 4. Set appropriate resource limits for development
# 5. Use separate Dockerfile for development vs production

# Development Security Notes:
# 1. Development containers may have less restrictive security
# 2. Avoid exposing sensitive data in development containers
# 3. Use different credentials for development databases
# 4. Regularly update development dependencies
# 5. Monitor for security vulnerabilities in dev tools
