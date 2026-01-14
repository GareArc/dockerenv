FROM dockerenv-opencode-base:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    bison \
    bsdmainutils \
    && rm -rf /var/lib/apt/lists/*

ENV NVM_DIR=/root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install --lts \
    && nvm alias default node

RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)"
RUN bash -c "source /root/.gvm/scripts/gvm && gvm install go1.22.0 -B && gvm use go1.22.0 --default"

RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc \
    && echo '[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"' >> ~/.bashrc

WORKDIR /app
CMD ["/bin/bash"]
