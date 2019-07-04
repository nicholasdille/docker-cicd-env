#!/bin/bash

sleep 10

gitea admin create-user --name "${GITEA_ADMIN_NAME}" --password "${GITEA_ADMIN_PASS}" --email "${GITEA_ADMIN_MAIL}" --admin
