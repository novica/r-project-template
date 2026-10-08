---
tags:
  - packaging
---

# ADR-008: Migrate R dependency management from uvr to rig proj
| | |
| ---| ---|
| **Status** |  🟡 Proposed |
| **Created**  | 2026-10-08 |
| **Last Updated**  | 2026-10-08 |
| **Deciders** | Novica Nakov |

---

## Context

[ADR-006](006-migrate-from-rv-to-uvr.md) moved this template from rv to
[uvr](https://github.com/nbafrank/uvr) because uvr installs R itself and has native dev-dependencies. ADR-006
scored "renv + rig" lower for two reasons: it split the job across two tools, and neither had a dev-dependency
concept.

rig now ships [`rig proj`](https://rig.r-lib.org/reference/proj.html), which removes both objections. One tool
(rig) installs R and manages the project's packages:

| This template's need | uvr today | rig proj |
|---|---|---|
| Manifest | `uvr.toml` | `rproj.toml` |
| Lockfile | `uvr.lock` | `rproj.lock` |
| Dev-only deps | `[dev-dependencies]` | `[dependency-groups.dev]` (`rig proj add --dev`; `rig proj sync --no-dev` skips them) |
| Install pinned R | `uvr r install $(cat .r-version)` | `rig proj sync` installs the R version `rproj.lock` names |
| Pin R version | `.r-version` | `[tool.rig] r-versions = [...]` in `rproj.toml` |
| Project library in plain R sessions | `# >>> uvr >>>` block in `.Rprofile` → `.uvr/library` | `.Renviron` block + `.rvenvlib/rvenv` shim → `.rvenv/lib` |
| Run a script | `uvr run script.R` | `rig run script.R` (locks and syncs as needed) |

rig proj also brings features uvr does not cover here:

* A cross-platform lockfile: by default it solves for macOS, Windows, glibc Linux and source in one `rproj.lock`.
* A shared `tools` library that is on every project's library path, a natural home for `languageserver` and
  `roxygen2`.
* Inline script dependencies (`# /// script` blocks, like uv's PEP 723 scripts).
* Bioconductor, git/GitHub/GitLab, URL and local package sources, plus import/export of `DESCRIPTION` and
  `renv.lock`.

rig is maintained under r-lib (Posit). uvr has a single maintainer, which ADR-006 listed as a downside. However,
`rig proj` is documented as **experimental**: "rig proj is currently experimental, and might change in future
versions."

## Problem Statement

Now that `rig proj` covers R installation, locking, and dev-dependencies in one r-lib-maintained tool, should this
template replace uvr with it?

## Options Considered

|  Option  | Description | Handles R install | Dev-dependency support | CLI/format stability | Maintainer backing | Overall score | Notes |
|----------|-------------|-------------|-----------------|-------------| ----- | ----- | ------|
| **Weight**      | - | 2 | 1 | 2 | 1 | - | - |
| **uvr (status quo)** | Rust binary; packages + R install, `[dev-dependencies]`. | ✅ | ✅ | ⚠️ | ❌ | 14 | Working today, but pre-1.0 with a single maintainer. |
| **rig proj** | rig's project mode; packages + R install, dependency groups, cross-platform lock. | ✅ | ✅ | ❌ | ✅ | 14 | Officially experimental, but r-lib-backed, with extra features (tools library, inline script deps, platform-wide lock). |

✅ = 3 (good), ⚠️ = 2 (acceptable), ❌ = 1 (poor)

## Decision Outcome

Not decided yet. On these drivers the two options tie, so the decision depends on a hands-on trial (see
Confirmation). If the trial passes, migrate to rig proj: it costs the same and adds the cross-platform lock and
r-lib backing. If any blocking check fails, stay on uvr and revisit when `rig proj` is no longer experimental.

## Consequences

* Good, because R installation, package management, and the project library would be owned by an r-lib tool that
  is widely used for R installation.
* Good, because one `rproj.lock` covering every platform makes Windows/macOS contributors and Linux CI resolve to
  the same versions.
* Good, because the `tools` library and inline script dependencies fit this template's tooling and
  `scripts/` usage.
* Bad, because `rig proj` is experimental: the manifest, lockfile, or CLI may change, forcing follow-up migrations.
* Bad, because migration touches `justfile`, `ci.yml`, `generate-docs.yml`, the devcontainer `Dockerfile` and
  `postCreateCommand`, `.gitignore`, `.Rprofile`, `release-please-config.json` (`extra-files` → `rproj.toml`),
  `CLAUDE.md` and README.
* Risk: `R --vanilla` ignores `.Renviron`, so such sessions won't see the project library. This is the same as
  uvr's `.Rprofile` approach today, so it is no regression.
* Unknown: whether `rig proj sync` can fail on a stale lockfile the way `uvr sync --frozen` does in CI.

## Confirmation

Trial on a branch, on a Linux machine, before accepting. Each check must pass:

1. `rig` installs on Linux without root (user mode) via a script suitable for CI and the devcontainer.
2. `rig proj init` + `rig proj add box dplyr` + `rig proj add --dev languageserver roxygen2 testthat` reproduce
   the current `uvr.toml`; `rig proj lock` writes a lock covering Linux, macOS and Windows.
3. `rig proj sync` installs the pinned R (4.6.1) and the packages into `.rvenv/lib`.
4. Plain `Rscript` from the repo root sees the project library (the `box::use()` check ADR-006 used), and
   `rig run scripts/run-tests.R` passes the test suite.
5. `just docs-build` works unchanged apart from the runner.
6. CI can fail on a stale `rproj.lock` (find the flag equivalent to `uvr sync --frozen`, or a `rig proj status`
   check).
7. The devcontainer builds on `debian:bookworm-slim` with rig instead of uvr, and IDE paths keep working.
8. Windows: `rig proj sync` and `rig run` work for local development.

If accepted: replace `uvr.toml`/`uvr.lock`/`.r-version` with `rproj.toml`/`rproj.lock`, remove the uvr
`.Rprofile` block, gitignore `.rvenv/`, update the files listed under Consequences, and mark ADR-006
🔵 Superseded by ADR-008.

## Links

| Type | Links |
| -----| ------|
| **ADRs**   | [ADR-006](006-migrate-from-rv-to-uvr.md) (would be superseded by this) |
| **Docs**   | [rig proj reference](https://rig.r-lib.org/reference/proj.html) |
| **Issues** | |
| **PRs**    | |
