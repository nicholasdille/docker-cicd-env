ARG DOCKER_VERSION=stable

FROM golang:1.11-alpine AS builder
RUN apk add --update-cache --no-cache \
        ca-certificates \
        git
ENV GO111MODULE=on
RUN git clone https://github.com/buildkite/sockguard /go/src/github.com/buildkite/sockguard
WORKDIR /go/src/github.com/buildkite/sockguard
RUN go mod download \
 && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
        go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/sockguard ./cmd/sockguard/

FROM docker:${DOCKER_VERSION}-dind
RUN echo @testing http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
 && apk add --update-cache --no-cache \
        ca-certificates \
        dumb-init \
        bash \
        git \
        curl \
        jq \
        shellinabox@testing \
 && curl -sLfo /white-on-black.css https://github.com/shellinabox/shellinabox/raw/v2.20/shellinabox/white-on-black.css
COPY --from=builder /go/bin/sockguard /sockguard
ENV SHELL_USER user
ENV SHELL_GROUP user
ENV ENABLE_SOCKGUARD true
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
