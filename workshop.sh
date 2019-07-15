VM_BASE_NAME=workshop
DOMAIN=inmylab.de
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
        HCLOUD_VM_NAME="${VM_BASE_NAME}-${index}"
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

    cat >~/.ssh/config.d/${VM_BASE_NAME}-${index} <<EOF
Host ${VM_BASE_NAME}-${index} ${ip} ${VM_BASE_NAME}-${index}.${DOMAIN}
    HostName ${ip}
    User root
    IdentityFile ~/id_rsa_hetzner
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
    chmod 0600 ~/.ssh/config.d/${VM_BASE_NAME}-${index}
}

new_dns_record() {
    local index=$1
    local ip=$2

    flarectl dns create-or-update --zone ${DOMAIN} --type A --name ${VM_BASE_NAME}-${index} --content "${ip}" >>~/.local/log/${VM_BASE_NAME}-${index}.log 2>&1
    flarectl dns create-or-update --zone ${DOMAIN} --type A --name "*.${VM_BASE_NAME}-${index}" --content "${ip}" >>~/.local/log/${VM_BASE_NAME}-${index}.log 2>&1
}

wait_docker() {
    local index=$1
    local ip=$2

    timeout 300 bash -c "while test -z \"\$(ssh ${ip} ps -C dockerd --no-headers)\"; do sleep 5; done"
}

echo Creating VM 1
IP=$(new_vm 1)
echo   Got IP ${IP}

echo Creating SSH configuration for VM 1
new_dns_record 1 ${IP}

echo Adding DNS record for VM 1
new_ssh_config 1 ${IP}

echo Waitig for dockerd on VM 1
wait_docker 1 ${IP}
