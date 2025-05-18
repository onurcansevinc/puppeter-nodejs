FROM        --platform=$TARGETOS/$TARGETARCH node:21-bookworm-slim

LABEL       author="Onurcan Sevinc" maintainer="me@onurcansevinc.com"
LABEL       org.opencontainers.image.source="https://github.com/onurcansevinc/puppeter-nodejs"
LABEL       org.opencontainers.image.description="Node.js 21 Docker image for Pterodactyl"
LABEL       org.opencontainers.image.licenses="MIT"

RUN         apt update \
            && apt -y install \ 
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
            tini \
            libatk1.0-0 \
            && useradd -m -d /home/container container

RUN         npm install --global npm@10.x.x typescript ts-node @types/node

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ./../entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]