ARG version
FROM gitea/gitea:$version

COPY root /
RUN patch /etc/s6/gitea/run < /run.patch
