# Contributing

Everything you need to contribute a template, fix a bug, or improve the docs.

---

## Quick links

| I want to             | Go here                                           |
| --------------------- | ------------------------------------------------- |
| Create a new template | [Creating a template](#creating-a-template)       |
| Fix a bug             | [Opening a pull request](#opening-a-pull-request) |
| Fix docs              | [Opening a pull request](#opening-a-pull-request) |
| Report an issue       | [Bug reports](#bug-reports)                       |
| Know the rules        | [TEMPLATE_STANDARDS.md](TEMPLATE_STANDARDS.md)    |

---

## Code of Conduct

Be respectful and constructive. Harassment and personal attacks are not tolerated.

---

## Bug reports

Before opening an issue:

1. Check for [duplicates](https://github.com/ronald2wing/Dockerfile/issues)
2. Test with the latest template version
3. Rule out a Docker configuration problem

Include:

```markdown
**Template:** `frameworks/react.Dockerfile`
**Docker:** `24.0`
**OS:** `Ubuntu 22.04`

**Summary:** [What is wrong]

**Steps:**

1. cp frameworks/react.Dockerfile Dockerfile
2. docker build -t test .
3. [Error or unexpected behavior]

**Expected:** [What should happen]
**Actual:** [What happens]
```

---

## Creating a template

### 1. Research

- Read the official technology docs and Docker best practices
- Study existing templates in the same category

### 2. Choose a category

| Directory     | For                                                 |
| ------------- | --------------------------------------------------- |
| `frameworks/` | Self-contained, hardened Dockerfiles for frameworks |
| `languages/`  | Runtime-only, designed to combine with patterns     |
| `patterns/`   | Reusable cross-cutting layers                       |
| `tools/`      | Databases, proxies, caches, and utilities           |

### 3. Follow the standards

Every template must comply with [TEMPLATE_STANDARDS.md](TEMPLATE_STANDARDS.md):

- **Header**: standard `Created by https://Dockerfile.io/` block + metadata block
- **Naming**: `.Dockerfile` extension (capital D), lowercase, hyphens for spaces, strip dots
- **Security**: framework and tool templates require non-root users, pinned versions, health checks, proper permissions
- **Documentation footer**: 5+ usage examples and best practices

### 4. Test

Basic build test:

```bash
mkdir test-template && cd test-template
cp ../path/to/your-template.Dockerfile Dockerfile
echo '{"name": "test"}' > package.json
echo 'console.log("Test successful")' > index.js
docker build --no-cache -t template-test .
docker run --rm template-test
docker rmi template-test
cd .. && rm -rf test-template
```

For framework templates, also verify:

- Non-root user is active (`docker run --rm template-test whoami`)
- Health check passes
- Multi-stage targets build independently

---

## Opening a pull request

### 1. Fork and clone

```bash
git clone https://github.com/YOUR_USERNAME/Dockerfile.git
cd Dockerfile
git remote add upstream https://github.com/ronald2wing/Dockerfile.git
```

### 2. Branch

Branch names follow the convention `<type>/<description>` with lowercase kebab-case descriptions.

| Type        | Purpose          | Example                    |
| ----------- | ---------------- | -------------------------- |
| `feat/`     | New template     | `feat/add-astro-template`  |
| `fix/`      | Bug fix          | `fix/react-build-error`    |
| `docs/`     | Documentation    | `docs/improve-readme`      |
| `refactor/` | Code improvement | `refactor/simplify-nextjs` |
| `chore/`    | Maintenance      | `chore/update-base-images` |

```bash
git checkout -b feat/add-astro-template
git checkout -b fix/react-build-error
git checkout -b docs/improve-readme
```

### 3. Implement and test

Make your changes, run through the [testing requirements](#4-test) above.

### 4. Commit

Use conventional prefixes: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`.

```bash
git commit -m "feat: add astro.Dockerfile

- Multi-stage build with SSR support
- Non-root user and health check"
```

### 5. Push and open a PR

```bash
git push origin feat/add-astro-template
```

PR description:

```markdown
## Summary

Add Astro framework template.

## Changes

- `frameworks/astro.Dockerfile`: multi-stage build, health check, production config

## Testing

- Builds and runs with `docker build --no-cache`
- Non-root user active
- Dev and prod targets build successfully

## Checklist

- [x] Follows TEMPLATE_STANDARDS.md
- [x] Builds and runs clean
- [x] Security configs included
- [x] Documentation footer present
- [x] No conflicts

Closes #42
```

### 6. Review

A maintainer will review. Address feedback. Once approved, your PR will be merged.

---

## PR review

PRs are reviewed against the [Template Standards validation checklist](TEMPLATE_STANDARDS.md#checklist). See also the [testing requirements](#4-test) above.
