FROM rocker/r-ver:4.5.0

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

# Install rv and sync project packages (prefer using rv to manage packages)
RUN curl -sSL https://raw.githubusercontent.com/A2-ai/rv/refs/heads/main/scripts/install.sh | sh \
    && if command -v rv >/dev/null 2>&1; then \
    rv syncs || true; \
    else \
    echo "rv install script did not put 'rv' on PATH; skipping rv sync"; \
    fi

# Install air
RUN curl -LsSf https://github.com/posit-dev/air/releases/latest/download/air-installer.sh | sh

# Install jarl
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/etiennebacher/jarl/releases/latest/download/jarl-installer.sh | sh


WORKDIR /workspace

CMD ["/bin/bash"]
