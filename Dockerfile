FROM izone/arm:node-4

ENV GHOST_VERSION 0.11.10
ENV GHOST_SOURCE /usr/src/ghost
ENV GHOST_CONTENT /var/lib/ghost

WORKDIR $GHOST_SOURCE

RUN apk add --no-cache 'su-exec>=0.2' \
                bash \
                tar && \
    set -ex && \
    apk add --no-cache --virtual .build-deps \
            ca-certificates \
            gcc \
            make \
            openssl \
            python \
            unzip \
            g++ \
            curl \
            gnupg \
            libgcc \
    && \
    wget -O ghost.zip "https://github.com/TryGhost/Ghost/releases/download/${GHOST_VERSION}/Ghost-${GHOST_VERSION}.zip" && \
    unzip ghost.zip && \
    npm install --production && \
    apk del .build-deps && \
    rm ghost.zip && \
    npm cache clean && \
    rm -rf /tmp/npm* && \
    mkdir -p "$GHOST_CONTENT" && \
    chown -R node:node "$GHOST_CONTENT" && \
    # Ghost expects "config.js" to be in $GHOST_SOURCE, but it's more useful for
    # image users to manage that as part of their $GHOST_CONTENT volume, so we
    # symlink.
    ln -s "$GHOST_CONTENT/config.js" "$GHOST_SOURCE/config.js"

COPY docker-entrypoint.sh /usr/local/bin/

VOLUME $GHOST_CONTENT

EXPOSE 2368

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["npm", "start"]
