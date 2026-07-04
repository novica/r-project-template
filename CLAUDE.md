# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

R project template (not an R package — no `DESCRIPTION`/`NAMESPACE`). Uses `box` modules instead of package
namespaces, `rv` for dependency management instead of `renv`/`packrat`, `air` for formatting, `jarl` for linting.
`src/package_name` is a placeholder directory name meant to be renamed per-project.

## Commands

Use `just <recipe>` (see `justfile`); run `just` alone to list recipes.

```bash
just install      # rv sync — installs R deps into rv/library
just update       # rv upgrade — bump deps to latest allowed versions
just lint          # jarl check .
just format        # r-air format --check .   (drop --check to auto-fix: r-air format .)
just test          # Rscript -e "testthat::test_dir('src/package_name/__tests__')"
just docs-build     # quartify generates docs/reference/*.qmd, then `quarto render docs/` builds docs/html
just pre-commit-install   # one-time: installs pre-commit + pre-push + commit-msg hooks via prek
just pre-commit           # prek run --all-files --hook-stage pre-push
```

Run a single test file directly: `Rscript -e "testthat::test_file('src/package_name/__tests__/test-hello.R')"`.

CI (`.github/workflows/ci.yml`) runs, in order: `air format --check .`, `jarl check .`, then the testthat suite.
Match that order locally before pushing.

## Architecture

**Module system (`box`), not an R package.** Code lives under `src/<pkg>/`. Each module file re-exports its
public API via `#' @export` roxygen tags and a trailing `box::export()` where needed. `__init__.r` at a
directory's root is the module's entry point and re-exports submodules with `box::use(. / submodule)`.
Import a sibling module with `box::use(. / hello)`; import a parent-relative module with `box::use(.. / hello[...])`.
There is no `library()`/`require()` for internal code — everything is `box::use()`.

**Tests live inside the source tree**, not in a separate top-level `tests/` dir: `src/<pkg>/__tests__/`.
- `__tests__/__init__.r` is itself a box module: on load it calls `testthat::test_dir(box::file())`, so the
  test directory can be run either via `testthat::test_dir()` directly or by `box::use()`-ing it as a module.
- `__tests__/helper-module.r` does `box::use(.. / hello[...])` to pull the parent module's exports into scope
  for the tests — add an equivalent `box::use()` line here when testing a new sibling module.
- New test files follow the `test-<module>.R` naming convention testthat expects.

**`docs/` is a single hand-authored Quarto website** (`docs/_quarto.yml`, see ADR-004) that combines the root
README (`docs/index.qmd` includes it via `{{< include ../README.md >}}`), the architecture/ADR markdown
(`docs/architecture/**`, rendered natively, edit directly), and a generated API reference. Only
`docs/reference/*.qmd` and `docs/html/` are generated/gitignored: `quartify::rtoqmd_dir()` converts roxygen
comments from `src/package_name/*.r` into `.qmd` (excluding `__tests__`), which `just docs-build` relocates
into `docs/reference/` before running `quarto render docs/` to produce `docs/html` (deployed to GitHub Pages
via `generate-docs.yml`). Don't hand-edit `docs/reference/*.qmd`/`docs/html` — edit the roxygen comments and
regenerate instead. Adding or removing a source module needs a matching entry added/removed in
`docs/_quarto.yml`'s sidebar (quartify's output isn't auto-discovered there).

**Architectural Decision Records live in `docs/architecture/adr/`** (see ADR-001). Any architecturally
significant change (new tool, new convention, reversing a prior decision) should get a new ADR — copy
`template.md`, number sequentially (`NNN-verb-object.md`), status `🟡 Proposed`. Check existing ADRs before
proposing changes that touch already-decided territory (e.g. `box` vs packages, `rv` vs `renv`/`packrat`).
Note: ADR-002 covers running Git hooks via `prek`, a dependency-free Rust binary — R dependency management is
a separate decision, `rv` not `renv`/`packrat` (see ADR-003). ADR-004 covers the `docs/` site structure.

**Only one package manager is in play**: `rv` (via `rproject.toml` / `rv.lock`) manages R dependencies. rv has
no concept of dev-only dependencies, so tooling deps (`languageserver`, `testthat`, `roxygen2`, `quartify`) are
listed directly in `rproject.toml`'s `dependencies` alongside runtime deps. Git hooks run via `prek`
(`.pre-commit-config.yaml`), a standalone binary — no Python/uv install required for hooks anymore.

**Releases** are automated via `release-please` (conventional commits → version bump in `rproject.toml`,
`NEWS.md`, `.release-please-manifest.json`). Commit messages must follow Conventional Commits
(enforced by a commit-msg pre-commit hook) — this directly drives versioning, not just changelog style.

**AI-assisted commits** use the `Assisted-by:` trailer, not `Co-Authored-By:`, following the Linux kernel's
guidance on coding-assistant attribution (https://docs.kernel.org/process/coding-assistants.html) — AI tools
must not add `Signed-off-by:`, only a human can certify the DCO.
