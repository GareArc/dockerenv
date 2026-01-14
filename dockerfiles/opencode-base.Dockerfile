FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get clean && apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    ca-certificates \
    locales \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create directories for OpenCode mounts
# These will be populated by volume mounts at runtime
RUN mkdir -p /root/.opencode/bin \
    && mkdir -p /root/.config/opencode \
    && mkdir -p /root/.local/share/opencode \
    && mkdir -p /root/.cache/opencode \
    && mkdir -p /root/.cache/oh-my-opencode \
    && mkdir -p /root/.local/state/opencode

# Add OpenCode binary to PATH
ENV PATH="/root/.opencode/bin:${PATH}"

WORKDIR /app
CMD ["/bin/bash"]
