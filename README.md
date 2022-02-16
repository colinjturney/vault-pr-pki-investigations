# Vault PR PKI Investigations

An investigation into the functionality of the PKI secrets engine and its interaction with Vault Performance Replication

# Pre-requisites

* Vault Enterprise License allowing Performance Replication (place in repository directory in file called `license-vault.txt`)
* Vagrant (Tested using v.2.2.19 with Virtualbox)

# How to run the demo

1. `vagrant up`
1. `vagrant ssh vault-1`, then on vault-1:
    1. Run the following command `/vagrant/0-init-vault.sh`
    1. Then run `/vagrant/1-setup-pr-vault-1.sh`
1. Exit the SSH session on vault-1
1. `vagrant ssh vault-2`, then on vault-2:
    1. Run the following command `/vagrant/0-init-vault.sh`
    1. Then run `/vagrant/2-setup-pr-vault-2.sh`
1. Exit the SSH session on vault-2.
1. `vagrant ssh vault-1` again, then on vault-1:
    1. Run the following command `/vagrant/3-configure-pki-vault-1.sh`
    1. Then run `/vagrant/4-issue-pki-vault-1.sh`
1. Exit the SSH session on vault-1.
1. `vagrant ssh vault-2` again, then on vault-2
    1. Then run `/vagrant/5-issue-pki-vault-2.sh`

# Testing notes

## Aim

The aim of this demo is to investigate how the PKI secrets engine behaves in conjunction with performance replication, particularly around the use of Certificate Revocation Lists (CRLs)

## Test Conditions

* Environment created with two VMs each acting as single-node Vault "clusters, `vault-1` (Performance Replication Primary) and `vault-2` (Performance Replication Secondary).
* PKI secrets engine is enabled on `vault-1`, along with a single role for generating certificates.
* Both secrets engine and role confirmed to have replicated across to the PR secondary.

## Test Scenarios

### Scenario 1

* CRL distribution point set to 127.0.0.1:8200, testing to see whether the CRL distribution point URL somehow points to the API address of the given cluster that the cert is being generated from.
* Certificate requested from `vault-1`
* Certificate requested from `vault-2`

#### Finding

Inspecting x509v3 extension - CRL distribution points shows that 127.0.0.1:8200 is merely hardcoded into the certificate. There's no "magic" to somehow link the CRL URL to the host the cert is generated from, 
which would have allowed separate CRLs to be maintained per cluster.

### Scenario 2

* CRL distribution point set to `vault-1`'s IP address
* Certificate requested from `vault-1`
* Certificate requested from `vault-2`
* Certificate from `vault-2` revoked

Has CRL on `vault-1` been updated to suit?

#### Finding

No, it hasn't. Even after a CRL rotation and despite the CRL distribution point URL for the certificate being set to `vault-1`'s CRL URL, the revoked certificate generated from `vault-2` does not feature on `vault-1`s CRL. Instead, a CRL maintained on `vault-2` is updated to include the revoked certificate- this is despite the x509v3 extension CRL distribution point pointing towards `vault-1`.