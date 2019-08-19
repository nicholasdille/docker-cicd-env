#!/usr/bin/dumb-init /bin/bash

shellinaboxd --disable-ssl &

/usr/local/bin/dind dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375
