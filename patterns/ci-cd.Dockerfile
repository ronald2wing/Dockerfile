# ==============================================================================
# Created by https://Dockerfile.io/
# Pattern TEMPLATE for CI/CD Integration
# Website: https://dockerfile.io/
# Repository: https://github.com/ronald2wing/Dockerfile
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Pattern
# · PURPOSE: CI/CD integration patterns for Docker builds
# · DESIGN PHILOSOPHY: Reusable patterns for CI/CD pipelines
# · COMBINATION: Combine with language or framework templates
# · SECURITY: Build-time security, secret management
# · BEST PRACTICES: Cache optimization, multi-stage builds, testing
# · OFFICIAL SOURCES: Docker best practices and CI/CD guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CI/CD BUILD ARGUMENTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CI/CD specific build arguments
ARG CI=false
ARG CI_COMMIT_SHA=unknown
ARG CI_COMMIT_REF_NAME=unknown
ARG CI_COMMIT_TAG=
ARG CI_JOB_ID=unknown
ARG CI_PIPELINE_ID=unknown
ARG CI_PROJECT_URL=unknown
ARG DOCKER_BUILDKIT=1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CI/CD ENVIRONMENT VARIABLES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CI/CD metadata
ENV CI=${CI} \
  CI_COMMIT_SHA=${CI_COMMIT_SHA} \
  CI_COMMIT_REF_NAME=${CI_COMMIT_REF_NAME} \
  CI_COMMIT_TAG=${CI_COMMIT_TAG} \
  CI_JOB_ID=${CI_JOB_ID} \
  CI_PIPELINE_ID=${CI_PIPELINE_ID} \
  CI_PROJECT_URL=${CI_PROJECT_URL} \
  DOCKER_BUILDKIT=${DOCKER_BUILDKIT} \
  # Build optimization
  BUILDKIT_PROGRESS=plain \
  # Security
  DOCKER_CONTENT_TRUST=1

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD CACHE OPTIMIZATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Pattern 1: Multi-stage cache optimization
FROM alpine:3.19 AS cache-prepare

RUN mkdir -p /cache/apt /cache/npm /cache/pip /cache/gradle /cache/maven

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEPENDENCY CACHE PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Pattern 2: NPM cache configuration
# COPY --from=cache-prepare /cache/npm /root/.npm
# ENV npm_config_cache=/root/.npm

# Pattern 3: Pip cache configuration
# COPY --from=cache-prepare /cache/pip /root/.cache/pip
# ENV PIP_CACHE_DIR=/root/.cache/pip

# Pattern 4: Maven cache configuration
# COPY --from=cache-prepare /cache/maven /root/.m2
# ENV MAVEN_OPTS="-Dmaven.repo.local=/root/.m2/repository"

# Pattern 5: Gradle cache configuration
# COPY --from=cache-prepare /cache/gradle /root/.gradle
# ENV GRADLE_USER_HOME=/root/.gradle

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECRET MANAGEMENT PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Pattern 6: Build-time secrets (Docker BuildKit)
# RUN --mount=type=secret,id=npm_token \
#   npm config set //registry.npmjs.org/:_authToken $(cat /run/secrets/npm_token)

# Pattern 7: SSH key for private repositories
# RUN --mount=type=ssh \
#   git clone git@github.com:user/private-repo.git

# Pattern 8: Environment file for secrets
# RUN --mount=type=secret,id=env_file \
#   export $(cat /run/secrets/env_file | xargs) && \
#   echo "Secrets loaded"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TESTING PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Pattern 9: Test stage
FROM alpine:3.19 AS test

RUN apk add --no-cache \
  curl \
  jq \
  bash

COPY tests/ /tests/

ENV TEST_ENV=ci

ENTRYPOINT ["/tests/run-tests.sh"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY SCANNING PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Pattern 10: Security scanning stage
FROM alpine:3.19 AS security-scan

RUN apk add --no-cache \
  curl \
  bash \
  && curl -sSfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

COPY --from=build-stage-1 /app /app

CMD ["trivy", "filesystem", "--severity", "HIGH,CRITICAL", "/app"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# METADATA AND LABELING PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Pattern 11: Open Container Initiative (OCI) labels
LABEL org.opencontainers.image.title="Application" \
  org.opencontainers.image.description="Application container" \
  org.opencontainers.image.version="${CI_COMMIT_TAG:-${CI_COMMIT_SHA}}" \
  org.opencontainers.image.created="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
  org.opencontainers.image.source="${CI_PROJECT_URL}" \
  org.opencontainers.image.revision="${CI_COMMIT_SHA}" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.authors="Team"

# Pattern 12: Custom CI/CD labels
LABEL ci.job.id="${CI_JOB_ID}" \
  ci.pipeline.id="${CI_PIPELINE_ID}" \
  ci.commit.sha="${CI_COMMIT_SHA}" \
  ci.commit.ref="${CI_COMMIT_REF_NAME}" \
  ci.commit.tag="${CI_COMMIT_TAG}"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILD OPTIMIZATION PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Pattern 13: Parallel build stages
FROM alpine:3.19 AS build-stage-1
# Build step 1

FROM alpine:3.19 AS build-stage-2
# Build step 2

FROM alpine:3.19 AS build-stage-3
# Build step 3

# Pattern 14: Conditional builds
# ARG TARGETARCH
# ARG TARGETOS
# ARG TARGETVARIANT
#
# RUN if [ "$TARGETARCH" = "arm64" ]; then \
#   echo "Building for ARM64"; \
#   # ARM64 specific commands \
# else \
#   echo "Building for AMD64"; \
#   # AMD64 specific commands \
# fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ARTIFACT MANAGEMENT PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Pattern 15: Artifact export stage
FROM scratch AS artifact-export

COPY --from=build-stage-1 /app/dist /dist
COPY --from=build-stage-1 /app/build /build

# Pattern 16: SBOM (Software Bill of Materials) generation
FROM alpine:3.19 AS sbom-generator

RUN apk add --no-cache \
  curl \
  jq \
  && curl -sSfL https://github.com/anchore/syft/releases/download/v0.94.0/syft_0.94.0_linux_amd64.tar.gz | tar xz -C /usr/local/bin

COPY --from=build-stage-1 /app /app
CMD ["syft", "packages", "/app", "-o", "spdx-json"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============

# 1. Basic Combination Example:
# Combine this CI/CD pattern with language templates:
# cat languages/node.Dockerfile \
#     patterns/ci-cd.Dockerfile \
#     patterns/multi-stage.Dockerfile \
#     patterns/security-hardened.Dockerfile > Dockerfile

# 2. Complete CI/CD Pipeline Setup:
# 1. Start with language or framework template
# 2. Add this CI/CD pattern template
# 3. Add patterns/multi-stage.Dockerfile for optimization
# 4. Add patterns/security-hardened.Dockerfile for security

# 3. CI/CD Pipeline Integration Examples:

# GitHub Actions:
# ```
# jobs:
#   build:
#     runs-on: ubuntu-latest
#     steps:
#       - uses: actions/checkout@v4
#       - name: Build Docker image
#         run: |
#           docker build \
#             --build-arg CI=true \
#             --build-arg CI_COMMIT_SHA=${{ github.sha }} \
#             --build-arg CI_COMMIT_REF_NAME=${{ github.ref_name }} \
#             -t my-app:${{ github.sha }} .
# ```

# GitLab CI:
# ```
# build:
#   stage: build
#   script:
#     - docker build \
#         --build-arg CI=true \
#         --build-arg CI_COMMIT_SHA=$CI_COMMIT_SHA \
#         --build-arg CI_COMMIT_REF_NAME=$CI_COMMIT_REF_NAME \
#         -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
# ```

# Jenkins:
# ```
# pipeline {
#   agent any
#   environment {
#     DOCKER_BUILDKIT = '1'
#   }
#   stages {
#     stage('Build') {
#       steps {
#         sh '''
#           docker build \
#             --build-arg CI=true \
#             --build-arg CI_COMMIT_SHA=${GIT_COMMIT} \
#             --build-arg CI_COMMIT_REF_NAME=${BRANCH_NAME} \
#             -t my-app:${BUILD_NUMBER} .
#         '''
#       }
#     }
#   }
# }
# ```

# BEST PRACTICES
# ==============

# 1. CI/CD Best Practices:
#    • Use BuildKit for faster builds and secret management
#    • Implement multi-stage builds to reduce image size
#    • Add security scanning in the pipeline
#    • Generate SBOM for compliance
#    • Use cache optimization for faster builds
#    • Implement proper tagging strategy
#    • Add health checks and readiness probes
#    • Monitor build metrics and performance

# 2. Security Considerations:
#    • Never hardcode secrets in Dockerfiles
#    • Use Docker BuildKit secrets for sensitive data
#    • Scan images for vulnerabilities
#    • Sign images for authenticity
#    • Use content trust for image verification

# 3. Performance Optimization:
#    • Use .dockerignore to exclude unnecessary files
#    • Order Dockerfile instructions for optimal caching
#    • Use multi-architecture builds when needed
#    • Implement build cache sharing between jobs
#    • Use parallel build stages when possible

# 4. Combination Patterns:
#    • This template is designed to be combined with language/framework templates
#    • Always combine with security-hardened.Dockerfile for production
#    • Use multi-stage.Dockerfile for build optimization
#    • Consider adding monitoring.Dockerfile for observability

# 5. Testing Recommendations:
#    • Run security scans in CI/CD pipeline
#    • Test with different base images
#    • Validate multi-architecture builds
#    • Test secret management patterns
