FROM        --platform=$TARGETOS/$TARGETARCH node:21-bookworm-slim

LABEL       author="Onur Can Sevinc" maintainer="me@onurcansevinc.com"
LABEL       org.opencontainers.image.description="Discord WhatsApp Bot with Chrome & Puppeteer"
LABEL       org.opencontainers.image.licenses="MIT"

# Add container user and stop signal
RUN useradd -m -d /home/container container
STOPSIGNAL SIGINT

# Install Chrome & dependencies
RUN apt update \
    && apt install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt update \
    && apt install -y \
        google-chrome-stable \
        ffmpeg \
        iproute2 \
        git \
        sqlite3 \
        libsqlite3-dev \
        python3 \
        python3-dev \
        ca-certificates \
        dnsutils \
        tzdata \
        zip \
        tar \
        curl \
        build-essential \
        libtool \
        iputils-ping \
        libnss3 \
        libatk1.0-0 \
        tini \
        fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
    && rm -rf /var/lib/apt/lists/*

# Global Node Tools
RUN npm install -g typescript ts-node @types/node

# pnpm
RUN npm install -g corepack
RUN corepack enable
RUN corepack prepare pnpm@latest --activate

# Switch to container user
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Copy and install app dependencies
COPY --chown=container:container package*.json ./
RUN npm install --production

# Copy application
COPY --chown=container:container . .

# Runtime directories
RUN mkdir -p /home/container/whatsapp-auth /home/container/backups

# Chrome path
ENV CHROME_PATH=/usr/bin/google-chrome-stable
ENV NODE_ENV=production

# Entry script
COPY --chown=container:container ./../entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
