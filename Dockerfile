FROM        --platform=$TARGETOS/$TARGETARCH node:21-bookworm-slim

LABEL       author="Onurcan Sevinc" maintainer="me@onurcansevinc.com"
LABEL       org.opencontainers.image.source="https://github.com/onurcansevinc/puppeter-nodejs"
LABEL       org.opencontainers.image.description="Node.js 21 Docker image for Pterodactyl"
LABEL       org.opencontainers.image.licenses="MIT"
LABEL       org.opencontainers.image.public="true"

# Install latest chrome dev package and fonts to support major charsets
RUN         apt update \
            && apt install -y wget gnupg \
            && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
            && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
            && apt update \
            && apt install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
            && apt install -y ffmpeg iproute2 git sqlite3 libsqlite3-dev python3 python3-dev ca-certificates dnsutils tzdata zip tar curl build-essential libtool iputils-ping libnss3 tini libatk1.0-0 \
            && rm -rf /var/lib/apt/lists/* \
            && useradd -m -d /home/container container

# Install Node.js packages
RUN         npm install --global npm@10.x.x typescript ts-node @types/node

# Install pnpm
RUN         npm install -g pnpm@latest

# Create app directory
WORKDIR     /app

# Initialize npm project
RUN         npm init -y

# Install Puppeteer
RUN         npm install puppeteer

# Setup Puppeteer user
RUN         groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
            && mkdir -p /home/pptruser/Downloads \
            && chown -R pptruser:pptruser /home/pptruser \
            && chown -R pptruser:pptruser /app

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        --chown=container:container ./../entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]