FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta

RUN apt-get update -y && apt-get install -y \
    curl wget git unzip zip tar \
    ca-certificates gnupg dirmngr lsb-release \
    build-essential \
    software-properties-common \
    jq nano vim htop \
    sqlite3 \
    ffmpeg \
    openssh-client \
    cron \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p $NVM_DIR && \
    curl --retry 3 --retry-delay 2 -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
RUN . $NVM_DIR/nvm.sh && \
    nvm install 18 && \
    nvm install 20 && \
    nvm install 22 && \
    nvm alias default 22 && \
    npm install -g pnpm yarn bun && \
    ln -s "$NVM_DIR/versions/node/$(nvm version default)" /usr/local/node-current
ENV PATH="/usr/local/node-current/bin:$PATH"

RUN for i in 1 2 3 4 5; do add-apt-repository -y ppa:deadsnakes/ppa && break || sleep 5; done && \
    apt-get update -y && \
    apt-get install -y \
      python3.11 python3.11-venv \
      python3.12 python3.12-venv \
      python3.13 python3.13-venv \
      python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN for i in 1 2 3 4 5; do add-apt-repository -y ppa:ondrej/php && break || sleep 5; done && \
    apt-get update -y && \
    for v in 8.1 8.2 8.3 8.4; do \
      apt-get install -y \
        php$v php$v-cli php$v-fpm php$v-common \
        php$v-mysql php$v-pgsql php$v-sqlite3 \
        php$v-curl php$v-gd php$v-mbstring \
        php$v-xml php$v-zip php$v-bcmath php$v-intl; \
    done && \
    apt-get install -y composer && \
    rm -rf /var/lib/apt/lists/*
RUN update-alternatives --install /usr/bin/php php /usr/bin/php8.1 81 && \
    update-alternatives --install /usr/bin/php php /usr/bin/php8.2 82 && \
    update-alternatives --install /usr/bin/php php /usr/bin/php8.3 83 && \
    update-alternatives --install /usr/bin/php php /usr/bin/php8.4 84 && \
    update-alternatives --set php /usr/bin/php8.3

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 1

RUN apt-get update -y && apt-get install -y \
    libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 \
    libcups2 libdrm2 libxkbcommon0 libxcomposite1 \
    libxdamage1 libxfixes3 libxrandr2 libgbm1 libasound2t64 \
    libpango-1.0-0 libcairo2 fonts-liberation \
    libx11-6 libxext6 libxcb1 libxrender1 libxi6 \
    libgtk-3-0 libvulkan1 \
    xvfb x11-utils xauth \
    libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 \
    libwoff1 libopus0 libwebpdemux2 libharfbuzz-icu0 \
    libenchant-2-2 libsecret-1-0 libhyphen0 libmanette-0.2-0 \
    libgles2 libx264-dev \
    fonts-noto fonts-noto-color-emoji fonts-noto-cjk fonts-dejavu-core \
    locales tzdata \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TZ=Asia/Jakarta

ENV PLAYWRIGHT_BROWSERS_PATH=/opt/browsers
RUN pip install --break-system-packages playwright && \
    python3 -m playwright install chromium firefox webkit --with-deps

RUN . $NVM_DIR/nvm.sh && \
    npm install -g playwright puppeteer puppeteer-real-browser puppeteer-extra puppeteer-extra-plugin-stealth pm2 && \
    npx --yes playwright install chromium firefox webkit --with-deps
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

RUN ARCH=$(dpkg --print-architecture) && \
    curl --retry 3 --retry-delay 2 -Lo /usr/local/bin/ttyd "https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.${ARCH}" && \
    chmod +x /usr/local/bin/ttyd


RUN ARCH=$(dpkg --print-architecture) && \
    curl --retry 3 --retry-delay 2 -Lo /usr/local/bin/cloudflared "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${ARCH}" && \
    chmod +x /usr/local/bin/cloudflared

WORKDIR /home/container
ENV HOME=/home/container
ENV USER=container
RUN echo '' >> /etc/bash.bashrc && \
    echo 'if [ -n "$CODEX_PS1" ]; then' >> /etc/bash.bashrc && \
    echo '  PS1="$CODEX_PS1"' >> /etc/bash.bashrc && \
    echo 'fi' >> /etc/bash.bashrc

COPY entrypoint.sh /entrypoint.sh
COPY scripts/ /scripts/
RUN chmod +x /entrypoint.sh /scripts/*.sh

CMD ["/bin/bash", "/entrypoint.sh"]
