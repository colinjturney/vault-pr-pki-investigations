#!/bin/bash

export VAULT_ADDR=http://127.0.0.1:8200
export ROOT_TOKEN=$(cat /vagrant/$(hostname).txt | grep Token | cut -f2 -d' ')
export VAULT_1_UNSEAL_KEY=$(cat /vagrant/vault-1.txt | grep Unseal | cut -f2 -d' ')
export UNSEAL_KEY=$(cat /vagrant/$(hostname).txt | grep Unseal | cut -f2 -d' ')
export PR_WRAPPING_TOKEN=$(cat /vagrant/vault-1.txt | grep PRWrapping | cut -f2 -d' ')

vault login ${ROOT_TOKEN}
vault write sys/replication/performance/secondary/enable token="${PR_WRAPPING_TOKEN}"

echo "Waiting 30 seconds..."
sleep 30

vault operator generate-root -init -format=json > /vagrant/vault-2-gr.json

export GR_NONCE=$(cat /vagrant/vault-2-gr.json | jq -r '.nonce')
export GR_OTP=$(cat /vagrant/vault-2-gr.json | jq -r '.otp')

echo ${VAULT_1_UNSEAL_KEY} | vault operator generate-root -format=json -nonce="${GR_NONCE}" - > /vagrant/vault-2-et.json

export ENCODED_TOKEN=$(cat /vagrant/vault-2-et.json | jq -r '.encoded_token')

export VAULT_2_NEW_ROOT=$(vault operator generate-root -format=json -decode="${ENCODED_TOKEN}" -otp="${GR_OTP}" | jq -r '.token')

echo "NewToken: ${VAULT_2_NEW_ROOT}" >> /vagrant/vault-2.txt