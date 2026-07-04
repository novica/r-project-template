# -----------------------------------------------------------------------------
# R Project Template — Justfile
# -----------------------------------------------------------------------------
# Common developer commands for rv-based projects.
# Run `just <command>` (e.g., `just test`).
# -----------------------------------------------------------------------------

# Always use bash for consistency across OSes
set shell := ["bash", "-cu"]

# Default recipe (shown when running plain `just`)
default:
    @just --list

# Install dependencies (create/update virtualenv)
install:
    rv sync

# Upgrade packages to the latest versions available
update:
    rv upgrade

# Lint (Jarl check)
lint:
    jarl check .

# Format (Air format)
format:
    r-air format --check .

# Run testthat
test:
    Rscript -e "testthat::test_dir('src/package_name/__tests__')"

# Build docs (Quartify generates reference qmd, Quarto renders the docs/ website)
docs-build:
    Rscript -e "quartify::rtoqmd_dir('src/package_name/', create_book = FALSE, render_html = FALSE, exclude_pattern = '__tests__')"
    rm -rf docs/reference && mkdir -p docs/reference
    # __init__.r is just re-export wiring (box::use(...)), not a documented module — drop its qmd
    rm -f src/package_name/__init__.qmd
    for f in src/package_name/*.qmd; do mv "$f" "docs/reference/$(basename "$f" | sed 's/^_*//')"; done
    # Home page includes README minus its badges block (GitHub-only, not relevant on the docs site)
    sed '/<!-- badges: start -->/,/<!-- badges: end -->/d' README.md > docs/_readme.md
    # docs/ isn't the repo root, so its rendered R chunks (e.g. reference/hello.qmd) won't see
    # .Rprofile's rv activation — point R_LIBS_USER at rv's library directly instead.
    R_LIBS_USER="$(pwd)/$(rv info --library | sed 's/^library: //')" quarto render docs/

# Install pre-commit hooks (via prek)
pre-commit-install:
    prek install \
    && prek install -t pre-push \
    && prek install --hook-type commit-msg

# Run all pre-commit hooks (via prek)
pre-commit:
    prek run --all-files --hook-stage pre-push
