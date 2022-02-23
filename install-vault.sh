#!/bin/bash
# This script can be used to install Vault as per the deployment guide:
# https://www.vaultproject.io/guides/operations/deployment-guide.html


readonly VAULT_VERSION="1.9.3+ent"
export VAULT_ADDR=http://127.0.0.1:8200
export LOCAL_IP=$(ip a | grep inet | grep eth1 | cut -d' ' -f6 | cut -d'/' -f1)

function print_usage {
  echo
  echo "Usage: install-vault [OPTIONS]"
  echo "Options:"
  echo "This script can be used to install Vault and its dependencies. This script has been tested with Ubuntu 18.04 and Centos 7."
  echo
}

function log {
  local -r level="$1"
  local -r func="$2"
  local -r message="$3"
  local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  >&2 echo -e "${timestamp} [${level}] [${SCRIPT_NAME}:${func}] ${message}"
}

function setup_bash_profile {
  cat <<EOF >> /etc/bash.bashrc
export VAULT_ADDR=http://127.0.0.1:8200
EOF
}

function install_vault_enterprise {

  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt-get update -y
  sudo apt install -y vault-enterprise

}

function configure_vault_hcl {

  cp /vagrant/license-vault.txt /etc/vault.d/vault.hclic

  cat <<EOF > /etc/vault.d/vault.hcl
# Full configuration options can be found at https://www.vaultproject.io/docs/configuration

ui = true

#mlock = true
#disable_mlock = true

#api_addr      = "http://${LOCAL_IP}:8200"
#cluster_addr  = "https://${LOCAL_IP}:8201"

storage "raft" {
  path    = "opt/vault/data"
  node_id = "$(hostname)"
}

# HTTP listener
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = "true"
#  tls_cert_file = "/opt/vault/tls/tls.crt"
#  tls_key_file  = "/opt/vault/tls/tls.key"
}

# Enterprise license_path
# This will be required for enterprise as of v1.8
license_path = "/etc/vault.d/vault.hclic"

EOF

}

function start_vault {
  sudo systemctl start vault
}

function install_dependencies {
  sudo apt-get install -y jq
}

function main {
  local func="main"

  install_dependencies
  install_vault_enterprise
  configure_vault_hcl
  start_vault

}

main "$@"
