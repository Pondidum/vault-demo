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

curl --request PUT \
  --url $CONSUL_URL/agent/service/register \
  --header "$CONTENT_JSON" \
  --data '{ "ID": "postgres", "Name": "postgres", "Address": "'$POSTGRES_HOST'", "Port": '$POSTGRES_PORT'}'

curl --request PUT \
  --url $CONSUL_URL/agent/service/register \
  --header "$CONTENT_JSON" \
  --data '{ "ID": "rabbit", "Name": "rabbit", "Address": "'$RABBIT_HOST'", "Port": '$RABBIT_PORT'}'

curl --request PUT \
  --url $CONSUL_URL/agent/service/register \
  --header "$CONTENT_JSON" \
  --data '{ "ID": "vault", "Name": "vault", "Address": "'$VAULT_HOST'", "Port": '$VAULT_PORT'}'
