FROM nginx:stable

RUN apt-get update \
 && apt-get install -y nginx-extras \
 && rm /etc/nginx/sites-enabled/* \
 && mkdir -p /data /etc/nginx/auth \
 && chown www-data /data

COPY default.conf /etc/nginx/conf.d/default.conf
COPY webdav-entrypoint.sh /

ENTRYPOINT /webdav-entrypoint.sh
