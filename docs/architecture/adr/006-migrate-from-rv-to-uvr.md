---
tags:
  - packaging
---

# ADR-006: Migrate R dependency management from rv to uvr
| | |
| ---| ---|
| **Status** |  🟢 Accepted |
| **Created**  | 2026-07-04 |
| **Last Updated**  | 2026-07-11 |
| **Deciders** | Novica Nakov |

---

## Context

This template used `rv` ([ADR-003](003-manage-r-dependencies-with-rv.md)) for R package dependency management,
with a custom `.Rprofile` + `rv/scripts/{rvr,activate}.R` shim to make rv's project library available to plain
`Rscript`/interactive R sessions. R version *installation* itself wasn't handled by any tool in this repo —
CI used `r-lib/actions/setup-r`, the devcontainer used a pinned `rocker/r-ver` base image. `rproject.toml` only
carried a comment citing `r-rig` as the reason `r_version` couldn't always be freely changed
(https://github.com/r-lib/rig/issues/317) — rig itself was never actually installed/used anywhere in this repo.

[uvr](https://github.com/nbafrank/uvr) is a single Rust binary that does both package dependency management
*and* R version installation (`uvr r install`), with **native dev-dependency support** — something rv
explicitly lacked (called out repeatedly in `rproject.toml`'s own comments, `CLAUDE.md`, and ADR-003's
Consequences). This ADR was blocked on
[nbafrank/uvr#116](https://github.com/nbafrank/uvr/pull/116) (portable R builds, replacing per-platform
installers/patches, fixing known R-install bugs on macOS/some Linux distros) — that PR merged 2026-07-11 and
shipped in uvr 0.4.0, clearing the way to implement this for real.

## Problem Statement

Should this template replace rv with uvr for R dependency management, given uvr additionally handles R version
installation (something no tool in this repo did before) and supports dev-only dependencies natively?

## Options Considered

|  Option  | Description | Handles R install | Dev-dependency support | Maturity | Overall score | Notes |
|----------|-------------|-------------|-----------------|-------------| ----- | ------|
| **Weight**      | - | 2 | 1 | 2 | - | - |
| **rv (status quo)** | Rust-based, declarative TOML manifest + lockfile, parallel installer. | ❌ | ❌ | ⚠️ | 10 | No R-version installation at all (relies on CI/devcontainer pinning separately); explicitly no dev-dependency concept. |
| **uvr** | Rust-based, combines package management + R version installation, dev-dependencies section. | ✅ | ✅ | ⚠️ | 22 | Chosen. Younger/smaller than rv (single maintainer vs A2-ai). |
| **renv + rig** | Two separate mature tools instead of one. | ✅ | ❌ | ✅ | 17 | Each individually more mature than rv/uvr, but reintroduces the two-tool split this migration is meant to collapse, and renv still has no first-class dev-dependency concept. |

✅ = 3 (good), ⚠️ = 2 (acceptable), ❌ = 1 (poor)

## Decision Outcome

We migrated to uvr. `uvr.toml` replaces `rproject.toml`: `box`/`dplyr` as real `[dependencies]`,
`languageserver`/`roxygen2`/`testthat` moved to `[dev-dependencies]` — the exact split rv couldn't express.
`uvr.lock` replaces `rv.lock`. A `.r-version` file (written by `uvr r pin`) pins the exact R version
(`4.6.1`), separate from `uvr.toml`'s looser `r_version = ">=4.6.0"` constraint — the same two-tier pattern
`uv python pin` uses.

**The biggest open question going in — whether plain `Rscript`/interactive R sessions would need wrapping in
`uvr run` to see the project library — resolved cleanly in uvr's favor**: `uvr init` appends a self-managed
block to `.Rprofile` (delimited by `# >>> uvr >>>` / `# <<< uvr <<<`) that adds `.uvr/library` to
`.libPaths()` automatically and warns on an R-version/`.r-version` mismatch. Verified directly: a bare
`Rscript -e 'library(testthat); box::use(hello = ./src/package_name/hello); ...'` run from the repo root sees
the project library with no wrapper at all. This means `justfile`'s `test`/`docs-build` recipes and both CI
workflows' `Rscript` calls needed **no changes** — only the install/sync steps changed.

The devcontainer base image was swapped from `rocker/r-ver:4.6.1` to `debian:bookworm-slim` + `uvr r install`
— since uvr now owns R installation, pinning an R-specific base image is redundant. A portable R 4.6.1 build
downloaded from `cdn.posit.co` and installed in ~34s locally, matching the reliability #116 was meant to
deliver.

`justfile`'s `install` recipe is now `uvr r install $(cat .r-version) && uvr sync`; `update` is `uvr update`.
CI (`ci.yml`, `generate-docs.yml`) installs `uvr` via its release `install.sh` (same curl-script pattern as
air/jarl/prek/rd2qmd), then `uvr r install $(cat .r-version)`, then `uvr sync --frozen` (fails fast on a stale
lockfile — stricter than rv's CI usage was, worth adopting). The separate `r-lib/actions/setup-r` step was
dropped entirely.

## Consequences

* Good, because this template now has a working R-version-installation story for the first time — one tool
  (`uvr`) owns R itself, packages, and the project library, instead of splitting that across
  `r-lib/actions/setup-r`, a pinned Docker base image, and rv.
* Good, because uvr's native `[dev-dependencies]` section fixes a gap rv had for this template's whole
  lifetime (ADR-003's own Consequences section already flagged this).
* Good, because the devcontainer no longer depends on an R-specific base image (`rocker/r-ver`) — any slim
  Linux base plus `uvr r install` works, verified locally.
* Bad, because uvr is younger and smaller than rv (single maintainer vs. A2-ai) — a step down in maturity
  along that axis even as it's a step up in feature completeness.
* Gotcha found during migration, not a blocker: `uvr init` also injects **machine-specific absolute paths**
  into `.vscode/settings.json` (e.g. `positron.r.customRootFolders`, hardcoded to the initializing machine's
  home directory) — reverted before committing; don't blindly commit whatever `uvr init` touches in
  `.vscode/`.

## Confirmation

`uvr.toml`, `uvr.lock`, and `.r-version` are committed; `rproject.toml`/`rv.lock` and the old `rv/`
scripts directory (`rv/scripts/{rvr,activate}.R`, `rv/.gitignore`) are removed. `.uvr/library/` is gitignored
(mirroring how `rv/library/` was). `just install`/`just update` wrap `uvr r install`+`uvr sync`/`uvr update`.
Both CI workflows install `uvr` and run `uvr sync --frozen`. The devcontainer `Dockerfile` installs R via
`uvr r install` on a slim Debian base (symlinking the pinned R into `/usr/local/bin/R` so
`devcontainer.json`'s existing IDE path settings keep working unchanged); `postCreateCommand` runs `uvr sync`.
`release-please-config.json`'s `extra-files` list points at `uvr.toml` instead of `rproject.toml`.

## Links

| Type | Links |
| -----| ------|
| **ADRs**   | [ADR-003](003-manage-r-dependencies-with-rv.md) (superseded by this) |
| **Issues** | [nbafrank/uvr#116](https://github.com/nbafrank/uvr/pull/116) (merged) |
| **PRs**    | |
