---
tags:
  - tooling
---

# ADR-002: Use uv to invoke pre-commit hooks
| | |
| ---| ---|
| **Status** |  🟢 Accepted |
| **Created**  | 2025-10-18 |
| **Last Updated**  | 2026-07-04 |
| **Deciders** | Novica Nakov |

---

## Context

This project's dependencies are R packages, managed with rv (see [ADR-003](003-manage-r-dependencies-with-rv.md)) — there is no project-level Python environment. However, `pre-commit` (formatting/linting orchestration, conventional-commit enforcement, spelling) is a Python tool, and its hook repos (`air-pre-commit`, `jarl-pre-commit`, `conventional-pre-commit`, `codespell`, ...) run as isolated Python environments regardless of what manages the project's own dependencies. Contributors need a way to invoke `pre-commit` itself without setting up a persistent Python dependency-management workflow (`pyproject.toml`, a checked-in virtualenv, etc.) for what is otherwise an R-only project.

## Problem Statement

How do we run `pre-commit` — a Python tool — without introducing a persistent, project-level Python dependency setup?

## Options Considered

|  Option  | Description | Developer Experience | Speed | No persistent env | Adoption | CI | Overall score | Notes |
|----------|-------------|-------------|-----------------|-------------| ----- | ------|------|------|
| **Weight**      | - | 2 | 2 | 2 | 1 | 1 | - | - |
| **uv (uvx)**    | Rust-based Python tool runner; resolves and runs a tool in an ephemeral, cached env. | ✅ | ✅ | ✅ | ⚠️ | ✅ | 25 | One install, no lockfile/venv to maintain; version pins live in `.pre-commit-config.yaml` itself. |
| **pipx**        | Established tool for running Python CLIs in isolated venvs. | ✅ | ⚠️ | ✅ | ✅ | ✅ | 23 | Mature and widely adopted, but noticeably slower to install/run than uv. |
| **pip + venv**  | Manually create a project venv and `pip install pre-commit`. | ⚠️ | ⚠️ | ❌ | ✅ | ✅ | 18 | Requires a checked-in or documented venv — persistent Python state in an R project. |
| **System pip install** | `pip install --user pre-commit` globally. | ❌ | ✅ | ⚠️ | ✅ | ⚠️ | 16 | No isolation; version drifts across machines/CI; risk of clobbering other global installs. |

✅ = 3 (good), ⚠️ = 2 (acceptable), ❌ = 1 (poor)

## Decision Outcome

We will use `uvx pre-commit` (via uv). It runs `pre-commit` as an ephemeral, cached tool invocation with no persistent virtualenv or Python manifest to maintain, keeping the project's declared dependency surface R-only (`rproject.toml` / `rv.lock`) while still using the mature Python `pre-commit` ecosystem for hook orchestration. It is also extremely fast, which matters for the `pre-commit-install`/`pre-commit` justfile recipes and CI.

## Consequences

* Good, because contributors and CI only need `uv` installed — no `pyproject.toml`, `uv.lock`, or venv is added to the repo.
* Good, because hook tool versions are pinned in `.pre-commit-config.yaml` (`rev:` per repo), so reproducibility doesn't depend on a Python lockfile at all.
* Bad, because `uv` is a separate install contributors must have alongside `rv`/`air`/`jarl` — one more tool in the onboarding list.
* Unknown/risk: if a future hook needs Python dependencies beyond what its own repo declares, `uvx` alone won't manage those — would need to revisit (e.g. `uvx --with`).

## Confirmation

`justfile`'s `pre-commit-install` and `pre-commit` recipes both shell out to `uvx pre-commit ...`. README documents `uv` as an optional install, needed only for local hook usage.

## Links

| Type | Links |
| -----| ------|
| **ADRs**   | [ADR-003](003-manage-r-dependencies-with-rv.md) |
| **Issues** | |
| **PRs**    | |
