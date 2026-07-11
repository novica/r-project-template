---
tags:
  - packaging
---

# ADR-003: Manage R dependencies with rv
| | |
| ---| ---|
| **Status** |  🔵 Superseded by [ADR-006](006-migrate-from-rv-to-uvr.md) |
| **Created**  | 2026-07-04 |
| **Last Updated**  | 2026-07-04 |
| **Deciders** | Novica Nakov |

---

## Context

Every R project needs a way to install a reproducible, pinned set of package dependencies across contributors' machines and CI. This project is not an R package (no `DESCRIPTION`/`NAMESPACE`), so tools built around the standard package-install workflow (`install.packages()`, `devtools::install_deps()`) don't have a natural manifest to read dependencies from. The manifest needs to declare runtime dependencies explicitly, since there is no `DESCRIPTION` to infer them from, and it needs to work for both runtime deps (e.g. `dplyr`) and tooling deps (`testthat`, `roxygen2`, `quartify`, `languageserver`) that a package's `DESCRIPTION` would normally split into `Imports` vs `Suggests`.

Note: this ADR documents a decision already implemented at project creation (retroactive record), not a proposal.

## Problem Statement

What R dependency manager should this template use to install and lock reproducible package versions?

## Options Considered

|  Option  | Description | Developer Experience | Speed | Reproducibility | Adoption/Maturity | CI | Explicit manifest | Overall score | Notes |
|----------|-------------|-------------|-----------------|-------------| ----- | ------|------|------|------|
| **Weight**      | - | 2 | 2 | 2 | 1 | 1 | 1 | - | - |
| **rv**          | Rust-based, declarative TOML manifest (`rproject.toml`) + lockfile (`rv.lock`), parallel installer. | ✅ | ✅ | ✅ | ⚠️ | ✅ | ✅ | 26 | Fast, explicit dependency list (deps declared up front, not inferred). Pre-1.0, smaller community. |
| **renv**        | RStudio/Posit-backed snapshot/restore tool; scans project code and the active library to build `renv.lock`. | ⚠️ | ⚠️ | ✅ | ✅ | ✅ | ❌ | 22 | De facto community standard, very mature. Dependency capture is inferred by scanning, not declared — can miss or over-capture packages. |
| **packrat**     | RStudio's older snapshot-based manager, predecessor to renv. | ❌ | ⚠️ | ✅ | ❌ | ⚠️ | ❌ | 15 | Deprecated in favor of renv; not actively developed. |
| **pak (ad hoc)**| Fast installer (`pak::pkg_install()`), no manifest/lockfile of its own. | ⚠️ | ✅ | ❌ | ✅ | ⚠️ | ❌ | 18 | Great for speed, but provides no lockfile/manifest layer by itself — would need pairing with renv for reproducibility. |

✅ = 3 (good), ⚠️ = 2 (acceptable), ❌ = 1 (poor)

## Decision Outcome

We will use rv. Its declarative manifest (`rproject.toml`) requires every dependency — including tooling-only deps like `testthat` and `roxygen2` — to be listed explicitly, which fits a non-package project with no `DESCRIPTION` to infer deps from. It is fast (Rust, parallel resolution/installs), which matters for CI, and its lockfile (`rv.lock`) gives the same reproducibility guarantee as `renv.lock`. This also keeps the template consistent with its other tool choices (`air`, `jarl` are likewise newer Rust-based R tooling) — see the README's stated caveat that this template deliberately explores emerging, not-yet-default tooling.

renv was the main alternative and remains the safer, more mature choice for projects that want the widest community support; it is the natural fallback if rv's development stalls.

## Consequences

* Good, because dependencies (runtime and tooling) are declared explicitly in one file, with no need for a `DESCRIPTION`/`NAMESPACE` package shape.
* Good, because installs are fast in CI (parallel resolver), reducing pipeline wait time.
* Bad, because rv is pre-1.0 and under active development — manifest format or CLI flags may change between versions.
* Unknown/risk: rv has a much smaller install base than renv; less community troubleshooting content, fewer integrations (e.g. RStudio's renv-aware UI features don't apply). Mitigation: revisit this ADR if rv development stalls or a breaking change imposes significant migration cost; renv is the documented fallback.

## Confirmation

`rproject.toml` and `rv.lock` are committed to the repo. `just install` / `just update` wrap `rv sync` / `rv upgrade`. CI (`ci.yml`) installs `rv` via its install script before running `rv sync`. README's "Manual installation" section documents installing `rv` first.

## Links

| Type | Links |
| -----| ------|
| **ADRs**   | [ADR-002](002-use-prek-for-git-hooks.md), [ADR-006](006-migrate-from-rv-to-uvr.md) |
| **Issues** | |
| **PRs**    | |
