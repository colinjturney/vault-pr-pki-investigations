#!/bin/bash

export VAULT_ADDR=http://127.0.0.1:8200
export ROOT_TOKEN=$(cat /vagrant/$(hostname).txt | grep Token | cut -f2 -d' ')

if [[ $(hostname) != "vault-1" ]]
then
    echo "Run this on vault-1"
    exit 1
fi

vault secrets enable pki

vault secrets tune -max-lease-ttl=8760 pki

vault write pki/root/generate/internal \
    common_name=my-website.com \
    ttl=8760h

vault write pki/config/urls \
    issuing_certificates="http://192.168.56.101:8200/v1/pki/ca" \
    crl_distribution_points="http://192.168.56.101:8200/v1/pki/crl" \

vault write pki/roles/example-dot-com \
    allowed_domains=my-website.com \
    allow_subdomains=true \
    max_ttl=72h
