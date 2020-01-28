#!/bin/sh -eu

src="/vagrant/box"

# consul setup

rc-update add consul
rc-service consul start || echo "rc-service exit code $? is suppressed";
sleep 5

# vault setup
cp $src/vault.hcl /etc/vault/vault.hcl

mkdir -p "/var/vault"
chown vault:vault "/var/vault"

rc-update add vault
rc-service vault start || echo "rc-service exit code $? is suppressed";
sleep 10

export VAULT_ADDR="http://localhost:8200"

init_json=$(vault operator init -key-shares=1 -key-threshold=1 -format=json)
root_token=$(echo "$init_json" | jq -r .root_token)
unseal_key=$(echo "$init_json" | jq -r .unseal_keys_b64[0])

vault operator unseal "$unseal_key"

export VAULT_TOKEN="$root_token"

audit_file="/var/log/vault_audit.log"

touch "$audit_file"
chown vault:vault "$audit_file"
vault audit enable file file_path="$audit_file"

# nomad setup

escaped_token=$(echo "$root_token" | sed -e 's/[\/&]/\\&/g')
sed "s/VAULT_TOKEN/$escaped_token/g" "$src/nomad.hcl" > /etc/nomad/nomad.hcl

rc-update add nomad
rc-service nomad start || echo "rc-service exit code $? is suppressed";

# containers!

mkdir -p "/vagrant/.artifacts"

docker run \
    -d \
    --restart always \
    -p 3030:3030 \
    -e 'PORT=3030' \
    -v /vagrant/.artifacts:/web \
    halverneus/static-file-server:latest

curl --silent \
    --request PUT \
    --url http://localhost:8500/v1/agent/service/register \
    --header 'content-type: application/json' \
    --data '{ "ID": "artifacts", "Name": "artifacts", "Port": 3030 }'

docker run \
    -d \
    --restart always \
    -p 5432:5432 \
    -e "POSTGRES_PASSWORD=postgres" \
    postgres:alpine

curl --silent \
    --request PUT \
    --url http://localhost:8500/v1/agent/service/register \
    --header 'content-type: application/json' \
    --data '{ "ID": "postgres", "Name": "postgres", "Port": 5432 }'


# dump machine info to the host directory
mkdir -p /vagrant/.machine

echo "$root_token" > /vagrant/.machine/vault_token
echo "$unseal_key" > /vagrant/.machine/vault_unseal_key
echo "$(ip route get 1 | awk '{print $(NF-2);exit}')" > /vagrant/.machine/ip
