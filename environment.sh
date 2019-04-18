#! /bin/bash

echo '
export VAULT_ADDR="http://localhost:8200"
export VAULT_TOKEN="vault"

export PGHOST="localhost"
export PGUSER="postgres"
export PGPASSWORD="postgres"
'
