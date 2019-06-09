#! /bin/bash

CONSUL_URL="http://localhost:8500/v1"
CONTENT_JSON='content-type: application/json'

POSTGRES_HOST="localhost"
POSTGRES_PORT="5432"

RABBIT_HOST="localhost"
RABBIT_PORT="5672"

VAULT_HOST="localhost"
VAULT_PORT="8200"
VAULT_URL="http://$VAULT_HOST:$VAULT_PORT/v1"

echo "registering postgres into consul"
curl --silent \
  --request PUT \
  --url $CONSUL_URL/agent/service/register \
  --header "$CONTENT_JSON" \
  --data '{ "ID": "postgres", "Name": "postgres", "Address": "'$POSTGRES_HOST'", "Port": '$POSTGRES_PORT'}'

echo "registering rabbitmq into consul"
curl --silent \
  --request PUT \
  --url $CONSUL_URL/agent/service/register \
  --header "$CONTENT_JSON" \
  --data '{ "ID": "rabbit", "Name": "rabbit", "Address": "'$RABBIT_HOST'", "Port": '$RABBIT_PORT'}'

echo "registering vault into consul"
curl --silent \
  --request PUT \
  --url $CONSUL_URL/agent/service/register \
  --header "$CONTENT_JSON" \
  --data '{ "ID": "vault", "Name": "vault", "Address": "'$VAULT_HOST'", "Port": '$VAULT_PORT'}'

echo "enabling vault audit file"
MSYS_NO_PATHCONV=1 vault audit enable file file_path='/var/log/vault/audit.log'
