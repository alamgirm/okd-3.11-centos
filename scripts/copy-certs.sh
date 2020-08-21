#!/bin/bash

source settings.sh

# generate a key pair
if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
  ssh-keygen -q -f ~/.ssh/id_rsa -N ""
fi

# copy the key to the VM that I used for generating certs
ssh-copy-id root@181.215.182.160

# instal certbot and creade a folder to store the certs
#yum install --enablerepo=epel -y certbot
mkdir -p /etc/letsencrypt/live/${DOMAIN}

# get the certs from remote server
scp root@181.215.182.160:/etc/letsencrypt/live/${DOMAIN}/fullchain.pem  /etc/letsencrypt/live/${DOMAIN}/fullchain.pem
scp root@181.215.182.160:/etc/letsencrypt/live/${DOMAIN}/chain.pem  /etc/letsencrypt/live/${DOMAIN}/chain.pem
scp root@181.215.182.160:/etc/letsencrypt/live/${DOMAIN}/privkey.pem  /etc/letsencrypt/live/${DOMAIN}/privkey.pem

ssh-copy-id root@${OKD_MASTER_IP}
ssh -o StrictHostKeyChecking=no root@${OKD_MASTER_IP} "pwd" < /dev/null
ssh-copy-id root@${OKD_WORKER_NODE_1_IP}
ssh-copy-id root@${OKD_WORKER_NODE_2_IP}
