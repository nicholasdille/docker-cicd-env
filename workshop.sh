VM_BASE_NAME=seat
DOMAIN=go-nerd.de
HCLOUD_IMAGE=ubuntu-18.04
HCLOUD_LOCATION=fsn1
HCLOUD_SSH_KEY=209622
HCLOUD_TYPE=cx21

CLOUDINIT=$(cat <<"EOF"
#!/bin/bash

echo "Installing git..."
apt-get update
apt-get -y install git jq apache2-utils

echo "Installing docker..."
curl -fL https://get.docker.com | sh

echo "Installing docker-compose..."
COMPOSE_VERSION=$(curl -sLH "Accept: application/json" https://github.com/docker/compose/releases/latest | jq --raw-output '.tag_name')
echo "  Version ${COMPOSE_VERSION}"
curl -sLfo /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-Linux-x86_64
chmod +x /usr/local/bin/docker-compose

git -C /root clone https://github.com/nicholasdille/docker-cicd-env
EOF
)

mkdir -p ~/.local/log

new_vm() {
    local index=$1
    
    HCLOUD_VM_IP=$(hcloud server list --selector ${VM_BASE_NAME}=true,index=${index} --output columns=ipv4 | tail -n +2)
    if [[ -z "${HCLOUD_VM_IP}" ]]; then
        HCLOUD_VM_NAME="${VM_BASE_NAME}${index}"
        hcloud server create \
            --location ${HCLOUD_LOCATION} \
            --image ${HCLOUD_IMAGE} \
            --name ${HCLOUD_VM_NAME} \
            --ssh-key ${HCLOUD_SSH_KEY} \
            --type ${HCLOUD_TYPE} \
            --user-data-from-file <(echo "${CLOUDINIT}") >~/.local/log/${HCLOUD_VM_NAME}.log 2>&1
        hcloud server add-label ${HCLOUD_VM_NAME} ${VM_BASE_NAME}=true >>~/.local/log/${HCLOUD_VM_NAME}.log 2>&1
        hcloud server add-label ${HCLOUD_VM_NAME} index=${index} >>~/.local/log/${HCLOUD_VM_NAME}.log 2>&1
        HCLOUD_VM_IP=$(hcloud server list --selector ${VM_BASE_NAME}=true,index=${index} --output columns=ipv4 | tail -n +2)
    fi

    echo ${HCLOUD_VM_IP}
}

new_ssh_config() {
    local index=$1
    local ip=$2

    cat >~/.ssh/config.d/${VM_BASE_NAME}${index} <<EOF
Host ${VM_BASE_NAME}${index} ${ip} ${VM_BASE_NAME}${index}.${DOMAIN}
    HostName ${ip}
    User root
    IdentityFile ~/id_rsa_hetzner
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
    chmod 0600 ~/.ssh/config.d/${VM_BASE_NAME}${index}
}

new_dns_record() {
    local index=$1
    local ip=$2

    if test -z "${CF_API_KEY}"; then
        echo You must set CF_API_KEY
        exit 1
    fi
    if test -z "${CF_API_EMAIL}"; then
        echo You must set CF_API_EMAIL
        exit 1
    fi

    flarectl dns create-or-update --zone ${DOMAIN} --type A --name ${VM_BASE_NAME}${index} --content "${ip}" >>~/.local/log/${VM_BASE_NAME}${index}.log 2>&1
    flarectl dns create-or-update --zone ${DOMAIN} --type A --name "*.${VM_BASE_NAME}${index}" --content "${ip}" >>~/.local/log/${VM_BASE_NAME}${index}.log 2>&1
}

wait_docker() {
    local index=$1
    local ip=$2

    timeout 300 bash -c "while test -z \"\$(ssh ${ip} ps -C dockerd --no-headers)\"; do sleep 5; done"
}

create_env() {
    local index=$1
    local ip=$2

    USER=sommer19
    PASSWORD="Seat${index}%123"
    TRAEFIK_AUTH=$(htpasswd -nbB ${USER} "${PASSWORD}")
    NGINX_AUTH=$(htpasswd -nb ${USER} "${PASSWORD}")

    cat >.env-${VM_BASE_NAME}${index} <<EOF
DOMAIN=${VM_BASE_NAME}${index}.${DOMAIN}
ACME_EMAIL=webmaster@${DOMAIN}
TRAEFIK_API_CREDS=${TRAEFIK_AUTH}
REGISTRY_CREDS=${TRAEFIK_AUTH}
HUB_CREDS=${TRAEFIK_AUTH}
IDE_CREDS=${TRAEFIK_AUTH}
WEBDAV_CREDS=${NGINX_AUTH}
GITEA_ADMIN_USER=${USER}
GITEA_ADMIN_PASS=${PASSWORD}
GITEA_ADMIN_PASS=${USER}@${VM_BASE_NAME}${index}.${DOMAIN}
GRAFANA_ADMIN_PASS=${PASSWORD}
EOF
}

for I in $(seq 3 15); do
    echo Creating VM ${I}
    IP=$(new_vm ${I})
    echo   Got IP ${IP}

    echo Creating SSH configuration for VM ${I}
    new_dns_record ${I} ${IP}

    echo Adding DNS record for VM ${I}
    new_ssh_config ${I} ${IP}

    echo Waitig for dockerd on VM ${I}
    wait_docker ${I} ${IP}

    if test -d ssl-${VM_BASE_NAME}${I}; then
        echo Injecting certificate
        ssh ${IP} mkdir -p /ssl
        scp ssl-${VM_BASE_NAME}${I}/certificate.* ${IP}:/ssl/
    fi

    echo Creating environment
    if ! test -f .env-${VM_BASE_NAME}${I}; then
        create_env ${I} ${IP}
    fi

    echo Injecting environment
    scp .env-${VM_BASE_NAME}${I} ${IP}:/root/docker-cicd-env/.env

    echo Deploying services
    ssh ${IP} bash <<EOF
cd /root/docker-cicd-env
docker-compose --file docker-compose.ssl.yml up -d
EOF
done
