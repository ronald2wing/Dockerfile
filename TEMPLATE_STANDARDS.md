# Template Standards

Every template in this repository must follow these rules. No exceptions.

---

## Template categories

| Category  | Directory     | Description                                                                |
| --------- | ------------- | -------------------------------------------------------------------------- |
| Framework | `frameworks/` | Self-contained, production-hardened (security, health checks, multi-stage) |
| Language  | `languages/`  | Runtime base; modular — designed to combine with patterns                  |
| Pattern   | `patterns/`   | Cross-cutting layer; combine with languages via `cat`                      |
| Tool      | `tools/`      | Infrastructure containers (databases, proxies, caches)                     |

---

## Naming convention

### Rules

- **Extension**: `.Dockerfile` (capital D — never `.dockerfile`)
- **Lowercase only** — no uppercase characters
- **Hyphens for spaces** — `spring-boot.Dockerfile`, not `spring_boot.Dockerfile`
- **Strip dots** — `nextjs.Dockerfile`, not `next.js.Dockerfile`
- **Strip special characters** — `csharp.Dockerfile`, not `C#.Dockerfile`

### JavaScript frameworks

Use the GitHub repository name, strip the org prefix and dots. Never append `.js`.

| Technology | GitHub repo         | Template name         |
| ---------- | ------------------- | --------------------- |
| React      | `facebook/react`    | `react.Dockerfile`    |
| Next.js    | `vercel/next.js`    | `nextjs.Dockerfile`   |
| Express.js | `expressjs/express` | `express.Dockerfile`  |
| Vue.js     | `vuejs/vue`         | `vue.Dockerfile`      |
| AdonisJS   | `adonisjs/core`     | `adonisjs.Dockerfile` |

### Examples

| Technology         | File name                       | Rule applied       |
| ------------------ | ------------------------------- | ------------------ |
| Visual Studio Code | `visual-studio-code.Dockerfile` | Hyphens for spaces |
| .NET               | `dotnet.Dockerfile`             | Strip dots         |
| Ruby on Rails      | `ruby-on-rails.Dockerfile`      | Hyphens for spaces |
| Spring Boot        | `spring-boot.Dockerfile`        | Hyphens for spaces |
| TypeScript         | `typescript.Dockerfile`         | Full name          |
| Node.js            | `node.Dockerfile`               | Repo: `node`       |

---

## Template anatomy

### Header (required, lines 1–6)

```dockerfile
# ==============================================================================
# Created by https://Dockerfile.io/
# [CATEGORY] TEMPLATE for [Technology Name]
# Website: [Official URL]
# Repository: [GitHub URL]
# ==============================================================================
```

### Metadata block (required, immediately after header)

```dockerfile
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TEMPLATE OVERVIEW & USAGE NOTES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# · CATEGORY:          [Framework / Language / Pattern / Tool]
# · PURPOSE:           [One-line description]
# · DESIGN PHILOSOPHY: [Design approach]
# · COMBINATION:       [How to combine with other templates]
# · SECURITY:          [Key security features]
# · BEST PRACTICES:    [Important notes]
# · OFFICIAL SOURCES:  [Reference docs]
```

### Section ordering

1. Metadata block
2. Base image (`FROM image:version`)
3. Build arguments (`ARG`)
4. Security setup (framework/tool: non-root user, permissions)
5. Dependencies (package install)
6. Application code (`COPY`, build)
7. Runtime config (`WORKDIR`, `EXPOSE`, `ENTRYPOINT`/`CMD`)
8. Documentation footer

### Documentation footer (required)

All templates must end with a `USAGE EXAMPLES & BEST PRACTICES` comment block:

```dockerfile
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# USAGE EXAMPLES & BEST PRACTICES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# USAGE EXAMPLES
# ==============
# 1. Basic build:
#    docker build -t my-app .
#
# 2. Development build:
#    docker build --build-arg NODE_ENV=development -t my-app:dev .
#
# 3. Production build:
#    docker build --build-arg NODE_ENV=production -t my-app:prod .
#
# 4. Multi-stage target:
#    docker build --target builder -t my-app:build .
#    docker build --target runtime -t my-app:prod .
#
# 5. CI/CD test:
#    docker build --build-arg NODE_ENV=test --no-cache -t my-app:test .

# BEST PRACTICES
# ==============
# · Security:    [key security notes]
# · Performance: [optimization tips]
# · Development: [dev workflow notes]
# · Operations:  [deploy/run notes]
# · Combination: [which patterns pair well]
```

Minimum 5 numbered examples: basic, dev, prod, multi-stage, CI/CD.

### Formatting rules

- **Line endings**: LF (Unix), not CRLF
- **Trailing whitespace**: must not exist
- **Trailing newline**: exactly one, no fewer, no more
- **Indentation**: spaces, consistent throughout
- **Comments**: `#` style, descriptive, no dead code

---

## Category requirements

### Framework templates

Must include all of:

1. Non-root user (`adduser`/`addgroup`)
2. Version-pinned base image (no `:latest`)
3. Proper file permissions (`chown`, `chmod`)
4. `HEALTHCHECK` instruction
5. Security-focused environment variables
6. Graceful shutdown signal handling (`STOPSIGNAL` or `exec` forms)

### Language templates

Modular runtime configurations. Designed to combine with pattern templates:

- **Keep minimal** — avoid security hardening that would conflict with `patterns/security-hardened.Dockerfile`
- Currently 12 of 19 include non-root `USER` directives. Follow existing patterns in the file you are editing.
- When in doubt, keep it modular (no security directives).

### Pattern templates

Reusable, language-agnostic layers. Must:

- Be independent of any specific language or framework
- Document which templates they pair with
- Express clear intent in the header metadata

### Tool templates

Must include:

1. Authentication configuration (databases)
2. Non-root execution where possible
3. Persistent data volume declarations
4. Health checks
5. Security headers (web servers, proxies)

---

## Security baseline

```dockerfile
# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S -u 1001 -G appgroup appuser

# Set ownership
RUN chown -R appuser:appgroup /app && \
    chmod -R 750 /app

# Switch to non-root
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["health-check-command"]

# Resource caps
ENV NODE_OPTIONS="--max-old-space-size=512"
```

---

## Combining templates

Framework templates are self-contained. Language templates are modular. Patterns are layers.

```bash
# Language + pattern (canonical)
cat languages/go.Dockerfile patterns/security-hardened.Dockerfile > Dockerfile

# Framework + tool
cat frameworks/nextjs.Dockerfile tools/postgresql.Dockerfile > Dockerfile

# Full production stack
cat frameworks/fastapi.Dockerfile \
    patterns/security-hardened.Dockerfile \
    patterns/monitoring.Dockerfile > Dockerfile
```

---

## Validation

### Required

```bash
docker build --no-cache -t template-test -f path/to/template.Dockerfile .
docker run --rm template-test echo "OK"
docker rmi template-test
```

### Checklist

- [ ] Standard header + metadata block present
- [ ] Correct file naming (`.Dockerfile`, lowercase, hyphens, no dots)
- [ ] No `:latest` image tags
- [ ] Framework/tool: non-root user, health check, permissions
- [ ] Language: minimal and modular
- [ ] Documentation footer with 5+ usage examples
- [ ] `docker build --no-cache` succeeds
- [ ] Runs without errors
- [ ] LF line endings, no trailing whitespace
- [ ] Single trailing newline
