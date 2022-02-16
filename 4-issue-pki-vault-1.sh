#!/bin/bash

export VAULT_ADDR=http://127.0.0.1:8200
export ROOT_TOKEN=$(cat /vagrant/$(hostname).txt | grep Token | cut -f2 -d' ')

if [[ $(hostname) != "vault-1" ]]
then
    echo "Run this on vault-1"
    exit 1
fi

vault write pki/issue/example-dot-com \
    common_name=vault-1.my-website.com \
    ttl=60m



#0f:2d:c5:bb:d5:2b:4c:4d:9a:55:80:dd:34:05:35:57:1d:c1:97:b7