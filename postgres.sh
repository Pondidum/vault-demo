#! /bin/bash


sql_command="
create role \"vault-admin\" with Login password 'supersecure' CreateRole;
grant connect on database postgres to \"vault-admin\";
"

echo "psql -c $sql_command"
psql -c "$sql_command"

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
  username="vault-admin" \
  password="supersecure"
'
vault write database/config/postgres \
  plugin_name="postgresql-database-plugin" \
  allowed_roles="*" \
  connection_url="postgresql://{{username}}:{{password}}@postgres/postgres?sslmode=disable" \
  username="vault-admin" \
  password="supersecure"

read -n 1 -s -r

# create the "reader" dbrole: attached to postgres, and can do CRUD operations on tables

echo '
vault write database/roles/reader \
  db_name="postgres" \
  creation_statements=" \
    CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="5m" \
  max_ttl="1h"
'

vault write database/roles/reader \
  db_name="postgres" \
  creation_statements=" \
    CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="5m" \
  max_ttl="1h"

read -n 1 -s -r

# create the "writer" dbrole: attached to postgres, and can do CRUD operations on tables

echo '
vault write database/roles/writer \
  db_name="postgres" \
  creation_statements=" \
    CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="5m" \
  max_ttl="1h"
'

vault write database/roles/writer \
  db_name="postgres" \
  creation_statements=" \
    CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="5m" \
  max_ttl="1h"

read -n 1 -s -r
