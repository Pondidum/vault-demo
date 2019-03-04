#! /bin/bash

export VAULT_TOKEN="vault"

# enable database secrets engine
echo "vault secrets enable database"
vault secrets enable database

read -n 1 -s -r

# configure how to communicate with postgres

echo '
vault write database/config/postgres \
  plugin_name="postgresql-database-plugin" \
  allowed_roles="*" \
  connection_url="postgresql://{{username}}:{{password}}@postgres/postgres?sslmode=disable" \
  username="postgres" \
  password="postgres"
'
vault write database/config/postgres \
  plugin_name="postgresql-database-plugin" \
  allowed_roles="*" \
  connection_url="postgresql://{{username}}:{{password}}@postgres/postgres?sslmode=disable" \
  username="postgres" \
  password="postgres"

read -n 1 -s -r

# create the "writer" dbrole: attached to postgres, and can do CRUD operations on tables

echo '
vault write database/roles/writer \
  db_name="postgres" \
  creation_statements=" \
    CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="10m" \
  max_ttl="1h"
'

vault write database/roles/writer \
  db_name="postgres" \
  creation_statements=" \
    CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="10m" \
  max_ttl="1h"

read -n 1 -s -r

# create the "migrator" dbrole: attached to postgres, and can modify table structure
echo '
vault write database/roles/migrator \
  db_name="postgres" \
  creation_statements=" \
    CREATE ROLE \"{{name}}\" WITH SUPERUSER LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="10m" \
  max_ttl="1h"
'

vault write database/roles/migrator \
  db_name="postgres" \
  creation_statements=" \
    CREATE ROLE \"{{name}}\" WITH SUPERUSER LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="10m" \
  max_ttl="1h"
