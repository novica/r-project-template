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

# Build docs (box's own doc parser generates .Rd, rd2qmd converts, Quarto renders the docs/ website)
docs-build:
    Rscript scripts/gen-rd.R
    rm -rf docs/reference && mkdir -p docs/reference
    rd2qmd man/ -f md -o docs/reference/
    rm -rf man
    # Home page includes README minus its badges block (GitHub-only, not relevant on the docs site)
    sed '/<!-- badges: start -->/,/<!-- badges: end -->/d' README.md > docs/_readme.md
    quarto render docs/

# Install pre-commit hooks (via prek)
pre-commit-install:
    prek install \
    && prek install -t pre-push \
    && prek install --hook-type commit-msg

# Run all pre-commit hooks (via prek)
pre-commit:
    prek run --all-files --hook-stage pre-push
