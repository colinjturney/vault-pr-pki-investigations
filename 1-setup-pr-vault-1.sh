#!/bin/bash

export VAULT_ADDR=http://127.0.0.1:8200
export ROOT_TOKEN=$(cat /vagrant/$(hostname).txt | grep Token | cut -f2 -d' ')

vault login ${ROOT_TOKEN}

vault write -f sys/replication/performance/primary/enable

export SECONDARY_WRAPPING_TOKEN=$(vault write -format=json sys/replication/performance/primary/secondary-token id="vault-2" | jq -r '.wrap_info.token')

echo "PRWrapping: ${SECONDARY_WRAPPING_TOKEN}" >> /vagrant/$(hostname).txt

