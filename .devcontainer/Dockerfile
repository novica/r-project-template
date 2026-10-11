FROM debian:trixie-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    curl \
    wget \
    gdebi-core \
    ca-certificates \
    apt-transport-https \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Quarto CLI (downloads latest .deb from quarto.org)
RUN wget -O /tmp/quarto.deb https://quarto.org/download/latest/quarto-linux-amd64.deb \
    && apt-get update \
    && apt-get install -y /tmp/quarto.deb \
    && rm -f /tmp/quarto.deb \
    && rm -rf /var/lib/apt/lists/*

# Install rig, then R itself (the version rproj.lock names) under /opt/R, linked to /usr/local/bin/R
# Project packages are synced by postCreateCommand once the repo is mounted (see devcontainer.json)
COPY rproj.lock .
RUN curl -fsSL https://github.com/r-lib/rig/releases/download/latest/rig-linux-x86_64-latest.tar.gz \
    | tar xz -C /usr/local \
    && rig add "$(sed -n 's/^r_version = "\(.*\)"/\1/p' rproj.lock | head -1)" \
    && rm rproj.lock

# Install air
RUN curl -LsSf https://github.com/posit-dev/air/releases/latest/download/air-installer.sh | sh

# Install jarl
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/etiennebacher/jarl/releases/latest/download/jarl-installer.sh | sh

# Install ry (static type/scope checker)
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/sims1253/ry/releases/latest/download/ry-cli-installer.sh | sh

# Install prek (Rust-based pre-commit hook runner)
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/j178/prek/releases/latest/download/prek-installer.sh | sh

# Install rd2qmd (Rd to Quarto Markdown converter, used by docs-build)
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/eitsupi/rd2qmd/releases/latest/download/rd2qmd-installer.sh | sh

# Install just
RUN curl -fsSL https://just.systems/install.sh | bash -s -- --to /usr/local/bin

CMD [ "bash" ]
