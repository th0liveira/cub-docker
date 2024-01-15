ARG DOCKER_VERSION_CADDY

FROM caddy:${DOCKER_VERSION_CADDY}-alpine

# Packages
RUN apk add --no-cache bash openssl

# -- Configure bash
COPY configs/bashrc-base /root/.bashrc

# -- Configure caddy
RUN rm -R /etc/caddy
RUN mkdir -p /etc/caddy
ADD configs/Caddyfile /etc/caddy/Caddyfile.original

# Linktree
ADD linktree /opt/linktree

# Entrypoint
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ADD entrypoint.d /entrypoint.d
RUN chmod +x -R /entrypoint.d

ENTRYPOINT ["/entrypoint.sh"]
