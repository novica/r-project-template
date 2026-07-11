# R project template

<!-- badges: start -->
[![CI](https://github.com/novica/r-project-template/actions/workflows/ci.yml/badge.svg)](https://github.com/novica/r-project-template/actions/workflows/ci.yml)
[![release](https://github.com/novica/r-project-template/actions/workflows/release-please.yml/badge.svg)](https://github.com/novica/r-project-template/actions/workflows/release-please.yml)
[![docs](https://github.com/novica/r-project-template/actions/workflows/generate-docs.yml/badge.svg)](https://github.com/novica/r-project-template/actions/workflows/generate-docs.yml)
[![Dependabot](https://img.shields.io/github/issues-search?query=repo%3Anovica%2Fr-project-template%20is%3Apr%20author%3Aapp%2Fdependabot%20is%3Aopen&label=Dependabot%20PRs)](https://github.com/novica/r-project-template/issues?q=is%3Apr%20is%3Aopen%20author%3Aapp%2Fdependabot)
[![air](https://img.shields.io/badge/-air-000000?logo=r&logoColor=white&labelColor=276DC3)](https://github.com/posit-dev/air/)
[![box](https://img.shields.io/badge/-box-000000?logo=r&logoColor=white&labelColor=276DC3)](https://github.com/klmr/box)
[![jarl](https://img.shields.io/badge/-jarl-000000?logo=r&logoColor=white&labelColor=276DC3)](https://github.com/etiennebacher/jarl/)
[![uvr](https://img.shields.io/badge/-uvr-000000?logo=r&logoColor=white&labelColor=276DC3)](https://github.com/nbafrank/uvr)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
<!-- badges: end -->

This is an attempt to make an R project template, that is not an R package, and that uses some of the recent tools that have been created in the R ecosystem. The template is inspired by the [python-project-template](https://github.com/gemmadanks/python-project-template/) by Gemma Danks.

The project features uvr for project/package management and R version installation, jarl for linting, and air for formatting, justfile, testthat testing, a Quarto documentation site, .editorconfig, .devcontainer, GitHub Actions CI, and automated semantic releases.

While the template can help you start writing code immediately without having to spend time deciding what tools or conventions to use, the tools and conventions that it introduces are not the *default*
way of doing things in the R world, and there is a question mark if they get adopted in the future or not.

## How to use this template

1. 🌱 Create a New Repository on GitHub
    1. Click **["Use this template"](https://github.com/novica/r-project-template/generate)**.
    1. Choose “Create a new repository”.
    1. Pick a name for your new project (for example, `my-awesome-package`).
    1. Clone your new repo locally
1. 🏡 Customise the repository
    1. Rename your package directory `cd src; mv package_name my_package`
    1. Update [uvr.toml](https://github.com/novica/r-project-template/blob/main/uvr.toml) with your package name, author, and description, and preferred repository.
    1. Update all references to package_name in:
        - [src/package_name/\_\_tests\_\_/](https://github.com/novica/r-project-template/tree/main/src/package_name/__tests__)
        - [docs/](https://github.com/novica/r-project-template/tree/main/docs)
        - [release-please-config.json](https://github.com/novica/r-project-template/blob/main/release-please-config.json)
        - [GitHub Actions workflow](https://github.com/novica/r-project-template/blob/main/.github/workflows/ci.yml)
        - This README (including badge links)
    1. Update the `"package-name"` field in [release-please-config.json](https://github.com/novica/r-project-template/blob/main/release-please-config.json) with your package name for automatically bumping the version number in [uvr.toml](https://github.com/novica/r-project-template/blob/main/uvr.toml) (see [release-please issue #2561](https://github.com/googleapis/release-please/issues/2561)).
    1. Customise this README with a description of your project and planned features.
    1. Clear the CHANGELOG.
    1. Enable automated releases by permitting GitHub Actions to open PRs (Settings -> Actions -> Workflow permissions) and add an initial commit hash to bootstrap the release-please in [.release-please-manifest.json](https://github.com/novica/r-project-template/blob/main/.release-please-manifest.json).
    1. Enable publishing to GitHub Pages (Settings -> Pages).

## 🚀 Features

- Modular project directory structure using [box](https://klmr.me/box/articles/box.html).
- README template with badges.
- Packaging, dependency management, and R version installation via [uvr](https://github.com/nbafrank/uvr): [uvr.toml](https://github.com/novica/r-project-template/blob/main/uvr.toml).
- Linting via [Jarl](https://jarl.etiennebacher.com/).
- Formatting via [Air](https://posit-dev.github.io/air/).
- Testing framework using [testthat](https://testthat.r-lib.org/).
- [Git hooks](https://github.com/novica/r-project-template/blob/main/.pre-commit-config.yaml) via [prek](https://prek.j178.dev/) (linting and formatting).
- CI using [GitHub Actions](https://docs.github.com/en/actions): [.github/workflows/ci.yml](https://github.com/novica/r-project-template/blob/main/.github/workflows/ci.yml).
- Docs generated with [box](https://klmr.me/box/)'s own roxygen parser + [rd2qmd](https://github.com/eitsupi/rd2qmd) and rendered as a single [Quarto](https://quarto.org/) website, deployed to GitHub Pages via GitHub action: [.github/workflows/generate-docs.yml](https://github.com/novica/r-project-template/blob/main/.github/workflows/generate-docs.yml).
- Templates for GitHub issues: bug report ([01-bug.yml](https://github.com/novica/r-project-template/blob/main/.github/ISSUE_TEMPLATE/01-bug.yml)) and feature request ([02-feature.yml](https://github.com/novica/r-project-template/blob/main/.github/ISSUE_TEMPLATE/02-feature.yml)).
- Template for GitHub pull request: [.github/pull_request_template.md](https://github.com/novica/r-project-template/blob/main/.github/pull_request_template.md).
- Template for [documenting architectural decisions](https://adr.github.io/): [docs/architecture/adr/template.md](https://github.com/novica/r-project-template/blob/main/docs/architecture/adr/template.md).
  - ADR to explain the rationale for using ADRs: [docs/architecture/adr/001-use-architectural-decision-records.md](https://github.com/novica/r-project-template/blob/main/docs/architecture/adr/001-use-architectural-decision-records.md).
- Release automation via GitHub action from [release-please](https://github.com/googleapis/release-please): [release-please-config.json](https://github.com/novica/r-project-template/blob/main/release-please-config.json).
- Citation metadata, automatically updated for each new release: [CITATION.cff](https://github.com/novica/r-project-template/blob/main/CITATION.cff).
- [EditorConfig](https://editorconfig.org/) configuration for consistent coding style across editors: [.editorconfig](https://github.com/novica/r-project-template/blob/main/.editorconfig).

## ‼️ Limitations

- Test coverage cannot be registered with codecov because it seems the R package `covr` does not work in this type of project structure.
- `pkgdown` cannot be used for documentation for the same reason as above.
- `devtools::check()` does not work because it expects a package structure with a `DESCRIPTION` file and an `R/` directory for source code, which this template does not have.

## 📦 Installation

### Working in a development container

A [Dockerfile](https://github.com/novica/r-project-template/blob/main/.devcontainer/Dockerfile) and [configuration](https://github.com/novica/r-project-template/blob/main/.devcontainer/devcontainer.json) in [.devcontainer](https://github.com/novica/r-project-template/tree/main/.devcontainer) can be used in VSCode or GitHub Codespaces to work in a pre-configured development environment. It uses a minimal Debian base image and installs Quarto, uvr (which then installs R itself), air, jarl, prek, rd2qmd, and just.

To open the project in the container VSCode, you will need to add the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) and download [Docker](https://docs.docker.com/get-started/get-docker/) (or [Podman](https://podman.io/docs/installation) -- and [configure VSCode to use podman instead of Docker](https://code.visualstudio.com/remote/advancedcontainers/docker-options#_podman)) -- see the [VSCode tutorial on devcontainers](https://code.visualstudio.com/docs/devcontainers/tutorial) for more details on using devcontainers. Then run:

``` bash
Dev Containers: Reopen in Container
```

### Manual installation

1. [Install uvr](https://github.com/nbafrank/uvr)
1. optional, if you want to use shortcut commands, [install just](https://just.systems/)
1. optional, if you want to use pre-commit hooks, [install prek](https://prek.j178.dev/)
1. optional, if you want to build the docs site locally, [install Quarto](https://quarto.org/docs/get-started/) and [rd2qmd](https://github.com/eitsupi/rd2qmd)
1. Clone and install the project using uvr:

```bash
git clone https://github.com/novica/r-project-template
cd r-project-template
uvr r install $(cat .r-version)
uvr sync
```

1. Install pre-commit hooks (only needs to be done once): `just pre-commit-install`

## 🧪 Common Tasks

Several common tasks have been added as recipes to a [justfile](https://github.com/novica/r-project-template/blob/main/justfile) in the root of the repository:

```bash
    default             # Default recipe (shown when running plain `just`)
    install             # Install R (via uvr) and dependencies (uvr sync)
    update              # Upgrade packages to the latest versions available (uvr update)
    lint                # Lint (Jarl check)
    format              # Format (Air format)
    test                # Run testthat
    docs-build          # Build docs (box + rd2qmd generate reference md, Quarto renders the site)
    pre-commit-install  # Install git hooks (via prek)
    pre-commit          # Run all git hooks (via prek)
```

## 📚 Documentation

- Generated with box's own roxygen parser + [rd2qmd](https://github.com/eitsupi/rd2qmd) and rendered as a single [Quarto](https://quarto.org/) website (`just docs-build`), combining this README, the architecture/ADR docs, and the generated API reference. See [ADR-004](https://github.com/novica/r-project-template/blob/main/docs/architecture/adr/004-unify-docs-into-single-quarto-website.md).

## 🔄 Releases

Managed by release-please: ([conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) drive [semantic versioning](https://semver.org/) and an autogenerated CHANGELOG).
    - Configuration: [release-please-config.json](https://github.com/novica/r-project-template/blob/main/release-please-config.json)
    - Version source: uvr.toml

## 📂 Project Structure

```bash
.
├── src/
│   └── package_name/              # Source package
│       ├── __init__.r
│       └── hello.r                # Example module (replace with real code)
|       └── __tests__/             # Test suite for the example module
|          ├── __init__.r
|          ├── helper-module.r
|          └── test_hello.R
├── data-raw/                       # Raw data used in the project (if applicable)
├── docs/                           # Documentation site (Quarto website, see ADR-004)
│   ├── _quarto.yml                # Hand-authored Quarto website project
│   ├── index.qmd                  # Home page ({{< include _readme.md >}})
│   ├── architecture/               # Hand-written: architecture overview + ADRs
│   │   ├── index.md
│   │   └── adr/
│   ├── reference/                  # Generated by rd2qmd (gitignored, rebuilt by `just docs-build`)
│   └── html/                      # Rendered site output (gitignored; deployed to GitHub Pages)
├── notebooks/                     # Quarto notebooks
│   └── demo.qmd
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                # Lint / test / build
│   │   ├── generate-docs.yml     # Generate and deploy docs
│   │   ├── release-please.yml    # Automated releases
|   |   └── update-citaton-date-released.yml     # Update date-released in CITATION.cff on new release
├── .devcontainer/                 # Dev container configuration
│   ├── devcontainer.json
│   └── Dockerfile
├── uvr.toml                       # Project metadata + dependencies (uvr)
├── uvr.lock                       # Locked dependency versions (uvr)
├── .r-version                     # Pinned exact R version (uvr)
├── README.md                      # Project overview (you are here)
├── CITATION.cff                   # Citation metadata
├── LICENSE                        # License
├── NEWS.md                        # Generated by release-please (post-release)
├── .pre-commit-config.yaml         # Git hooks configuration (run via prek)
├── .release-please-manifest.json  # Release-please state
├── release-please-config.json     # Release-please configuration
├── justfile                       # justfile containing recipes for common tasks
├── .editorconfig                  # Ensures consistent code style across editors
└── .gitignore
```

Note that while it is common practice to keep the config files at the root of the
repository, and this is what I recommend, it is possible to customise the
location of some of them if you prefer
(e.g. the path to `release-please-config.json` [can be specified in the
release-please.yml file for the GitHub action]
(<https://github.com/googleapis/release-please-action?tab=readme-ov-file#advanced-release-configuration>).

## 🤝 Contributing

Use [conventional commit](https://www.conventionalcommits.org/) messages (feat:, fix:, docs:, etc.). Ensure:

- Lint & format clean
- Tests pass
- Docs build without warnings
- ADR drafted for architecturally significant changes

Suggestions and improvements to this template are very welcome — feel free to open an issue or pull request if you spot something that could be refined, added or removed.

## 📖 Citation

If used in research, cite via [CITATION.cff](https://github.com/novica/r-project-template/blob/main/CITATION.cff).

## 🛡 License

BSD-3-Clause – see [LICENSE](https://github.com/novica/r-project-template/blob/main/LICENSE).

Happy coding! 🚀
