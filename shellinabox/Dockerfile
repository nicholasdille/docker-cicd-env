ARG DOCKER_VERSION=stable
FROM docker:${DOCKER_VERSION}-dind

RUN echo @testing http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
 && apk add --update-cache --no-cache \
        dumb-init \
        bash \
        git \
        curl \
        jq \
        shellinabox@testing \
 && curl -sLfo /white-on-black.css https://github.com/shellinabox/shellinabox/raw/v2.20/shellinabox/white-on-black.css

ENV SHELL_USER user
ENV SHELL_GROUP user
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
