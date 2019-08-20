#!/usr/bin/dumb-init /bin/bash
set -e

addgroup ${SHELL_GROUP}
adduser -D -h /home/${SHELL_USER} -s /bin/bash -G ${SHELL_GROUP} ${SHELL_USER}

shellinaboxd --disable-ssl --css=/white-on-black.css -s "/:${SHELL_USER}:${SHELL_GROUP}:/:/bin/bash" &

/usr/local/bin/dind dockerd --host=unix:///var/run/docker.sock
