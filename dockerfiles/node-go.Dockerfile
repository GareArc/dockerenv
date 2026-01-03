FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get clean && apt-get update && apt-getinstall -y --no-install-recommends \
    build-essential \
    curl \
    git \
    ca-certificates \
    bison \
    bsdmainutils \
    locales \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install nvm
ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install --lts \
    && nvm alias default node

# Install gvm
RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)"
RUN bash -c "source /root/.gvm/scripts/gvm && gvm install go1.22.0 -B && gvm use go1.22.0 --default"

# Install Claude Code
RUN . "$NVM_DIR/nvm.sh" && npm install -g @anthropic-ai/claude-code

# Setup shell
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc \
    && echo '[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"' >> ~/.bashrc

WORKDIR /app
CMD ["/bin/bash"]
