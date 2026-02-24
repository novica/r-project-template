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

# Build docs (Quartrify)
docs-build:
     Rscript -e "quartify::rtoqmd_dir('src/package_name/', render = TRUE,  output_html_dir = '../../docs/html', exclude_pattern='__tests__')"
