# ==============================================================================
# Created by https://Dockerfile.io/
# Pattern TEMPLATE for Development
# Website: https://dockerfile.io/
# Repository: https://github.com/ronald2wing/Dockerfile
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Pattern
# · PURPOSE: Development-specific patterns for local development workflows
# · DESIGN PHILOSOPHY: Optimized for developer experience and fast iteration
# · COMBINATION: Append to language templates for development setup
# · SECURITY: Development-focused, less restrictive than production
# · BEST PRACTICES: Hot reload, debugging tools, development dependencies
# · OFFICIAL SOURCES: Docker development best practices

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# This template provides development-specific patterns to be combined with
# language templates. It includes tools and configurations optimized for
# local development workflows.

# Development environment variables
ENV NODE_ENV=development \
  DEBUG=* \
  CHOKIDAR_USEPOLLING=true \
  WATCHPACK_POLLING=true \
  DOCKER_BUILDKIT=1

# Install development tools and debuggers
# Note: These should be customized based on the specific language/framework

# Example for Node.js development:
# RUN npm install -g nodemon

# Example for Python development:
# RUN pip install debugpy watchdog

# Example for Java development:
# RUN apt-get update && apt-get install -y maven gradle

# Example for Go development:
# RUN go install github.com/cosmtrek/air@v1.51.0

# Development port exposure
EXPOSE 9229  # Node.js debug port
EXPOSE 5678  # Python debug port
EXPOSE 5005  # Java debug port
EXPOSE 2345  # Rust debug port

# Volume mount for live code reload
# Note: This is typically configured in docker-compose or run command
# VOLUME /app

# Health check for development (less strict than production)
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=2 \
  CMD curl -f http://localhost:3000/ || exit 1

# Development entrypoint with debugging enabled
# Note: Customize based on language/framework
# ENTRYPOINT ["npm", "run", "dev"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEBUGGING CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Node.js debugging configuration
# ENV NODE_OPTIONS="--inspect=0.0.0.0:9229"

# Python debugging configuration
# ENV PYTHONPATH=/app

# Java debugging configuration
# ENV JAVA_TOOL_OPTIONS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"

# Go debugging configuration
# ENV GOPATH=/go

# Rust debugging configuration
# ENV RUST_BACKTRACE=1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT TOOLS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Common development utilities
RUN apt-get update && apt-get install -y \
  curl \
  wget \
  git \
  vim \
  nano \
  htop \
  net-tools \
  dnsutils \
  iputils-ping \
  && rm -rf /var/lib/apt/lists/*

# File watcher for hot reload (cross-platform)
# RUN npm install -g chokidar-cli || \
#   pip install watchdog || \
#   go install github.com/radovskyb/watcher/cmd/watcher@latest

# Development-specific package installations
# Note: These should be added to the main Dockerfile, not here
# but included as examples of what to add to development stage

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Combine with Node.js template for development
# cat languages/node.Dockerfile patterns/development.Dockerfile > Dockerfile.dev
#
# Then build and run:
# docker build -f Dockerfile.dev -t myapp:dev .
# docker run -d -p 3000:3000 -p 9229:9229 -v $(pwd):/app myapp:dev

# Example 2: Combine with Python template for development
# cat languages/python.Dockerfile patterns/development.Dockerfile > Dockerfile.dev
#
# Then build and run:
# docker build -f Dockerfile.dev -t myapp:dev .
# docker run -d -p 8000:8000 -p 5678:5678 -v $(pwd):/app myapp:dev

# Example 3: Development docker-compose configuration
# version: '3.8'
# services:
#   app:
#     build:
#       context: .
#       dockerfile: Dockerfile.dev
#     ports:
#       - "3000:3000"
#       - "9229:9229"  # Debug port
#     volumes:
#       - .:/app
#       - /app/node_modules  # Prevent host node_modules override
#     environment:
#       - NODE_ENV=development
#       - DEBUG=*
#     command: npm run dev

# Example 4: Development with hot reload and debugger
# cat languages/go.Dockerfile patterns/development.Dockerfile > Dockerfile.dev
# docker build -f Dockerfile.dev -t goapp:dev .
# docker run -d \
#   -p 8080:8080 \
#   -p 2345:2345 \
#   -v $(pwd):/app \
#   -e DEBUG=true \
#   goapp:dev

# Example 5: Multi-service development with Docker Compose
# version: '3.8'
# services:
#   api:
#     build:
#       context: .
#       dockerfile: Dockerfile.dev
#     ports:
#       - "3000:3000"
#       - "9229:9229"
#     volumes:
#       - .:/app
#       - /app/node_modules
#   db:
#     image: postgres:15-alpine
#     environment:
#       - POSTGRES_PASSWORD=devpassword
#     ports:
#       - "5432:5432"

# Development Best Practices:
# 1. Use bind mounts for live code reload (-v $(pwd):/app)
# 2. Expose debugging ports for IDE integration
# 3. Set development-specific environment variables
# 4. Install development tools and debuggers
# 5. Use less restrictive security for faster iteration
# 6. Implement health checks with longer timeouts
# 7. Use Docker BuildKit for faster builds (DOCKER_BUILDKIT=1)
# 8. Configure proper file watching for your platform

# Hot Reload Patterns by Language:

# Node.js with nodemon:
# CMD ["npx", "nodemon", "--inspect=0.0.0.0:9229", "server.js"]

# Python with watchdog:
# CMD ["python", "-m", "debugpy", "--listen", "0.0.0.0:5678", "app.py"]

# Go with air:
# CMD ["air", "-c", ".air.toml"]

# Java with Spring Boot DevTools:
# ENTRYPOINT ["java", "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005", "-jar", "app.jar"]

# Rust with cargo watch:
# CMD ["cargo", "watch", "-x", "run"]

# File Watching Considerations:
# 1. On Linux: Use inotify (default)
# 2. On macOS: Use fsevents or polling
# 3. On Windows: Use polling with CHOKIDAR_USEPOLLING=true
# 4. In Docker: May require polling depending on filesystem

# Debugging Setup:
# 1. Expose debug port in Dockerfile
# 2. Map debug port in run command (-p 9229:9229)
# 3. Configure IDE to connect to localhost:9229
# 4. Set breakpoints and inspect variables

# Development-Specific Security:
# 1. Run as root for easier file permissions during development
# 2. Disable production security restrictions
# 3. Enable verbose logging and debugging
# 4. Allow insecure connections for local development

# Note: This template is designed to be combined with language templates.
# It provides patterns and examples that should be customized for your
# specific development workflow and technology stack.
