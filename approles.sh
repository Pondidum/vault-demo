#! /bin/bash

export VAULT_TOKEN="vault"

# enable AppRole backend
vault auth enable approle

# create a policy allowing reads from the database secret engine
echo 'path "database/creds/*" {
  capabilities = ["read"]
}' | vault policy write postgres_connector -

# ci could read the policies and update vault (after PR, of course...)
vault write auth/approle/role/demo_service \
    token_ttl=20m \
    token_max_ttl=1h \
    policies="default, postgres_connector"

# read the generated role_id:
vault read auth/approle/role/demo_service/role-id

# create a secret id for the instance of the application
vault write -f auth/approle/role/demo_service/secret-id
