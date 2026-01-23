# Dockerfile Templates

<div align="center">

**Production-ready Dockerfiles. Copy, build, run.**

[![Templates](https://img.shields.io/badge/templates-87-blue)](https://dockerfile.io)
[![License](https://img.shields.io/badge/license-MIT-yellow)](LICENSE)
[![Contributions](https://img.shields.io/badge/contributions-welcome-brightgreen)](CONTRIBUTING.md)

[Website](https://dockerfile.io) ·
[GitHub](https://github.com/ronald2wing/Dockerfile) ·
[Issues](https://github.com/ronald2wing/Dockerfile/issues) ·
[Contribute](CONTRIBUTING.md)

</div>

---

## Quick start

```bash
cp frameworks/nextjs.Dockerfile Dockerfile
docker build -t my-app .
docker run -p 3000:3000 my-app
```

---

## Categories

| Category       | Count | Philosophy                    | For                            |
| -------------- | ----- | ----------------------------- | ------------------------------ |
| **Frameworks** | 29    | Self-contained, hardened      | Full-stack apps, APIs, SPAs    |
| **Languages**  | 19    | Modular runtime base          | Custom services, microservices |
| **Patterns**   | 16    | Reusable cross-cutting layers | Layer onto language templates  |
| **Tools**      | 23    | Infrastructure container      | Data layer, networking         |

### Features

- **Pinned base images** — no `:latest` drift, reproducible builds
- **Non-root execution** — framework templates ship with unprivileged users
- **Multi-stage builds** — build toolchains never land in the final image
- **Health checks** — ready for orchestrators (K8s, Swarm, ECS)
- **Modular composition** — `cat` templates together for custom stacks

---

## Template catalog

### Frameworks (`frameworks/`)

Production-hardened: multi-stage builds, health checks, security baked in.

|                             |                      |                      |                      |                            |
| --------------------------- | -------------------- | -------------------- | -------------------- | -------------------------- |
| `angular.Dockerfile`        | `django.Dockerfile`  | `fiber.Dockerfile`   | `koa.Dockerfile`     | `remix.Dockerfile`         |
| `astro.Dockerfile`          | `dotnet.Dockerfile`  | `flask.Dockerfile`   | `laravel.Dockerfile` | `ruby-on-rails.Dockerfile` |
| `adonisjs.Dockerfile`       | `ember.Dockerfile`   | `gatsby.Dockerfile`  | `nest.Dockerfile`    | `solid.Dockerfile`         |
| `express.Dockerfile`        | `fastapi.Dockerfile` | `gin.Dockerfile`     | `nextjs.Dockerfile`  | `spring-boot.Dockerfile`   |
| `fastify.Dockerfile`        | `nuxt.Dockerfile`    | `phoenix.Dockerfile` | `svelte.Dockerfile`  | `sveltekit.Dockerfile`     |
| `play-framework.Dockerfile` | `qwik.Dockerfile`    | `react.Dockerfile`   | `vue.Dockerfile`     |                            |

### Languages (`languages/`)

Runtime-only, designed for composition with pattern templates. All are minimal and modular — layer on `patterns/security-hardened.Dockerfile` for non-root users and hardening. See [AGENTS.md](AGENTS.md#language-template-variation) for details.

|                     |                     |                      |                     |                         |
| ------------------- | ------------------- | -------------------- | ------------------- | ----------------------- |
| `bun.Dockerfile`    | `deno.Dockerfile`   | `go.Dockerfile`      | `kotlin.Dockerfile` | `rust.Dockerfile`       |
| `csharp.Dockerfile` | `elixir.Dockerfile` | `haskell.Dockerfile` | `node.Dockerfile`   | `scala.Dockerfile`      |
| `dart.Dockerfile`   |                     | `julia.Dockerfile`   | `php.Dockerfile`    | `swift.Dockerfile`      |
|                     |                     | `java.Dockerfile`    | `python.Dockerfile` | `typescript.Dockerfile` |
|                     |                     |                      | `r.Dockerfile`      | `ruby.Dockerfile`       |

### Patterns (`patterns/`)

Reusable layers. Combine with language templates via `cat`.

| Pattern                        | Purpose                                      |
| ------------------------------ | -------------------------------------------- |
| `alpine.Dockerfile`            | Alpine Linux base for minimal images         |
| `blue-green.Dockerfile`        | Blue-green deployment setup                  |
| `ci-cd.Dockerfile`             | Pipeline automation hooks                    |
| `development.Dockerfile`       | Dev tooling (debug ports, live reload hooks) |
| `distroless.Dockerfile`        | Distroless minimal attack surface            |
| `docker-compose.Dockerfile`    | Compose service scaffolding                  |
| `edge-computing.Dockerfile`    | Edge-optimized configs                       |
| `gpu-accelerated.Dockerfile`   | CUDA / GPU pass-through                      |
| `hot-reload.Dockerfile`        | File-watch + container-reload dev loop       |
| `microservices.Dockerfile`     | Inter-service communication patterns         |
| `monitoring.Dockerfile`        | Metrics, logs, tracing sidecars              |
| `multi-stage.Dockerfile`       | Multi-stage build boilerplate                |
| `security-hardened.Dockerfile` | Non-root, read-only fs, capability drops     |
| `serverless.Dockerfile`        | Cloud Function / Lambda packaging            |
| `wasm.Dockerfile`              | WebAssembly runtime targets                  |
| `zero-downtime.Dockerfile`     | Graceful shutdown + readiness probes         |

### Tools (`tools/`)

Infrastructure containers with auth configs, data dirs, and health checks.

|                            |                       |                        |                         |                          |
| -------------------------- | --------------------- | ---------------------- | ----------------------- | ------------------------ |
| `cassandra.Dockerfile`     | `grafana.Dockerfile`  | `mariadb.Dockerfile`   | `neo4j.Dockerfile`      | `redis.Dockerfile`       |
| `certbot.Dockerfile`       | `haproxy.Dockerfile`  | `memcached.Dockerfile` | `nginx.Dockerfile`      | `sqlite.Dockerfile`      |
| `clickhouse.Dockerfile`    | `influxdb.Dockerfile` | `minio.Dockerfile`     | `postgresql.Dockerfile` | `timescaledb.Dockerfile` |
| `elasticsearch.Dockerfile` | `kafka.Dockerfile`    | `mongodb.Dockerfile`   | `prometheus.Dockerfile` | `traefik.Dockerfile`     |
|                            |                       | `mysql.Dockerfile`     | `rabbitmq.Dockerfile`   | `varnish.Dockerfile`     |

---

## Usage

### Build arguments

```bash
docker build --build-arg NODE_ENV=production -t my-app .
```

### Runtime config

```bash
docker run -d -p 3000:3000 \
  -e NODE_ENV=production \
  --name my-app my-app
```

### Build variants

```bash
docker build --build-arg NODE_ENV=development -t my-app:dev .
docker build --build-arg NODE_ENV=production  -t my-app:prod .
docker build --build-arg NODE_ENV=test        -t my-app:test .
```

### Composing templates

Stack templates with `cat`. Language + pattern is the canonical composition. See [TEMPLATE_STANDARDS.md](TEMPLATE_STANDARDS.md#combining-templates) for examples and design intent.

---

## Security

Framework and tool templates ship hardened. For language templates, layer on `patterns/security-hardened.Dockerfile`. See [TEMPLATE_STANDARDS.md](TEMPLATE_STANDARDS.md#security-baseline) for full security requirements.

---

## Performance

- **Order layers by change frequency** — dependencies first, source last
- **Multi-stage builds** — separate build from runtime
- **`.dockerignore`** — exclude `node_modules`, `.git`, docs

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full process and [TEMPLATE_STANDARDS.md](TEMPLATE_STANDARDS.md) for template rules.

---

## Docs

| Document                                       | For                                            |
| ---------------------------------------------- | ---------------------------------------------- |
| [CONTRIBUTING.md](CONTRIBUTING.md)             | Contributors — workflow, PRs, testing          |
| [TEMPLATE_STANDARDS.md](TEMPLATE_STANDARDS.md) | Authors — format, naming, security, QA         |
| [AGENTS.md](AGENTS.md)                         | AI agents — conventions, pitfalls, maintenance |

---

## Related

- [dockerfile.io](https://dockerfile.io) — browse and copy templates online
- [.dockerignore templates](https://github.com/ronald2wing/.dockerignore) — 87+ ignore files
- [.gitignore templates](https://github.com/ronald2wing/.gitignores) — 129+ ignore files

---

<div align="center">

Maintained by [Dockerfile.io](https://dockerfile.io)

</div>
