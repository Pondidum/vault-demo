#! /bin/bash

CONTENT_JSON='content-type: application/json'

VAULT_HOST="localhost"
VAULT_PORT="8200"
VAULT_URL="http://$VAULT_HOST:$VAULT_PORT/v1"
VAULT_TOKEN='x-vault-token: vault'

# enable database secrets engine
curl --request POST \
  --url $VAULT_URL/sys/mounts/database \
  --header "$CONTENT_JSON" \
  --header "$VAULT_TOKEN" \
  --data '{ "type": "database" }'

# configure how to communicate with postgres
curl --request POST \
  --url $VAULT_URL/database/config/postgres \
  --header "$CONTENT_JSON" \
  --header "$VAULT_TOKEN" \
  --data '{
  "plugin_name":
  "postgresql-database-plugin",
  "allowed_roles":[ "*" ],
  "connection_url":"postgresql://{{username}}:{{password}}@postgres/postgres?sslmode=disable",
  "username":"postgres",
  "password":"postgres"
}'


# create the "writer" dbrole: attached to postgres, and can do CRUD operations on tables
curl --request POST \
  --url $VAULT_URL/database/roles/writer \
  --header "$CONTENT_JSON" \
  --header "$VAULT_TOKEN" \
  --data '{
	"db_name": "postgres",
	"creation_statements": [
		"CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '\''{{password}}'\'' VALID UNTIL '\''{{expiration}}'\''",
		"GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA public TO \"{{name}}\""
	],
	"default_ttl": "10m",
	"max_ttl": "1h"
}'

# create the "migrator" dbrole: attached to postgres, and can modify table structure
curl --request POST \
  --url $VAULT_URL/database/roles/migrator \
  --header "$CONTENT_JSON" \
  --header "$VAULT_TOKEN" \
  --data '{
	"db_name": "postgres",
	"creation_statements": [
		"CREATE ROLE \"{{name}}\" WITH SUPERUSER LOGIN PASSWORD '\''{{password}}'\'' VALID UNTIL '\''{{expiration}}'\''",
		"GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\""
	],
	"default_ttl": "10m",
	"max_ttl": "1h"
}'
