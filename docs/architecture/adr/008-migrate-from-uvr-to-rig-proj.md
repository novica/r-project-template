---
tags:
  - packaging
---

# ADR-008: Migrate R dependency management from uvr to rig proj
| | |
| ---| ---|
| **Status** |  🟡 Proposed |
| **Created**  | 2026-10-08 |
| **Last Updated**  | 2026-10-11 |
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
| Pin R version | `.r-version` | `[tool.rig] r-versions = ["4.6.1"]` in `rproj.toml` (exact patch; `sync` won't substitute another 4.6.x) |
| Project library in plain R sessions | `# >>> uvr >>>` block in `.Rprofile` → `.uvr/library` | `.Renviron` block + `.rvenvlib/rvenv` shim → `.rvenv/lib` |
| Run a script | `uvr run script.R` | `rig run script.R` (locks and syncs as needed) |
| CI install from lock only | `uvr sync --frozen` | `rig proj sync --frozen --no-install-r` |

rig proj also brings features uvr does not cover here:

* A cross-platform lockfile: by default it solves for `aarch64-apple-darwin`, `x86_64-w64-mingw32`, glibc
  Linux (`x86_64-unknown-linux-gnu`) and `source` in one `rproj.lock`. Other platforms fall back to `source`;
  `platforms = [...]` or `rig proj lock --add-platform` adds binary targets (e.g. ARM Linux).
* A shared `tools` library on every project's library path. It is not in `rproj.lock`, so this template keeps
  its tooling in `[dependency-groups.dev]` instead.
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
* Good, because inline script dependencies fit this template's `scripts/` usage.
* Bad, because `rig proj` is experimental: the manifest, lockfile, or CLI may change, forcing follow-up migrations.
* Bad, because migration touches `justfile`, `ci.yml`, `generate-docs.yml`, the devcontainer `Dockerfile` and
  `postCreateCommand`, `.gitignore`, `.Rprofile`, `release-please-config.json` (`extra-files` → `rproj.toml`),
  `CLAUDE.md` and README.
* Risk: `R --vanilla` ignores `.Renviron`, so such sessions won't see the project library. This is the same as
  uvr's `.Rprofile` approach today, so it is no regression.
* Risk: rig's `.Renviron` block sets `R_LIBS_USER` and replaces `R_DEFAULT_PACKAGES` to load its `rvenv`
  package. Projects created from the template that already use `.Renviron` must keep their own settings outside
  the block and must not set those two variables after it.
* Risk: rig installed as a distro package defaults to admin mode, and `rig proj add`/`sync` then call `sudo`.
  Non-root users must set `RIG_MODE=user`. The devcontainer runs as root, so admin mode needs no sudo there.
* Risk: on distros the r-hub version API doesn't know (seen on Arch: 404 on
  `rversions/resolve/release/linux-arch-/x86_64`), `rig proj init` fails without `--r-version`. With the R version
  pinned in `rproj.toml`, locking works and uses generic glibc Linux binaries.
* Note: on Linux, rig's two modes install different R builds, both from Posit's
  [r-builds](https://github.com/rstudio/r-builds). User mode always installs a portable build (glibc >= 2.34,
  into the home directory). This is the same build uvr installs, so it is no new dependency. Admin mode installs
  a distro-specific build into `/opt/R`, and falls back to the portable build (also into `/opt/R`) for distros
  Posit has retired. Debian 12 is retired: R 4.6.0 is its last distro-specific build, so admin mode installs the
  portable 4.6.1 there. During the trial this fallback failed with a 403, because the R versions API returned a
  broken `.deb` link for retired distros instead of a 404; that was fixed upstream on 2026-10-11. The
  devcontainer uses `debian:trixie-slim` (Debian 13), the current Debian stable release, which still gets the
  distro-specific build.
* Note: some distros ship rig as `r-rig` (e.g. Arch), because `rig` is already taken by the Random Identity
  Generator. Upstream installs call it `rig`, so the `justfile` and CI use `rig`.
* Note: R started from a subdirectory doesn't read the project's `.Renviron`, so it doesn't see the project
  library. uvr's `.Rprofile` block has the same limitation, so this is no regression.
* Note: neither `rig proj sync --frozen` nor `rig proj status` compares `rproj.lock` with `rproj.toml`. A
  stale lock is caught by `rig proj lock && git diff --exit-code rproj.lock`: with the manifest unchanged the
  re-lock is byte-identical. CI must not rely on `rig run`, which re-locks silently.

## Confirmation

Trial on a branch, on a Linux machine, before accepting. Each check must pass. Results from a trial on
2026-10-11 (rig 0.11.0, Arch Linux, user mode, on a copy of the repo) are marked ✅ (passed) or ⬜ (not yet
run):

1. ✅ `rig` installs on Linux without root (user mode) via a script suitable for CI and the devcontainer.
   Locally, `rig add 4.6.1 --user` installed R under `~/.local/share/rig` without sudo. In the devcontainer,
   the release tarball (`rig-linux-x86_64-latest.tar.gz` extracted into `/usr/local`) plus `rig add` works.
2. ✅ `rig proj init` + `rig proj add box dplyr` + `rig proj add --dev languageserver roxygen2 testthat` reproduce
   the current `uvr.toml`; `rig proj lock` writes a lock covering Linux, macOS and Windows.
3. ✅ `rig proj sync` installs the pinned R (4.6.1) and the packages into `.rvenv/lib`.
4. ✅ Plain `Rscript` from the repo root sees the project library (the `box::use()` check ADR-006 used), and
   `rig run scripts/run-tests.R` passes the test suite.
5. ✅ `just docs-build` works unchanged apart from the runner.
6. ✅ CI can fail on a stale `rproj.lock`: `rig proj lock && git diff --exit-code rproj.lock`, then
   `rig proj sync --frozen --no-install-r`.
7. ✅ The devcontainer builds with rig instead of uvr, and IDE paths keep working. Tested with podman on
   `debian:trixie-slim` in admin mode (the base image the devcontainer now uses): `rig proj sync`, all
   pre-commit hooks, `rig run scripts/run-tests.R` and `languageserver` through `/usr/local/bin/R` pass. On
   `debian:bookworm-slim`, user mode passed the same checks plus `just docs-build`, and admin mode installs the
   portable R build into `/opt/R` with the `/usr/local/bin/R` symlink (after the upstream API fix).
8. ⬜ Windows: `rig proj sync` and `rig run` work for local development.

If accepted: replace `uvr.toml`/`uvr.lock`/`.r-version` with `rproj.toml`/`rproj.lock`, remove the uvr
`.Rprofile` block, gitignore `.rvenv/`, update the files listed under Consequences, and mark ADR-006
🔵 Superseded by ADR-008.

## Links

| Type | Links |
| -----| ------|
| **ADRs**   | [ADR-006](006-migrate-from-rv-to-uvr.md) (would be superseded by this) |
| **Docs**   | [rig proj reference](https://rig.r-lib.org/reference/proj.html) |
| **Issues** | [#43](https://github.com/novica/r-project-template/issues/43) |
| **PRs**    | |
