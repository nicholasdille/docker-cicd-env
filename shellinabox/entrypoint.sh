#!/usr/bin/dumb-init /bin/bash
set -e

DOCKER_SOCK=/var/run/docker.sock
if [[ "${ENABLE_SOCKGUARD}" = "true" ]]; then
    DOCKER_SOCK=/var/run/docker-raw.sock
fi

# Start dockerd
/usr/local/bin/dind dockerd --host=unix:/${DOCKER_SOCK} &

if [[ "${ENABLE_SOCKGUARD}" = "true" ]]; then
    while ! test -S /var/run/docker-raw.sock; do
        sleep 1
    done
    /sockguard -upstream-socket /var/run/docker-raw.sock -filename /var/run/docker.sock &
fi

# Start SIAB
addgroup ${SHELL_GROUP}
adduser -D -h /home/${SHELL_USER} -s /bin/bash -G ${SHELL_GROUP} ${SHELL_USER}
shellinaboxd --disable-ssl --css=/white-on-black.css -s "/:${SHELL_USER}:${SHELL_GROUP}:/:/bin/bash --login"
