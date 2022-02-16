#!/bin/bash

export VAULT_ADDR=http://127.0.0.1:8200
export ROOT_TOKEN=$(cat /vagrant/$(hostname).txt | grep NewToken | cut -f2 -d' ')

if [[ $(hostname) != "vault-2" ]]
then
    echo "Run this on vault-2"
    exit 1
fi

vault login ${ROOT_TOKEN}

vault write pki/issue/example-dot-com \
    common_name=vault-2.my-website.com \
    ttl=60m
