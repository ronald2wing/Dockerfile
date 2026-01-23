# ==============================================================================
# Created by https://Dockerfile.io/
# Pattern TEMPLATE for Serverless Applications
# Website: https://dockerfile.io/
# Repository: https://github.com/ronald2wing/Dockerfile
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Pattern
# · PURPOSE: Optimizations for serverless and function-as-a-service deployments
# · DESIGN PHILOSOPHY: Minimal image size, fast cold starts, efficient resource usage
# · COMBINATION: Combine with language templates for serverless functions
# · SECURITY: Minimal attack surface, read-only filesystem where possible
# · BEST PRACTICES: Small base images, single binary deployments, health checks
# · OFFICIAL SOURCES: AWS Lambda, Google Cloud Functions, Azure Functions documentation

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SERVERLESS OPTIMIZATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# This template provides optimizations for serverless applications.
# Combine with language templates to create serverless-ready containers.

# Serverless-specific environment variables
ENV SERVERLESS_MODE=true \
    AWS_LAMBDA_RUNTIME_API= \
    FUNCTION_MEMORY_SIZE=128 \
    FUNCTION_TIMEOUT=30 \
    COLD_START_OPTIMIZED=true

# Health check optimized for serverless environments
HEALTHCHECK --interval=10s --timeout=2s --start-period=5s --retries=2 \
    CMD [ "sh", "-c", "test -f /tmp/serverless-ready || exit 1" ]

# Serverless-specific labels for orchestration
LABEL io.serverless.mode="true" \
      io.serverless.optimized="true" \
      io.serverless.cold-start="optimized"

# Example serverless function handler (override in your Dockerfile)
# CMD ["/var/task/bootstrap"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Basic serverless function:
#    cat patterns/serverless.Dockerfile > Dockerfile
#    docker build -t serverless-function .
#
# 2. AWS Lambda deployment:
#    docker build -t lambda-function .
#    # Use AWS ECR to push and deploy as Lambda function
#
# 3. Google Cloud Functions deployment:
#    docker build -t gcf-function .
#    # Use Google Container Registry to deploy as Cloud Function
#
# 4. Azure Functions deployment:
#    docker build -t azure-function .
#    # Use Azure Container Registry to deploy as Function App
#
# 5. Development with mounted source code:
#    docker run -it --rm -v $(pwd):/var/task -p 8080:8080 serverless-function
#
# 6. Production serverless deployment:
#    docker run -d --restart unless-stopped --memory=128m --cpus=0.5 --name serverless-prod serverless-function
#
# 7. Combining with language templates:
#    cat languages/node.Dockerfile patterns/serverless.Dockerfile > Dockerfile
#    docker build -t node-serverless-function .
#
# 8. Serverless monitoring and logging:
#    docker run -d --log-driver=awslogs --log-opt awslogs-group=serverless --name serverless-monitored serverless-function

# BEST PRACTICES
# ==============
# • Security & Compliance:
#   - Use minimal base images (Alpine Linux) to reduce attack surface
#   - Implement read-only filesystems where possible for serverless functions
#   - Regularly update base images and dependencies for security patches
#   - Use environment variables for sensitive configuration instead of hardcoding
#
# • Performance & Optimization:
#   - Optimize for cold start performance with minimal dependencies
#   - Set appropriate memory and CPU limits for serverless environments
#   - Implement efficient health checks for serverless platforms
#   - Use lightweight logging drivers to reduce overhead
#
# • Development & Operations:
#   - Design for stateless operation and horizontal scaling
#   - Implement graceful degradation and error handling
#   - Configure proper health checks for serverless platforms
#   - Use environment variables for platform-specific configuration
#
# • Serverless-Specific Considerations:
#   - Understand cold start performance implications and optimization strategies
#   - Design for event-driven architectures and asynchronous processing
#   - Implement proper error handling and retry logic
#   - Consider platform-specific constraints and best practices
#
# • Combination Patterns:
#   - Combine with language templates (node.Dockerfile, python.Dockerfile, go.Dockerfile) for function logic
#   - Use with patterns/alpine.Dockerfile for minimal image sizes
#   - Integrate with patterns/security-hardened.Dockerfile for enhanced security
#   - Combine with patterns/multi-stage.Dockerfile for optimized builds
#   - Use with patterns/monitoring.Dockerfile for function performance monitoring
