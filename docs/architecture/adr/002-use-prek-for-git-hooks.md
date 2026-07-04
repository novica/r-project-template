---
tags:
  - tooling
---

# ADR-002: Use prek for git hooks
| | |
| ---| ---|
| **Status** |  🟢 Accepted |
| **Created**  | 2026-07-04 |
| **Last Updated**  | 2026-07-04 |
| **Deciders** | Novica Nakov |

---

## Context

This project's dependencies are R packages, managed with rv (see [ADR-003](003-manage-r-dependencies-with-rv.md)) — there is no project-level Python environment. `pre-commit` (formatting/linting orchestration, conventional-commit enforcement, spelling) is the standard framework for running Git hooks, but the reference `pre-commit` CLI is a Python tool, and every hook repo it runs (`air-pre-commit`, `jarl-pre-commit`, `conventional-pre-commit`, `codespell`) spins up its own isolated Python/Node environment underneath. Running Git hooks shouldn't require setting up a persistent, project-level Python dependency workflow (`pyproject.toml`, a checked-in virtualenv, etc.) for what is otherwise an R-only project.

## Problem Statement

How do we run `.pre-commit-config.yaml`'s hooks without introducing a persistent Python dependency setup?

## Options Considered

|  Option  | Description | Developer Experience | Speed | No persistent Python env | Config compatibility | Maturity | Overall score | Notes |
|----------|-------------|-------------|-----------------|-------------| ----- | ------|------|------|
| **Weight**      | - | 2 | 2 | 2 | 1 | 1 | - | - |
| **prek**        | Single Rust binary, drop-in for `pre-commit`; manages Python/Node/Go/Rust/Ruby toolchains itself. | ✅ | ✅ | ✅ | ✅ | ⚠️ | 25 | Reads the same `.pre-commit-config.yaml`, same CLI flags (`-t`, `--all-files`, `--hook-stage`). Newer project, smaller community than `pre-commit`. |
| **pre-commit via uv** | `uvx pre-commit ...` — run the reference Python CLI as an ephemeral `uv` tool invocation. | ✅ | ⚠️ | ❌ | ✅ | ✅ | 19 | Mature, huge hook ecosystem, but still needs `uv` and a Python env per hook. |
| **pre-commit via pipx** | `pipx install pre-commit`. | ⚠️ | ⚠️ | ❌ | ✅ | ✅ | 17 | Same Python dependency, slower installs than uv. |

✅ = 3 (good), ⚠️ = 2 (acceptable), ❌ = 1 (poor)

## Decision Outcome

We will use `prek`. It reads the exact same `.pre-commit-config.yaml` and exposes the same CLI (`install -t <type>`, `run --all-files --hook-stage <stage>`), so the hook configuration itself needs no changes. It avoids any Python/`uv` requirement — contributors only need the `prek` binary, consistent with how `rv`/`air`/`jarl` are already distributed (standalone Rust binaries, no runtime dependency).

## Consequences

* Good, because contributors don't need Python or `uv` installed just to run Git hooks.
* Good, because `prek` is generally faster than `pre-commit` and manages hook toolchains (including Python ones, via its own bundled `uv` integration) without any user-visible Python setup.
* Good, because `.pre-commit-config.yaml` works unchanged — no hook-repo migration needed.
* Bad/unknown risk: `prek` is newer and has a smaller install base and community than `pre-commit`; if a hook repo needs `pre-commit`-specific behavior `prek` doesn't yet replicate, we'd need to fall back to running that hook via `uvx pre-commit`.

## Confirmation

`justfile`'s `pre-commit-install` and `pre-commit` recipes shell out to `prek` directly. `.devcontainer/Dockerfile` installs the `prek` standalone binary. README's "Manual installation" section documents installing `prek`.

## Links

| Type | Links |
| -----| ------|
| **ADRs**   | [ADR-003](003-manage-r-dependencies-with-rv.md) |
| **Issues** | |
| **PRs**    | |
