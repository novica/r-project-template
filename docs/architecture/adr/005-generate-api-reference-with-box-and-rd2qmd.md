---
tags:
  - docs
---

# ADR-005: Generate API reference with box + rd2qmd instead of quartify
| | |
| ---| ---|
| **Status** |  🟢 Accepted |
| **Created**  | 2026-07-04 |
| **Last Updated**  | 2026-07-04 |
| **Deciders** | Novica Nakov |

---

## Context

[ADR-004](004-unify-docs-into-single-quarto-website.md) used `quartify::rtoqmd_dir()` to convert roxygen
comments into the API reference pages under `docs/reference/`. Investigating an alternative surfaced that
`box` — already this template's module system — has its own internal roxygen-parsing pipeline
(`box:::parse_documentation()`), the same one that powers `box::help()`. It correctly produces standard `.Rd`
documentation (including box's `.__module__.` module-level doc convention, which plain `roxygen2::roc_proc_text()`
can't resolve on its own), without quartify's book-mode side effect of writing `_quarto.yml` into
`src/package_name/`. `.Rd` is also the format [rd2qmd](https://github.com/eitsupi/rd2qmd) — a fast, standalone
Rd-to-Quarto-Markdown converter — expects as input.

## Problem Statement

Should this template keep generating its API reference with quartify, or switch to box's own doc-parsing
pipeline plus rd2qmd?

## Options Considered

|  Option  | Description | Doc quality | No source-tree side effects | Execution model fits (no package) | Maintained tooling | Overall score | Notes |
|----------|-------------|-------------|-----------------|-------------| ----- | ------|------|
| **Weight**      | - | 1 | 2 | 2 | 1 | - | - |
| **quartify (status quo)** | Converts roxygen comments to `.qmd` directly, one page per source file. | ⚠️ | ❌ | ✅ | ⚠️ | 12 | Book-mode default writes `_quarto.yml` into `src/package_name/`; required `create_book = FALSE` workaround. Freeform HTML-callout layout, no structured arguments table. |
| **box + rd2qmd** | `box:::parse_documentation()` (box's own internal doc engine) generates `.Rd`; `rd2qmd -f md` converts to plain, non-executable `.md`, one page per documented topic. | ✅ | ✅ | ✅ | ⚠️ | 20 | Chosen. Rd is a mature, structured format (real Arguments table, standard aliases); no source-tree side effects; `-f md` avoids any package-installed assumption. Relies on unexported `box:::parse_documentation()` — see Consequences. |
| **rd2qmd's default `-f qmd` (executable examples)** | Same as above but with executable `{r}` example chunks (rd2qmd's default, pkgdown-style). | ✅ | ✅ | ❌ | ⚠️ | 16 | Rejected: assumes an installed package (`library(pkg)` in scope) so examples can call the documented functions; this template is never a package. Would need a generated per-file `box::use()` setup chunk to work at all — unnecessary complexity `-f md` avoids entirely. |
| **Hand-write reference pages** | Drop generation, write `docs/reference/*.md` by hand. | ⚠️ | ✅ | ✅ | ✅ | 15 | No tooling dependency, but docs drift from source immediately; defeats the purpose of roxygen comments in the source. |

✅ = 3 (good), ⚠️ = 2 (acceptable), ❌ = 1 (poor)

## Decision Outcome

We will generate the API reference with `box:::parse_documentation()` + `rd2qmd -f md`. `scripts/gen-rd.R`
replicates the one piece of setup `box::use()` normally does internal to module loading — binding
`.__module__.` in the namespace before sourcing (see `box::make_namespace()`) — then calls
`parse_documentation()` per module and writes the resulting Rd text to `man/`. `rd2qmd -f md` converts that to
`docs/reference/*.md`, one page per documented topic (module doc + each exported function), which
`docs/_quarto.yml`'s sidebar lists individually. `-f md` produces plain, non-executable code fences —
deliberately matching quartify's own `execute: eval: false` behavior, since this template is never an
installed package and there is nothing for a `library(pkg)`-style example to call.

## Consequences

* Good, because Rd is a mature, structured format — reference pages get a real Arguments table and standard
  aliases, better than quartify's freeform HTML-callout layout.
* Good, because nothing is written into `src/package_name/` during generation — no book-mode side effects to
  work around.
* Good, because rd2qmd produces one page per documented topic (pkgdown/CRAN convention) rather than one page
  per source file, which reads better as the module count grows.
* Bad, because `box:::parse_documentation()` is unexported — `scripts/gen-rd.R` depends on box internals that
  could change without notice in a future box release. A matching exported function (`box::mod_rd()`) has been
  drafted to propose upstream; until/unless that lands, this is a known fragility, not a blocker.
* Bad, because `docs/_quarto.yml`'s "API Reference" sidebar section needs one manual entry per documented
  topic (not just per module) — slightly more entries to maintain than ADR-004's one-per-file quartify setup.
* Confirmed by testing: rd2qmd's default `-f qmd` output (executable examples) fails at render time with
  `could not find function "say_hello"` — there's no installed package providing it. `-f md` avoids this
  entirely rather than working around it with a generated setup chunk.

## Confirmation

`quartify` is removed from `rproject.toml`'s dependencies (was only used for this). `rd2qmd` is installed
alongside `air`/`jarl`/`prek` (standalone Rust binary, `.devcontainer/Dockerfile` and CI both install it via
its release installer script). `justfile`'s `docs-build` recipe and `.github/workflows/generate-docs.yml` both
run `Rscript scripts/gen-rd.R` then `rd2qmd man/ -f md -o docs/reference/`.

## Links

| Type | Links |
| -----| ------|
| **ADRs**   | [ADR-004](004-unify-docs-into-single-quarto-website.md) |
| **Issues** | |
| **PRs**    | |
