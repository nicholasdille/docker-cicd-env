#!/bin/sh

echo "${WEBDAV_CREDS}" > /etc/nginx/auth/htpasswd

exec nginx -g "daemon off;"
