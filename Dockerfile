FROM        --platform=$TARGETOS/$TARGETARCH node:21-bookworm-slim

LABEL       author="Onurcan Sevinc" maintainer="me@onurcansevinc.com"
LABEL       org.opencontainers.image.source="https://github.com/onurcansevinc/puppeter-nodejs"
LABEL       org.opencontainers.image.description="Discord WhatsApp Bot with Node.js 21"
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

# Copy package files first for better caching
COPY        package*.json ./

# Install dependencies
RUN         npm ci --only=production

# Copy application code
COPY        --chown=container:container . .

# Setup Puppeteer user
RUN         groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
            && mkdir -p /home/pptruser/Downloads \
            && chown -R pptruser:pptruser /home/pptruser \
            && chown -R container:container /app

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /app

# Set Chrome path environment variable
ENV         CHROME_PATH=/usr/bin/google-chrome-stable
ENV         NODE_ENV=production

# Create necessary directories
RUN         mkdir -p /app/whatsapp-auth /app/backups

ENTRYPOINT  ["/usr/bin/tini", "-g", "--"]
CMD         ["node", "bot.js"]
