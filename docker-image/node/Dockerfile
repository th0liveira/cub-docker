ARG DOCKER_VERSION_NODE

FROM node:${DOCKER_VERSION_NODE}-alpine

# -- Install dependecies
RUN apk add --no-cache python3 py3-pip ca-certificates bash git inotify-tools rsync

# -- Configure bash
COPY configs/bashrc-base /root/.bashrc

# -- Setup NPM
RUN npm config set cache /mnt/cache --global

# nodemon
RUN npm install -g nodemon concurrently

# AWS cli / openssl
RUN pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
        awscli \
    && rm -rf /var/cache/apk/

# Entrypoint
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ADD entrypoint.d /entrypoint.d
RUN chmod +x -R /entrypoint.d

ENTRYPOINT ["/entrypoint.sh"]
