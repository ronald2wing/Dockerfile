# ==============================================================================
# Created by https://Dockerfile.io/
# Language TEMPLATE for Rust
# Website: https://www.rust-lang.org/
# Repository: https://github.com/rust-lang/rust
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Language
# · PURPOSE: Rust development and production environment
# · DESIGN PHILOSOPHY: Modular patterns for combination with pattern templates
# · COMBINATION: Combine with patterns/multi-stage.Dockerfile and patterns/security-hardened.Dockerfile
# · SECURITY: No security patterns included - combine with security template
# · BEST PRACTICES: Build optimization, dependency caching, musl for static linking
# · OFFICIAL SOURCES: Rust documentation and Docker security guidelines

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# BUILDER STAGE - Compilation and testing
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM rust:1.70-alpine AS builder

# Build arguments for environment configuration
ARG BUILD_PROFILE=release
ARG BUILD_ID=unknown
ARG COMMIT_SHA=unknown
ARG CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

# Environment variables for build process
ENV BUILD_PROFILE=${BUILD_PROFILE} \
  BUILD_ID=${BUILD_ID} \
  COMMIT_SHA=${COMMIT_SHA} \
  CARGO_REGISTRIES_CRATES_IO_PROTOCOL=${CARGO_REGISTRIES_CRATES_IO_PROTOCOL} \
  RUSTFLAGS="-C target-feature=-crt-static" \
  CARGO_HOME=/usr/local/cargo \
  CARGO_TARGET_DIR=/tmp/target

# Install musl-tools for static linking
RUN apk add --no-cache \
  musl-dev \
  openssl-dev \
  pkgconfig \
  && rustup target add x86_64-unknown-linux-musl

WORKDIR /app

# Copy dependency files first for optimal layer caching
COPY Cargo.toml Cargo.lock ./

# Create dummy source files to cache dependencies
RUN mkdir -p src \
  && echo "fn main() {}" > src/main.rs \
  && echo "#[cfg(test)] mod tests { #[test] fn it_works() {} }" > src/lib.rs

# Download and cache dependencies
RUN cargo fetch --locked

# Build dependencies only (cached layer)
RUN cargo build --locked --target x86_64-unknown-linux-musl --profile ${BUILD_PROFILE} \
  && rm -rf src

COPY . .

# Build application
RUN cargo build --locked --target x86_64-unknown-linux-musl --profile ${BUILD_PROFILE} \
  && strip /tmp/target/x86_64-unknown-linux-musl/${BUILD_PROFILE}/app

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# RUNTIME STAGE - Production deployment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM alpine:3.18 AS runtime

# Install runtime dependencies
RUN apk add --no-cache \
  ca-certificates \
  tzdata \
  libgcc

# Set secure defaults
ENV UMASK=0027 \
  RUST_LOG=info \
  PORT=8080

WORKDIR /app

# Copy built binary from builder stage
COPY --from=builder /tmp/target/x86_64-unknown-linux-musl/release/app /usr/local/bin/app

# Create necessary directories
RUN mkdir -p /app/data /app/logs /app/config && \
  chmod -R 750 /app/data /app/logs /app/config

# Expose application port
EXPOSE 8080

# Health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#   CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Run application
CMD ["/usr/local/bin/app"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DEVELOPMENT STAGE - Full development environment
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM rust:1.70-alpine AS development

# Install development tools
RUN apk add --no-cache \
  musl-dev \
  openssl-dev \
  pkgconfig \
  git \
  bash \
  curl \
  vim \
  && cargo install cargo-watch \
  && cargo install cargo-audit

# Set development environment variables
ENV RUST_BACKTRACE=1 \
  RUST_LOG=debug \
  CARGO_HOME=/usr/local/cargo

WORKDIR /app

# Development command with hot reload
CMD ["cargo", "watch", "-x", "run"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TESTING STAGE - Unit and integration testing
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM rust:1.70-alpine AS testing

# Install testing dependencies
RUN apk add --no-cache \
  musl-dev \
  openssl-dev \
  pkgconfig

# Set testing environment variables
ENV RUST_BACKTRACE=1 \
  RUST_LOG=info

WORKDIR /app

COPY Cargo.toml Cargo.lock ./

# Download dependencies
RUN cargo fetch --locked

COPY . .

# Test command
CMD ["cargo", "test", "--verbose"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# AUDIT STAGE - Security vulnerability scanning
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FROM rust:1.70-alpine AS audit

# Install cargo-audit
RUN cargo install cargo-audit

WORKDIR /app

COPY Cargo.toml Cargo.lock ./

# Security audit command
CMD ["cargo", "audit"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Example 1: Build production image
# docker build --target runtime -t my-rust-app:prod .

# Example 2: Build development image
# docker build --target development -t my-rust-app:dev .

# Example 3: Build testing image
# docker build --target testing -t my-rust-app:test .

# Example 4: Run security audit
# docker build --target audit -t my-rust-app:audit .
# docker run --rm my-rust-app:audit

# Example 5: Run production container
# docker run -d -p 8080:8080 --name rust-app my-rust-app:prod

# Example 6: Run development container with hot reload
# docker run -d -p 8080:8080 -v $(pwd):/app --name rust-dev my-rust-app:dev

# Example Cargo.toml structure:
# [package]
# name = "myapp"
# version = "0.1.0"
# edition = "2021"
#
# [dependencies]
# tokio = { version = "1.0", features = ["full"] }
# warp = "0.3"
# serde = { version = "1.0", features = ["derive"] }
# tracing = "0.1"
# tracing-subscriber = "0.3"
#
# [dev-dependencies]
# tokio-test = "0.4"

# Example main.rs structure:
# use warp::Filter;
# use std::convert::Infallible;
#
# #[tokio::main]
# async fn main() {
#     // Initialize logging
#     tracing_subscriber::fmt::init();
#
#     // Health check endpoint
#     let health = warp::path!("health")
#         .map(|| warp::reply::json(&serde_json::json!({"status": "healthy"})));
#
#     // Your routes here
#     let hello = warp::path!("hello" / String)
#         .map(|name| format!("Hello, {}!", name));
#
#     let routes = health.or(hello);
#
#     warp::serve(routes)
#         .run(([0, 0, 0, 0], 8080))
#         .await;
# }

# Best Practices:
# 1. Always use .dockerignore to exclude target/, .git, etc.
# 2. Use specific Rust versions (not 'latest')
# 3. Enable LTO (Link Time Optimization) for release builds
# 4. Strip debug symbols from production binaries
# 5. Use musl target for static linking and smaller images
# 6. Implement proper error handling and logging
# 7. Use environment variables for configuration
# 8. Set up health checks for container orchestration

# Customization Notes:
# 1. Adjust Rust version based on your project requirements
# 2. Modify build profiles (debug, release, etc.)
# 3. Add additional system dependencies as needed
# 4. Configure logging levels and formats
# 5. Add database connections and connection pooling
# 6. Implement authentication and authorization
# 7. Set up metrics and monitoring endpoints
# 8. Configure graceful shutdown handling

# Combination with pattern templates:
# 1. For additional security: Combine with patterns/security-hardened.Dockerfile
# 2. For multi-stage optimization: Already included in this template
# 3. For Docker Compose: Combine with patterns/docker-compose.Dockerfile
# 4. For Alpine optimizations: Already using Alpine base images
