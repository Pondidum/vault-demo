#! /bin/bash

CONTENT_JSON='content-type: application/json'

VAULT_HOST="localhost"
VAULT_PORT="8200"
VAULT_URL="http://$VAULT_HOST:$VAULT_PORT/v1"
VAULT_TOKEN='x-vault-token: vault'

# enable AppRole backend
curl --silent \
  --request POST \
  --url $VAULT_URL/sys/auth/approle \
  --header "$CONTENT_JSON" \
  --header "$VAULT_TOKEN" \
  --data '{ "type": "approle" }'


# create a policy allowing reads from the database secret engine
curl --silent \
  --request PUT \
  --url $VAULT_URL/sys/policy/postgres_connector \
  --header "$CONTENT_JSON" \
  --header "$VAULT_TOKEN" \
  --data '{
  "policy": "path \"database/creds/*\" { capabilities = [\"read\"] }"
}'


# generate a role_id, which would be embedded in the environment (e.g. by terraform)
curl --silent \
  --request POST \
  --url $VAULT_URL/auth/approle/role/demo_service \
  --header "$CONTENT_JSON" \
  --header "$VAULT_TOKEN" \
  --data '{
  "token_ttl": "20m",
  "token_max_ttl":"1h",
  "policies": [ "default", "postgres_connector" ]
}'


# read the generated role_id:
ROLE_ID=$(curl --silent \
  --request GET \
  --url $VAULT_URL/auth/approle/role/demo_service/role-id \
  --header "$VAULT_TOKEN" \
  | jq -r .data.role_id)

echo "role_id = $ROLE_ID"

# generate a secret_id, to be embedded in the application
SECRET_ID=$(curl --silent \
  --request POST \
  --url $VAULT_URL/auth/approle/role/demo_service/secret-id \
  --header "$CONTENT_JSON" \
  --header "$VAULT_TOKEN" \
  | jq -r .data.secret_id)

echo "secret_id = $SECRET_ID"
