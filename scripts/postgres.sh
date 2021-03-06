#!/bin/bash -eu

# export VAULT_ADDR="http://$(cat .machine/ip):8200"
# export VAULT_TOKEN="$(cat .machine/vault_token)"

# enable database secrets engine
echo "vault secrets enable database"
vault secrets enable database 2>/dev/null || echo "database secrets engine already enabled"

read -n 1 -s -r

# create a policy allowing reads from the database secret engine
echo "
echo 'path \"database/creds/*\" {
  capabilities = [\"read\"]
}' | vault policy write postgres_connector -
"

echo 'path "database/creds/*" {
  capabilities = ["read"]
}' | vault policy write postgres_connector -

read -n 1 -s -r

# configure how to communicate with postgres
echo '
vault write database/config/postgres
  plugin_name="postgresql-database-plugin"
  allowed_roles="*"
  connection_url="postgresql://{{username}}:{{password}}@postgres.service.consul/postgres?sslmode=disable"
  username="postgres"
  password="postgres"
'

vault write database/config/postgres \
  plugin_name="postgresql-database-plugin" \
  allowed_roles="*" \
  connection_url="postgresql://{{username}}:{{password}}@postgres.service.consul/postgres?sslmode=disable" \
  username="postgres" \
  password="postgres"

read -n 1 -s -r

# create the "reader" dbrole: attached to postgres, and can do CRUD operations on tables
echo '
vault write database/roles/reader
  db_name="postgres"
  creation_statements="
    CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD "'"{{password}}"'" VALID UNTIL "'"{{expiration}}"'";
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"
  default_ttl="10m"
  max_ttl="1h"
'

vault write database/roles/reader \
  db_name="postgres" \
  creation_statements=" \
    CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="10m" \
  max_ttl="1h"

read -n 1 -s -r

# create the "writer" dbrole: attached to postgres, and can do CRUD operations on tables
echo '
vault write database/roles/writer
  db_name="postgres"
  creation_statements="
    CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD "'"{{password}}"'" VALID UNTIL "'"{{expiration}}"'";
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"
  default_ttl="10m"
  max_ttl="1h"
'

vault write database/roles/writer \
  db_name="postgres" \
  creation_statements=" \
    CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="10m" \
  max_ttl="1h"
