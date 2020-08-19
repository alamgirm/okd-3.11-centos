#!/bin/bash

source settings.sh

if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
  ssh-keygen -t rsa
fi

#ssh-copy-id root@$181.215.182.160

mkdir -p /etc/letsencrypt/live/${DOMAIN}

scp root@181.215.182.160:/etc/letsencrypt/live/${DOMAIN}/fullchain.pem  /etc/letsencrypt/live/${DOMAIN}/fullchain.pem
scp root@181.215.182.160:/etc/letsencrypt/live/${DOMAIN}/chain.pem  /etc/letsencrypt/live/${DOMAIN}/chain.pem
scp root@181.215.182.160:/etc/letsencrypt/live/${DOMAIN}/privkey.pem  /etc/letsencrypt/live/${DOMAIN}/privkey.pem

