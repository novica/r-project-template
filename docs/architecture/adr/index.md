# Architectural Decision Records

| ADR | Status | Summary |
|-----|---------|----------|
| [ADR-001: Use Architecture Decision Records](001-use-architectural-decision-records.md) | 🟢 Accepted | Use ADRs to explain the rationale behind architecturally significant design choices for future developers and AI assistants |
| [ADR-002: Use prek for git hooks](002-use-prek-for-git-hooks.md) | 🟢 Accepted | Use prek, a dependency-free Rust binary, to run Git hooks with no Python/uv requirement |
| [ADR-003: Manage R dependencies with rv](003-manage-r-dependencies-with-rv.md) | 🔵 Superseded by ADR-006 | Use rv, not renv/packrat, for declarative R dependency management |
| [ADR-004: Unify docs into a single Quarto website](004-unify-docs-into-single-quarto-website.md) | 🟢 Accepted | Combine README, architecture/ADR markdown, and a generated API reference into one Quarto website |
| [ADR-005: Generate API reference with box + rd2qmd instead of quartify](005-generate-api-reference-with-box-and-rd2qmd.md) | 🟢 Accepted | Use box's own internal doc parser + rd2qmd for the API reference, replacing quartify |
| [ADR-006: Migrate R dependency management from rv to uvr](006-migrate-from-rv-to-uvr.md) | 🟢 Accepted | Use uvr, which also installs R itself and supports dev-dependencies, replacing rv |
