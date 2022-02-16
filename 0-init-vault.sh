#!/bin/bash

function install_jq {
  sudo apt-get -y install jq
}

function init_vault {

  export VAULT_ADDR=http://127.0.0.1:8200 

  vault operator init -key-shares=1 -key-threshold=1 > /tmp/init-output.txt 2>&1

  echo "Unseal: "$(grep Unseal /tmp/init-output.txt | cut -d' ' -f4) > /vagrant/$(hostname).txt
  echo "Token: "$(grep Token /tmp/init-output.txt | cut -d' ' -f4) >> /vagrant/$(hostname).txt
  rm /tmp/init-output.txt

  export UNSEAL_KEY=$(cat /vagrant/$(hostname).txt | grep Unseal | cut -f2 -d' ')
  export ROOT_TOKEN=$(cat /vagrant/$(hostname).txt | grep Token | cut -f2 -d' ')

  # Unseal Vault
  vault operator unseal ${UNSEAL_KEY}

}

init_vault