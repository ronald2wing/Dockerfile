# ==============================================================================
# Created by https://Dockerfile.io/
# Pattern TEMPLATE for GPU-Accelerated Applications
# Website: https://dockerfile.io/
# Repository: https://github.com/ronald2wing/Dockerfile
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Pattern
# · PURPOSE: GPU acceleration support for machine learning and compute-intensive workloads
# · DESIGN PHILOSOPHY: NVIDIA/CUDA compatibility, GPU resource management
# · COMBINATION: Combine with language templates for GPU applications
# · SECURITY: GPU isolation, driver compatibility, resource limits
# · BEST PRACTICES: Specific CUDA versions, GPU memory management, multi-GPU support
# · OFFICIAL SOURCES: NVIDIA Container Toolkit, CUDA documentation

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# GPU ACCELERATION CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# This template provides GPU acceleration support.
# Requires NVIDIA Container Toolkit on the host system.

# GPU environment variables
ENV NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility \
    CUDA_VERSION=12.3 \
    GPU_MEMORY_LIMIT= \
    GPU_COUNT=1

# Install NVIDIA CUDA runtime (example - adjust based on your base image)
# Note: This section is commented out as it depends on the base image
# Uncomment and adjust for your specific CUDA requirements

# Example CUDA installation (for Ubuntu-based images):
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     cuda-toolkit-12-3 \
#     cuda-libraries-12-3 \
#     && rm -rf /var/lib/apt/lists/*

# Example for Alpine-based images (more complex):
# RUN apk add --no-cache --virtual .build-deps \
#     build-base \
#     linux-headers \
#     && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb \
#     && dpkg -i cuda-keyring_1.1-1_all.deb \
#     && apt-get update \
#     && apt-get install -y cuda-toolkit-12-3 \
#     && rm -rf /var/lib/apt/lists/* \
#     && apk del .build-deps

# GPU-specific labels
LABEL gpu.accelerated="true" \
      gpu.cuda.version="12.3" \
      gpu.nvidia.required="true" \
      io.requires.gpu="true"

# Health check for GPU availability
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD [ "sh", "-c", "nvidia-smi > /dev/null 2>&1 || exit 1" ]

# Example GPU application startup (override in your Dockerfile)
# CMD ["python", "gpu_app.py"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Basic GPU-accelerated application:
#    cat patterns/gpu-accelerated.Dockerfile > Dockerfile
#    docker build -t gpu-app .
#
# 2. Run with NVIDIA GPU support:
#    docker run --gpus all -it --rm gpu-app nvidia-smi
#
# 3. Development with mounted source code:
#    docker run --gpus all -it --rm -v $(pwd):/app -p 8888:8888 gpu-app
#
# 4. Production GPU deployment:
#    docker run --gpus all -d --restart unless-stopped --name gpu-prod gpu-app
#
# 5. Multi-GPU support:
#    docker run --gpus '"device=0,1"' -it --rm gpu-app
#
# 6. GPU memory limits:
#    docker run --gpus all --gpus '"device=0,memory=4096"' -it --rm gpu-app
#
# 7. Combining with language templates:
#    cat languages/python.Dockerfile patterns/gpu-accelerated.Dockerfile > Dockerfile
#    docker build -t python-gpu-app .
#
# 8. GPU monitoring and metrics:
#    docker run --gpus all -d --name gpu-monitored gpu-app

# BEST PRACTICES
# ==============
# • Security & Compliance:
#   - Use specific CUDA versions for reproducibility and compatibility
#   - Implement GPU isolation for multi-tenant environments
#   - Regularly update NVIDIA drivers and CUDA toolkit for security patches
#   - Use GPU memory limits to prevent resource exhaustion
#
# • Performance & Optimization:
#   - Match CUDA version with application requirements and host drivers
#   - Optimize GPU memory usage for efficient resource utilization
#   - Implement proper GPU health checks and monitoring
#   - Use multi-GPU configurations for parallel processing workloads
#
# • Development & Operations:
#   - Test GPU compatibility across different NVIDIA driver versions
#   - Implement graceful degradation for non-GPU environments
#   - Configure proper health checks for GPU availability
#   - Use environment variables for GPU-specific configuration
#
# • GPU-Specific Considerations:
#   - Understand CUDA compatibility between driver, runtime, and application
#   - Design for GPU memory constraints and optimization
#   - Implement multi-GPU support for scalable compute workloads
#   - Consider thermal and power constraints for GPU-intensive applications
#
# • Combination Patterns:
#   - Combine with language templates (python.Dockerfile, cuda.Dockerfile) for application logic
#   - Use with patterns/multi-stage.Dockerfile for optimized builds
#   - Integrate with patterns/security-hardened.Dockerfile for enhanced security
#   - Combine with tools/jupyter.Dockerfile for interactive GPU notebooks
#   - Use with patterns/monitoring.Dockerfile for GPU performance monitoring
