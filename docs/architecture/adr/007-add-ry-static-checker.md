---
tags:
  - tooling
---

# ADR-007: Add ry static checker and track latest tool versions
| | |
| ---| ---|
| **Status** |  🟢 Accepted |
| **Created**  | 2026-09-24 |
| **Last Updated**  | 2026-09-24 |
| **Deciders** | Novica Nakov |

---

## Context

The template formats with `air` and lints with `jarl`, but nothing checks for likely runtime bugs before code runs:
incompatible types (`"a" + 1L`), unbound variables, misspelled data frame columns, invalid calls.
[ry](https://github.com/sims1253/ry) is a static type/scope checker for R, a standalone Rust binary inspired by astral's `ty`
and built on `tree-sitter-r`. It is meant to run alongside a formatter and linter, not replace them. It also ships an LSP
server and a VS Code / Positron extension (`scholzmx.ry-checker`). It is young (pre-1.0) and releases often, adding new
rules in most versions.

We checked ry 0.11.0 against this repo: it reported no findings on the current code. On a probe module with bugs
planted in it, ry caught all three: RY040 (character + integer arithmetic), RY010 (unbound variable) and RY060
(misspelled column, listing the real ones).

**ry does not understand `box::use()`.** It resolves names only via `library()`/`require()` and an R package's
`NAMESPACE`. What we observed:

- Names imported with `box::use(./mod[fn])` or `box::use(./mod[...])` are never bound. Using one as a *value*
  (e.g. `g <- say_hello`, `lapply(x, say_hello)`) reports a false RY010.
- Calls to unknown names are not checked at all, so a misspelled call (`helo("x")`) or importing a name the module
  doesn't export (`box::use(./hello[hello])`) goes unreported. This is why the current repo passes cleanly: tests only
  *call* box imports.
- Package functions imported through box (`box::use(dplyr[filter])`) are not tied to their package, so stub-based
  checks (e.g. data-masked column resolution) don't apply to them.

Separately, versions had drifted across the tools: CI installed air with `latest`, while `.pre-commit-config.yaml`
pinned air 0.8.2 and jarl 0.5.0 via their upstream hook repos. Those hook repos also use `language: python`, so prek
pip-installs the tools and a Python environment comes back, against the goal of [ADR-002](002-use-prek-for-git-hooks.md).

## Problem Statement

Static checking would catch real bugs early, but the checker doesn't model the template's module system, and tool
versions are inconsistent across hooks, CI and the devcontainer.
Should the template adopt ry, and how should it (and air/jarl) be versioned?

## Options Considered

|  Option  | Description | Bug detection | Low friction with box | Consistency across hooks/CI/editor | Maintenance | Overall score | Notes |
|----------|-------------|-------------|-----------------|-------------| ----- | ------|------|
| **Weight**   | - | 2 | 1 | 2 | 1 | - | |
| **A** | Add ry (blocking in CI), all tools on `latest`, local `system` hooks | ✅ | ⚠️ | ✅ | ✅ | 20 | New releases can fail CI without a code change; accepted as a signal to review |
| **B** | Add ry, pin every tool version in one place | ✅ | ⚠️ | ✅ | ❌ | 18 | Reproducible, but pins go stale in every project created from the template; no bot bumps curl-installer versions |
| **C** | Don't add ry | ❌ | ✅ | ⚠️ | ✅ | 14 | No type/scope checking; version drift still unresolved |

✅ = 3 (good), ⚠️ = 2 (acceptable), ❌ = 1 (poor)

## Decision Outcome

We will use **Option A**. ry catches real bugs that air and jarl cannot, and the current code is clean, so it can be
blocking from day one. In a template, getting new tool releases matters more than reproducible tool versions: projects
created from it should run the current air, jarl and ry, not whatever was pinned when they were forked.

- **Git hooks** (`.pre-commit-config.yaml`): air, jarl and ry run as `repo: local`, `language: system` hooks that call
  the installed binaries. This removes the pinned `rev`s and the Python install from the upstream air/jarl hook repos.
  The air hook falls back to `r-air`, the name some distros (e.g. Arch) package it under. `ry check .` runs on the whole
  project (`pass_filenames: false`), since ry resolves bindings across files.
- **CI** (`ci.yml`): installs ry with its `latest` installer and runs `ry check --output-format github .` after jarl,
  before tests, so findings show up as PR annotations.
- **Devcontainer / editors**: the Dockerfile installs the latest ry. The `scholzmx.ry-checker` extension is recommended
  and preinstalled.
- **`just typecheck`** runs `ry check .`. `just format` now resolves `air` or `r-air`.
- **`ry.toml`** documents how to work around the box limitation.

## Consequences

* Good, because type, scope and column bugs are caught before tests run, in CI, hooks and the editor.
* Good, because hooks, CI and devcontainer run the same (latest) versions, and hooks no longer need Python.
* Bad, because a new air/jarl/ry release can fail CI on unchanged code. The fix is to address the new finding or
  suppress it; a failing build isn't a regression in the project.
* Bad, because local `system` hooks require air, jarl and ry on `PATH`. prek no longer installs them.
* Bad, because referencing a box-imported name as a value gives a false RY010 until ry supports `box::use()`.
  Work around with `# ry: ignore[RY010]` inline, or `globals` in `ry.toml`.
* Risk: ry is pre-1.0; rule names, messages or config keys may change. Baselines match on message text, so reworded
  messages can bring back findings that were already accepted.

## Confirmation

CI runs `ry check` on every PR. Revisit this ADR if ry adds `box::use()` support (at that point, `ry.toml`'s `globals`
workaround can go) or if tracking `latest` causes repeated CI churn (then switch to Option B).

## Links

| Type | Links |
| -----| ------|
| **ADRs**   | [ADR-002](002-use-prek-for-git-hooks.md) |
| **Issues** | |
| **PRs**    | |
