# ==============================================================================
# Created by https://Dockerfile.io/
# Pattern TEMPLATE for WebAssembly (WASM)
# Website: https://webassembly.org/
# Repository: https://github.com/WebAssembly
# ==============================================================================

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY: Pattern
# · PURPOSE: WebAssembly compilation and runtime patterns for containers
# · DESIGN PHILOSOPHY: Portable, secure, and efficient WASM execution
# · COMBINATION: Combine with language templates for WASM compilation
# · SECURITY: Sandboxed execution, memory limits, capability-based security
# · BEST PRACTICES: WASM runtime selection, memory configuration, security hardening
# · OFFICIAL SOURCES: WebAssembly specification and runtime documentation
#
# IMPORTANT: WebAssembly provides sandboxed execution with memory safety.
# Choose appropriate WASM runtime based on your use case and performance needs.

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# WASM RUNTIME SELECTION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Available WASM runtimes (choose based on your requirements):

# Wasmtime (fast, standards-compliant):
# FROM rust:alpine AS wasmtime-builder
# RUN apk add --no-cache clang lld
# WORKDIR /app
# COPY . .
# RUN cargo build --target wasm32-wasi --release
#
# FROM ghcr.io/bytecodealliance/wasmtime:v18.0.0
# COPY --from=wasmtime-builder /app/target/wasm32-wasi/release/*.wasm .
# CMD ["wasmtime", "app.wasm"]

# Wasmer (multi-runtime support):
# FROM rust:alpine AS wasmer-builder
# WORKDIR /app
# COPY . .
# RUN cargo build --target wasm32-wasi --release
#
# FROM wasmer/wasmer:v4.2.4
# COPY --from=wasmer-builder /app/target/wasm32-wasi/release/*.wasm .
# CMD ["wasmer", "run", "app.wasm"]

# WasmEdge (cloud-native, high performance):
# FROM rust:alpine AS wasmedge-builder
# WORKDIR /app
# COPY . .
# RUN cargo build --target wasm32-wasi --release
#
# FROM wasmedge/wasmedge:v0.13.5
# COPY --from=wasmedge-builder /app/target/wasm32-wasi/release/*.wasm .
# CMD ["wasmedge", "app.wasm"]

# Node.js with WASI support:
# FROM node:18-alpine
# RUN apk add --no-cache wabt
# WORKDIR /app
# COPY . .
# CMD ["node", "--experimental-wasi-unstable-preview1", "app.js"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# COMPILATION PATTERNS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Rust to WASM (WASI target):
# FROM rust:alpine AS builder
# RUN apk add --no-cache clang lld
# WORKDIR /app
# COPY . .
# RUN cargo build --target wasm32-wasi --release
#
# FROM scratch
# COPY --from=builder /app/target/wasm32-wasi/release/app.wasm /
# CMD ["/app.wasm"]

# Go to WASM (TinyGo recommended):
# FROM tinygo/tinygo:0.31.0 AS builder
# WORKDIR /app
# COPY . .
# RUN tinygo build -target=wasi -o app.wasm .
#
# FROM scratch
# COPY --from=builder /app/app.wasm /
# CMD ["/app.wasm"]

# C/C++ to WASM (Emscripten):
# FROM emscripten/emsdk:3.1.59 AS builder
# WORKDIR /app
# COPY . .
# RUN emcc -o app.wasm app.c -s WASM=1 -s STANDALONE_WASM
#
# FROM scratch
# COPY --from=builder /app/app.wasm /
# CMD ["/app.wasm"]

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECURITY CONFIGURATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Memory limits (WASM runtime configuration):
# ENV WASMTIME_MEMORY_LIMIT="256MiB"
# ENV WASMER_MEMORY_LIMIT="256MiB"
# ENV WASMEDGE_MEMORY_LIMIT="256MiB"

# Capability-based security (WASI):
# LABEL wasi.capabilities="filesystem,network,clock"
# ENV WASI_CAPABILITIES="filesystem:/app,network,clock"

# Resource constraints:
# ENV WASM_MEMORY_PAGES="256"  # 16MB default
# ENV WASM_TABLE_SIZE="256"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PERFORMANCE OPTIMIZATIONS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Optimization flags for Rust:
# RUN RUSTFLAGS="-C target-feature=+bulk-memory" cargo build --target wasm32-wasi --release

# Optimization flags for TinyGo:
# RUN tinygo build -target=wasi -opt=2 -size=full -o app.wasm .

# WASM binary optimization (wasm-opt):
# RUN wasm-opt -O3 app.wasm -o app.optimized.wasm

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES
# ==============
# 1. Rust WASM application with Wasmtime:
#    FROM rust:alpine AS builder
#    RUN apk add --no-cache clang lld
#    WORKDIR /app
#    COPY . .
#    RUN cargo build --target wasm32-wasi --release
#
#    FROM ghcr.io/bytecodealliance/wasmtime:v18.0.0
#    COPY --from=builder /app/target/wasm32-wasi/release/app.wasm .
#    CMD ["wasmtime", "app.wasm"]
#
# 2. Go WASM application with TinyGo:
#    FROM tinygo/tinygo:0.31.0 AS builder
#    WORKDIR /app
#    COPY . .
#    RUN tinygo build -target=wasi -o app.wasm .
#
#    FROM wasmer/wasmer:v4.2.4
#    COPY --from=builder /app/app.wasm .
#    CMD ["wasmer", "run", "app.wasm"]
#
# 3. Multi-stage build with optimization:
#    FROM rust:alpine AS builder
#    RUN apk add --no-cache clang lld wabt
#    WORKDIR /app
#    COPY . .
#    RUN cargo build --target wasm32-wasi --release && \
#        wasm-opt -O3 target/wasm32-wasi/release/app.wasm -o app.optimized.wasm
#
#    FROM wasmedge/wasmedge:v0.13.5
#    COPY --from=builder /app/app.optimized.wasm .
#    CMD ["wasmedge", "app.optimized.wasm"]
#
# 4. Node.js with WASM modules:
#    FROM node:18-alpine
#    RUN apk add --no-cache wabt
#    WORKDIR /app
#    COPY package*.json ./
#    RUN npm install
#    COPY . .
#    CMD ["node", "app.js"]
#
# 5. WASM with filesystem access (WASI):
#    FROM rust:alpine AS builder
#    RUN apk add --no-cache clang lld
#    WORKDIR /app
#    COPY . .
#    RUN cargo build --target wasm32-wasi --release
#
#    FROM ghcr.io/bytecodealliance/wasmtime:v18.0.0
#    COPY --from=builder /app/target/wasm32-wasi/release/app.wasm .
#    RUN mkdir -p /data
#    CMD ["wasmtime", "--dir=/data", "app.wasm"]
#
# 6. WASM with networking:
#    FROM rust:alpine AS builder
#    RUN apk add --no-cache clang lld
#    WORKDIR /app
#    COPY . .
#    RUN cargo build --target wasm32-wasi --release
#
#    FROM wasmedge/wasmedge:v0.13.5
#    COPY --from=builder /app/target/wasm32-wasi/release/app.wasm .
#    CMD ["wasmedge", "--allow-net", "app.wasm"]
#
# 7. Health check for WASM applications:
#    HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#      CMD ["wasmtime", "--invoke", "health_check", "app.wasm"]
#
# 8. Resource limits for WASM containers:
#    ENV WASMTIME_MEMORY_LIMIT="128MiB"
#    ENV WASMTIME_FUEL_LIMIT="1000000000"

# BEST PRACTICES
# ==============
# Security:
# • WASM provides memory-safe sandboxed execution by default
# • Limit filesystem and network access using WASI capabilities
# • Set appropriate memory limits for each WASM module
# • Regularly update WASM runtimes for security patches

# Performance:
# • Optimize WASM binaries with wasm-opt tool
# • Choose appropriate WASM runtime for your use case
# • Consider AOT compilation for faster startup times
# • Profile WASM applications with runtime-specific tools

# Development:
# • Develop with standard toolchains first, then compile to WASM
# • Test with multiple WASM runtimes for compatibility
# • Use WASI for system interface when needed
# • Implement comprehensive error handling in WASM modules

# Operations:
# • Monitor WASM runtime memory usage and performance
# • Implement health checks specific to your WASM application
# • Consider cold start times for serverless deployments
# • Use appropriate resource limits for container orchestration

# Maintenance:
# • Regularly update compilation toolchains
# • Test with new versions of WASM runtimes
# • Monitor WASM specification updates
# • Update security configurations as runtimes evolve

# Combination Patterns:
# • Combine with languages/rust.Dockerfile for Rust WASM compilation
# • Combine with languages/go.Dockerfile for Go WASM compilation
# • Combine with patterns/distroless.Dockerfile for minimal containers
# • Combine with patterns/serverless.Dockerfile for FaaS deployments
# • Combine with patterns/edge-computing.Dockerfile for edge deployments

# WASM-Specific Considerations:
# • WASM provides portable bytecode execution across platforms
# • WASI enables system interface access with capability-based security
# • Different runtimes have different performance characteristics
# • Consider compilation targets (wasm32-unknown-unknown vs wasm32-wasi)
# • Memory management and garbage collection vary by language/runtime
