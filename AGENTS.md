# AGENTS.md

## Repository

No build system, CI, linting, pre-commit hooks, or package manager. Flat directories of Dockerfile templates:

```
frameworks/  — self-contained, production-hardened (security, health checks, multi-stage)
languages/   — runtime base, modular for composition with patterns
patterns/    — reusable cross-cutting layers (combine with language templates)
tools/       — standalone infrastructure (databases, proxies, caches)
```

[TEMPLATE_STANDARDS.md](TEMPLATE_STANDARDS.md) is the canonical reference for headers, naming, template types, security requirements, and validation.

---

## File conventions

| Rule          | Detail                                                                                                            |
| ------------- | ----------------------------------------------------------------------------------------------------------------- |
| Extension     | `.Dockerfile` (capital D) — never `.dockerfile`                                                                   |
| Naming        | Lowercase, hyphens for spaces, strip dots and special chars                                                       |
| JS frameworks | Use the underlying GitHub repo name, strip org prefix and dots, never append `.js`                                |
| Header        | 6-line block: separator, `Created by https://Dockerfile.io/`, category line, `Website:`, `Repository:`, separator |
| Metadata      | `TEMPLATE OVERVIEW & USAGE NOTES` block immediately after header                                                  |
| Docs footer   | `USAGE EXAMPLES & BEST PRACTICES` block with ≥5 numbered examples at end of file                                  |
| Formatting    | LF line endings, exactly one trailing newline, no trailing whitespace                                             |

Critical name translations (see [TEMPLATE_STANDARDS.md#naming-convention](TEMPLATE_STANDARDS.md#naming-convention) for full table):

| Technology  | Template                                  |
| ----------- | ----------------------------------------- |
| Next.js     | `nextjs.Dockerfile`                       |
| NestJS      | `nest.Dockerfile` (repo is `nestjs/nest`) |
| Express.js  | `express.Dockerfile`                      |
| SolidJS     | `solid.Dockerfile`                        |
| .NET        | `dotnet.Dockerfile`                       |
| Spring Boot | `spring-boot.Dockerfile`                  |

---

## Header CATEGORY labels

| Directory     | Header line 3                   | Metadata `CATEGORY:` |
| ------------- | ------------------------------- | -------------------- |
| `frameworks/` | `Framework TEMPLATE for [Name]` | `Framework`          |
| `languages/`  | `Language TEMPLATE for [Name]`  | `Language`           |
| `patterns/`   | `Pattern TEMPLATE for [Name]`   | `Pattern`            |
| `tools/`      | `Tool TEMPLATE for [Name]`      | `Tool`               |

---

## Language template variation

TEMPLATE_STANDARDS.md says language templates should be modular — no security hardening (leave that to `patterns/security-hardened.Dockerfile`). In practice:

- **0 of 19** include an active `USER` directive (all are commented out, keeping templates minimal)
- **9 of 19** include an active `HEALTHCHECK`
- **7 of 19** have no `USER`: `go`, `java`, `node`, `php`, `python`, `ruby`, `typescript`

**Rule**: When editing a language template, follow TEMPLATE_STANDARDS.md — keep it modular. When creating a new language template, keep it modular unless there's a clear reason not to.

---

## Testing

```bash
docker build --no-cache -t template-test -f path/to/template.Dockerfile .
```

For framework templates, also verify:

- Non-root user active: `docker run --rm template-test whoami`
- Health check passes
- All multi-stage targets build

### Validation checklist

- [ ] Standard header + metadata block present
- [ ] Documentation footer with 5+ usage examples present
- [ ] Correct file naming (`.Dockerfile`, lowercase, hyphens, no dots)
- [ ] No `:latest` image tags
- [ ] Framework/tool: non-root user, health check, permissions
- [ ] Language: minimal and modular (no security hardening — leave that to patterns)
- [ ] `docker build --no-cache` succeeds
- [ ] Runs without errors: `docker run --rm template-test echo "OK"`
- [ ] LF line endings, no trailing whitespace
- [ ] Single trailing newline

All validation is manual — no automated CI or linting exists.

---

## Combining templates

Framework templates are self-contained. Language templates are modular. Patterns are layers.

```bash
# Language + pattern (canonical)
cat languages/go.Dockerfile patterns/security-hardened.Dockerfile > Dockerfile

# Framework + tool
cat frameworks/nextjs.Dockerfile tools/postgresql.Dockerfile > Dockerfile
```

---

## Commit conventions

Prefix every commit message: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`.

No hook enforces this — it's a team convention.

---

## Pitfalls

- `:latest` image tag → use pinned versions
- `.dockerfile` extension → must be `.Dockerfile`
- `.js` suffix on JS framework names → strip it
- Dots kept from GitHub names (e.g., `next.js.Dockerfile`) → `nextjs.Dockerfile`
- NestJS uses repo name `nest`, so filename is `nest.Dockerfile` (not `nestjs.Dockerfile`)
- Trailing whitespace → none allowed
- Multiple trailing newlines → exactly one
- Wrong template type label in header → check table above
